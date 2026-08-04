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
      _localParticipants[roomId] = [
        {
          'id': 'system_ai_participant',
          'room_id': roomId,
          'user_id': 'system_ai',
          'is_speaker': true,
          'speaker_slot': 1,
          'joined_at': DateTime.now().toIso8601String(),
        }
      ];
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
          .select('room_id, is_speaker')
          .inFilter('room_id', roomIds);

      final Map<String, int> speakerCount = {};
      final Map<String, int> listenerCount = {};
      for (final p in countsData) {
        final rid = p['room_id'] as String;
        if (p['is_speaker'] == true) {
          speakerCount[rid] = (speakerCount[rid] ?? 0) + 1;
        } else {
          listenerCount[rid] = (listenerCount[rid] ?? 0) + 1;
        }
      }

      final maxSpeakers = rooms.map((r) => (r['max_speakers'] as num?)?.toInt() ?? 6).toList();

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
          'speakers_count': speakerCount[rid] ?? 0,
          'listeners_count': listenerCount[rid] ?? 0,
          'created_at': room['created_at'] as String?,
        };
      });
    } catch (_) {
      return [];
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

    await _supabaseClient
        .from('chat_room_participants')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', userId);

    final remaining = await _supabaseClient
        .from('chat_room_participants')
        .select('id')
        .eq('room_id', roomId);

    if (remaining.isEmpty) {
      await _supabaseClient
          .from('chat_rooms')
          .delete()
          .eq('id', roomId);
    }
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
}
