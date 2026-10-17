import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/chat_rooms_repository.dart';
class ChatRoomsRepositoryImpl implements ChatRoomsRepository {
  final SupabaseClient _supabaseClient;

  final Map<String, StreamController<List<Map<String, dynamic>>>> _participantsControllers = {};
  final Map<String, StreamController<List<Map<String, dynamic>>>> _messagesControllers = {};

  final Map<String, List<Map<String, dynamic>>> _localParticipants = {};
  final Map<String, List<Map<String, dynamic>>> _localMessages = {};

  bool _isLocalRoom(String roomId) {
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return !uuidRegex.hasMatch(roomId);
  }

  void _initLocalRoom(String roomId) {
    if (!_localParticipants.containsKey(roomId)) {
      _localParticipants[roomId] = [];
    }
    if (!_localMessages.containsKey(roomId)) {
      _localMessages[roomId] = [
        {
          'id': 'system_welcome_msg',
          'room_id': roomId,
          'user_id': 'system_ai',
          'message_text': '¡Bienvenido a la mesa de gremio! Aquí puedes practicar inglés de forma libre.',
          'message_type': 'system',
          'created_at': DateTime.now().toIso8601String(),
        }
      ];
    }
    if (!_participantsControllers.containsKey(roomId)) {
      _participantsControllers[roomId] = StreamController<List<Map<String, dynamic>>>.broadcast();
    }
    if (!_messagesControllers.containsKey(roomId)) {
      _messagesControllers[roomId] = StreamController<List<Map<String, dynamic>>>.broadcast();
    }
  }

  ChatRoomsRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      // 1. Salas activas (no borradas). G-B: sin hardcode, sin N+1.
      final rooms = await _supabaseClient
          .from('chat_rooms')
          .select('*')
          .eq('is_active', true)
          .isFilter('deleted_at', null)
          .order('created_at');

      if (rooms.isEmpty) return [];

      // 2. Conteos agregados de participantes en UNA consulta (anti N+1).
      final roomIds = rooms.map((r) => r['id'] as String).toList();
      final countsData = await _supabaseClient
          .from('chat_room_participants')
          .select('room_id, is_speaker, presence_state')
          .inFilter('room_id', roomIds);

      final Map<String, int> seatedCount = {};
      final Map<String, int> standingCount = {};
      for (final p in countsData) {
        final rid = p['room_id'] as String;
        // Fuente de verdad: presence_state (los RPC nuevos solo actualizan este
        // campo). Fallback al esquema antiguo solo para filas legacy.
        final presence = p['presence_state'] as String? ?? (p['is_speaker'] == true ? 'seated' : 'standing');
        if (presence == 'seated') {
          seatedCount[rid] = (seatedCount[rid] ?? 0) + 1;
        } else {
          standingCount[rid] = (standingCount[rid] ?? 0) + 1;
        }
      }

      final maxSpeakers = rooms.map((r) => (r['max_seats'] as num?)?.toInt() ?? (r['max_speakers'] as num?)?.toInt() ?? 8).toList();

      return List.generate(rooms.length, (i) {
        final room = rooms[i];
        final rid = room['id'] as String;
        return {
          'id': rid,
          'title': room['title'] as String? ?? 'Mesa de Gremio',
          'category': room['category'] as String? ?? 'general',
          'room_type': room['room_type'] as String? ?? 'discussion',
          'description': room['description'] as String? ?? '',
          'moderator_id': room['moderator_id'] as String?,
          'moderator_type': room['moderator_type'] as String? ?? 'ai',
          'has_ai_moderator': room['has_ai_moderator'] as bool? ?? false,
          'mana_cost_per_min': (room['mana_cost_per_min'] as num?)?.toInt() ?? 0,
          'max_speakers': maxSpeakers[i],
          'speakers_count': seatedCount[rid] ?? 0,
          'listeners_count': standingCount[rid] ?? 0,
          'seated_count': seatedCount[rid] ?? 0,
          'standing_count': standingCount[rid] ?? 0,
          'max_seats': maxSpeakers[i],
          'max_standing': (room['max_standing'] as num?)?.toInt() ?? 8,
          'created_at': room['created_at'] as String?,
        };
      });
    } catch (e) {
      // Re-lanzar para que el CachedFutureController conserve el último estado
      // (SWR) en vez de vaciar la lista por un error transitorio.
      debugPrint('getRooms error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createRoom({
    required String title,
    required String category,
    required String moderatorId,
    String? roomType,
  }) async {
    final room = await _supabaseClient.from('chat_rooms').insert({
      'title': title,
      'category': category,
      'moderator_id': moderatorId,
      'room_type': roomType ?? 'ai_practice',
    }).select().single();

    // Auto join the moderator to speaker slot 1
    await joinRoom(
      roomId: room['id'] as String,
      userId: moderatorId,
      isSpeaker: true,
      speakerSlot: 1,
    );

    return room;
  }

  @override
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required bool isSpeaker,
    int? speakerSlot,
  }) async {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localParticipants[roomId]!;
      if (isSpeaker && speakerSlot != null) {
        if (list.any((p) => p['speaker_slot'] == speakerSlot)) {
          throw Exception('El espacio de habla $speakerSlot ya está ocupado.');
        }
      }
      list.removeWhere((p) => p['user_id'] == userId);
      list.add({
        'id': 'local_${userId}_$roomId',
        'room_id': roomId,
        'user_id': userId,
        'is_speaker': isSpeaker,
        'speaker_slot': speakerSlot,
        'joined_at': DateTime.now().toIso8601String(),
      });
      _participantsControllers[roomId]!.add(List.from(list));
      return;
    }

    if (isSpeaker && speakerSlot != null) {
      final occupied = await _supabaseClient
          .from('chat_room_participants')
          .select('id')
          .eq('room_id', roomId)
          .eq('speaker_slot', speakerSlot)
          .maybeSingle();

      if (occupied != null) {
        throw Exception('El espacio de habla $speakerSlot ya está ocupado.');
      }
    }

    await _supabaseClient.from('chat_room_participants').upsert({
      'room_id': roomId,
      'user_id': userId,
      'is_speaker': isSpeaker,
      'speaker_slot': speakerSlot,
      'joined_at': DateTime.now().toIso8601String(),
    }, onConflict: 'room_id, user_id');
  }

  @override
  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localParticipants[roomId]!;
      list.removeWhere((p) => p['user_id'] == userId);
      _participantsControllers[roomId]!.add(List.from(list));
      return;
    }

    // RPC leave_table: libera la silla y auto-asienta al primero de la cola.
    // Fallback al borrado directo si el RPC aún no existe en el proyecto
    // (migración pendiente). La mesa vacía se conserva en el gremio.
    try {
      await _supabaseClient.rpc('leave_table', params: {
        'p_room_id': roomId,
        'p_user_id': userId,
      });
      return;
    } catch (e) {
      debugPrint('leave_table RPC failed (fallback a delete): $e');
    }

    await _supabaseClient
        .from('chat_room_participants')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }

  @override
  Future<void> claimSpeakerSlot({
    required String roomId,
    required String userId,
    required int speakerSlot,
  }) async {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localParticipants[roomId]!;
      if (list.any((p) => p['speaker_slot'] == speakerSlot)) {
        throw Exception('El espacio de habla $speakerSlot ya está ocupado.');
      }
      list.removeWhere((p) => p['user_id'] == userId);
      list.add({
        'id': 'local_${userId}_$roomId',
        'room_id': roomId,
        'user_id': userId,
        'is_speaker': true,
        'speaker_slot': speakerSlot,
        'joined_at': DateTime.now().toIso8601String(),
      });
      _participantsControllers[roomId]!.add(List.from(list));
      return;
    }

    final occupied = await _supabaseClient
        .from('chat_room_participants')
        .select('id')
        .eq('room_id', roomId)
        .eq('speaker_slot', speakerSlot)
        .maybeSingle();

    if (occupied != null) {
      throw Exception('El espacio de habla $speakerSlot ya está ocupado.');
    }

    await _supabaseClient.from('chat_room_participants').upsert({
      'room_id': roomId,
      'user_id': userId,
      'is_speaker': true,
      'speaker_slot': speakerSlot,
    }, onConflict: 'room_id, user_id');
  }

  @override
  Future<void> sendChatMessage({
    required String roomId,
    required String userId,
    required String messageText,
  }) async {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localMessages[roomId]!;
      list.add({
        'id': 'local_msg_${DateTime.now().millisecondsSinceEpoch}',
        'room_id': roomId,
        'user_id': userId,
        'message_text': messageText,
        'message_type': 'text',
        'created_at': DateTime.now().toIso8601String(),
      });
      _messagesControllers[roomId]!.add(List.from(list));
      return;
    }

    await _supabaseClient.from('chat_room_messages').insert({
      'room_id': roomId,
      'user_id': userId,
      'message_text': messageText,
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> streamParticipants(String roomId) {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      Timer.run(() {
        if (!_participantsControllers[roomId]!.isClosed) {
          _participantsControllers[roomId]!.add(List.from(_localParticipants[roomId]!));
        }
      });
      return _participantsControllers[roomId]!.stream;
    }

    return _supabaseClient
        .from('chat_room_participants')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .map((list) {
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> streamMessages(String roomId) {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      Timer.run(() {
        if (!_messagesControllers[roomId]!.isClosed) {
          _messagesControllers[roomId]!.add(List.from(_localMessages[roomId]!));
        }
      });
      return _messagesControllers[roomId]!.stream;
    }

    return _supabaseClient
        .from('chat_room_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((list) {
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        });
  }

  @override
  Future<int> countActiveSpeakers(String roomId) async {
    try {
      if (_isLocalRoom(roomId)) {
        _initLocalRoom(roomId);
        return _localParticipants[roomId]!
            .where((p) => p['is_speaker'] == true)
            .length;
      }

      final result = await _supabaseClient
          .from('chat_room_participants')
          .select('id')
          .eq('room_id', roomId)
          .eq('is_speaker', true);

      return result.length;
    } catch (e) {
      debugPrint('countActiveSpeakers error para $roomId: $e');
      return 0;
    }
  }

  @override
  Future<void> joinRoomAsCurrentUser(String roomId) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('joinRoomAsCurrentUser: sin usuario autenticado para $roomId');
      return;
    }

    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localParticipants[roomId]!;
      list.removeWhere((p) => p['user_id'] == userId);
      list.add({
        'id': 'local_${userId}_$roomId',
        'room_id': roomId,
        'user_id': userId,
        'is_speaker': false,
        'speaker_slot': null,
        'joined_at': DateTime.now().toIso8601String(),
      });
      _participantsControllers[roomId]!.add(List.from(list));
      return;
    }

    try {
      // El esquema real no tiene columna is_present: la presencia se modela con
      // la existencia de la fila (upsert de room_id + user_id).
      await _supabaseClient.from('chat_room_participants').upsert({
        'room_id': roomId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'room_id, user_id');
    } catch (e) {
      debugPrint('joinRoomAsCurrentUser error para $roomId: $e');
    }
  }

  @override
  Future<void> leaveRoomAsCurrentUser(String roomId) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('leaveRoomAsCurrentUser: sin usuario autenticado para $roomId');
      return;
    }

    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      _localParticipants[roomId]!.removeWhere((p) => p['user_id'] == userId);
      _participantsControllers[roomId]!.add(List.from(_localParticipants[roomId]!));
      return;
    }

    try {
      // Sin is_present: la ausencia se modela borrando la fila (mismo patrón
      // que leaveRoom, respeta la RLS "Usuarios pueden abandonar").
      await _supabaseClient
          .from('chat_room_participants')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('leaveRoomAsCurrentUser error para $roomId: $e');
    }
  }

    // ── Mesas del gremio: presencia de pie/sentado (RPC server-side) ────────────

  @override
  Future<void> joinTable(String roomId) async {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localParticipants[roomId]!;
      list.removeWhere((p) => p['user_id'] == _currentUserId());
      list.add({
        'id': 'local_${_currentUserId()}_$roomId',
        'room_id': roomId,
        'user_id': _currentUserId(),
        'is_speaker': false,
        'speaker_slot': null,
        'presence_state': 'standing',
        'joined_at': DateTime.now().toIso8601String(),
      });
      _participantsControllers[roomId]!.add(List.from(list));
      return;
    }
    final uid = _currentUserId();
    await _supabaseClient.rpc('join_table', params: {
      'p_room_id': roomId,
      'p_user_id': uid,
    });
  }

  @override
  Future<void> sitDown(String roomId, int seat) async {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localParticipants[roomId]!;
      if (list.any((p) => p['speaker_slot'] == seat && p['presence_state'] == 'seated')) {
        throw const ChatRoomException('seat_taken', 'La silla ya está ocupada.');
      }
      list.removeWhere((p) => p['user_id'] == _currentUserId());
      list.add({
        'id': 'local_${_currentUserId()}_$roomId',
        'room_id': roomId,
        'user_id': _currentUserId(),
        'is_speaker': true,
        'speaker_slot': seat,
        'presence_state': 'seated',
        'joined_at': DateTime.now().toIso8601String(),
      });
      _participantsControllers[roomId]!.add(List.from(list));
      return;
    }
    final res = await _supabaseClient.rpc('claim_seat', params: {
      'p_room_id': roomId,
      'p_user_id': _currentUserId(),
      'p_seat': seat,
    });
    final code = res as String? ?? 'ok';
    if (code != 'ok') {
      throw ChatRoomException(code, _seatError(code));
    }
  }

  @override
  Future<String> requestSeat(String roomId) async {
    if (_isLocalRoom(roomId)) {
      await sitDown(roomId, _firstFreeLocalSeat(roomId));
      return 'seated';
    }
    final res = await _supabaseClient.rpc('request_seat', params: {
      'p_room_id': roomId,
      'p_user_id': _currentUserId(),
    });
    return res as String? ?? 'queued';
  }

  @override
  Future<void> standUp(String roomId) async {
    if (_isLocalRoom(roomId)) {
      _initLocalRoom(roomId);
      final list = _localParticipants[roomId]!;
      list.removeWhere((p) => p['user_id'] == _currentUserId());
      list.add({
        'id': 'local_${_currentUserId()}_$roomId',
        'room_id': roomId,
        'user_id': _currentUserId(),
        'is_speaker': false,
        'speaker_slot': null,
        'presence_state': 'standing',
        'joined_at': DateTime.now().toIso8601String(),
      });
      _participantsControllers[roomId]!.add(List.from(list));
      return;
    }
    await _supabaseClient.rpc('stand_up', params: {
      'p_room_id': roomId,
      'p_user_id': _currentUserId(),
    });
  }

  @override
  Future<bool> moderatorStand(String roomId, String targetUserId) async {
    final res = await _supabaseClient.rpc('moderator_stand', params: {
      'p_room_id': roomId,
      'p_target_user_id': targetUserId,
      'p_moderator_id': _currentUserId(),
    });
    return res == true;
  }

  @override
  Future<void> touchPresence(String roomId) async {
    if (_isLocalRoom(roomId)) return;
    try {
      await _supabaseClient.rpc('touch_presence', params: {
        'p_room_id': roomId,
        'p_user_id': _currentUserId(),
      });
    } catch (e) {
      debugPrint('touch_presence falló (no bloqueante): $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamSeatRequests(String roomId) {
    if (_isLocalRoom(roomId)) {
      return const Stream.empty();
    }
    return _supabaseClient
        .from('seat_requests')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .map((list) {
          return list
              .where((item) => item['status'] == 'pending')
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        });
  }

  String _currentUserId() => _supabaseClient.auth.currentUser?.id ?? 'guest_user';

  int _firstFreeLocalSeat(String roomId) {
    final occupied = _localParticipants[roomId]!
        .where((p) => p['speaker_slot'] != null && p['presence_state'] == 'seated')
        .map((p) => p['speaker_slot'] as int)
        .toSet();
    for (var i = 1; i <= 8; i++) {
      if (!occupied.contains(i)) return i;
    }
    throw const ChatRoomException('table_full', 'La mesa está llena.');
  }

  String _seatError(String code) {
    switch (code) {
      case 'seat_taken':
        return 'La silla ya está ocupada.';
      case 'table_full':
        return 'Las 8 sillas están ocupadas. Solicita una silla para entrar a la cola.';
      case 'seated_elsewhere':
        return 'Ya estás sentado en otra mesa.';
      case 'not_in_room':
        return 'No formas parte de esta mesa.';
      case 'invalid_seat':
        return 'Silla inválida (1-8).';
      default:
        return 'No se pudo completar la acción.';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentRooms(int limit) async {
    try {
      final rooms = await _supabaseClient
          .from('chat_rooms')
          .select('*')
          .eq('is_active', true)
          .isFilter('deleted_at', null)
          .order('updated_at', ascending: false)
          .limit(limit);

      return rooms.map((room) {
        return {
          'id': room['id'] as String,
          'title': room['title'] as String? ?? 'Mesa de Gremio',
          'category': room['category'] as String? ?? 'general',
          'room_type': room['room_type'] as String? ?? 'discussion',
          'description': room['description'] as String? ?? '',
          'moderator_id': room['moderator_id'] as String?,
          'moderator_type': room['moderator_type'] as String? ?? 'ai',
          'has_ai_moderator': room['has_ai_moderator'] as bool? ?? false,
          'mana_cost_per_min': (room['mana_cost_per_min'] as num?)?.toInt() ?? 0,
          'max_speakers': (room['max_speakers'] as num?)?.toInt() ?? 6,
          'created_at': room['created_at'] as String?,
          'updated_at': room['updated_at'] as String?,
        };
      }).toList();
    } catch (e) {
      debugPrint('getRecentRooms error: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGuildAnnouncements() async {
    try {
      final data = await _supabaseClient
          .from('guild_announcements')
          .select('id, message, icon_emoji, sort_order')
          .eq('is_active', true)
          .order('sort_order');
      return (data as List)
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    } catch (e) {
      debugPrint('getGuildAnnouncements error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getParticipantProfiles(List<String> userIds) async {
    final map = <String, Map<String, dynamic>>{};
    if (userIds.isEmpty) return map;
    try {
      final res = await _supabaseClient
          .from('users')
          .select('id, display_name, avatar_url')
          .inFilter('id', userIds);
      for (final u in res) {
        map[u['id'] as String] = {
          'display_name': u['display_name'] as String? ?? '',
          'avatar_url': u['avatar_url'] as String? ?? 'warrior',
        };
      }
    } catch (_) {}
    return map;
  }

  @override
  Future<List<Map<String, dynamic>>> getOnlineGuildUsers({int limit = 8}) async {
    try {
      // 1. Mesas activas (no borradas).
      final rooms = await _supabaseClient
          .from('chat_rooms')
          .select('id')
          .eq('is_active', true)
          .isFilter('deleted_at', null);

      if (rooms.isEmpty) return [];

      // 2. Participantes presentes en esas mesas (una mesa por sesión ⇒ cada
      //    usuario aparece como máximo una vez; se deduplica por si hay legacy).
      // Issue #42: solo participantes con heartbeat reciente (<120 s) para no
      // mostrar como "conectados" a usuarios que cerraron la app.
      final roomIds = rooms.map((r) => r['id'] as String).toList();
      final cutoff = DateTime.now()
          .toUtc()
          .subtract(const Duration(seconds: 120))
          .toIso8601String();
      final participants = await _supabaseClient
          .from('chat_room_participants')
          .select('user_id')
          .inFilter('room_id', roomIds)
          .gte('last_seen_at', cutoff);

      final userIds = participants
          .map((p) => p['user_id'] as String?)
          .whereType<String>()
          .toSet()
          .take(limit)
          .toList();

      if (userIds.isEmpty) return [];

      // 3. Perfiles de esos usuarios.
      final profiles = await getParticipantProfiles(userIds);
      return userIds.map((id) {
        final profile = profiles[id] ?? const <String, dynamic>{};
        return {
          'user_id': id,
          'display_name': profile['display_name'] as String? ?? '',
          'avatar_url': profile['avatar_url'] as String? ?? 'warrior',
        };
      }).toList();
    } catch (e) {
      // Re-lanzar para que el provider conserven el último valor (SWR) en vez
      // de vaciar el roster por un error transitorio.
      debugPrint('getOnlineGuildUsers error: $e');
      rethrow;
    }
  }
}
