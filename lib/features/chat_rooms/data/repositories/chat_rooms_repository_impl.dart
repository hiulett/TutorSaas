import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/chat_rooms_repository.dart';

class ChatRoomsRepositoryImpl implements ChatRoomsRepository {
  final SupabaseClient _supabaseClient;

  ChatRoomsRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Map<String, dynamic>>> getRooms() async {
    final List<Map<String, dynamic>> defaultGuildTables = [
      {
        'id': 'guild_table_1',
        'title': '🍻 Mesa 1: La Taberna del Aprendiz (A1-A2)',
        'category': 'general',
        'moderator_id': 'system_ai',
        'speakers_count': 3,
        'listeners_count': 12,
        'has_ai_moderator': false,
        'mana_cost_per_min': 0,
        'description': 'Conversación libre y relajada para cazadores novatos (100% Gratuita).',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'guild_table_2',
        'title': '🛡️ Mesa 2: La Mesa Redonda de Tácticas (B1-B2)',
        'category': 'business',
        'moderator_id': 'system_ai',
        'speakers_count': 5,
        'listeners_count': 24,
        'has_ai_moderator': true,
        'mana_cost_per_min': 1,
        'description': 'Debates de estrategia, negocios y fluidez intermedia con Moderador IA.',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'guild_table_3',
        'title': '🐉 Mesa 3: El Consejo Supremo de Altos Cazadores (C1-C2)',
        'category': 'technology',
        'moderator_id': 'system_ai',
        'speakers_count': 4,
        'listeners_count': 45,
        'has_ai_moderator': true,
        'mana_cost_per_min': 1,
        'description': 'Elocuencia avanzada y discursos de nivel maestro con Moderador IA.',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'guild_table_4',
        'title': '🧙‍♂️ Mesa 4: La Cámara del Archimago (Pronunciación & Exámenes)',
        'category': 'art',
        'moderator_id': 'system_ai',
        'speakers_count': 2,
        'listeners_count': 18,
        'has_ai_moderator': true,
        'mana_cost_per_min': 1,
        'description': 'Clínica de fonética y preparación técnica para las pruebas de piso.',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    try {
      final rooms = await _supabaseClient
          .from('chat_rooms')
          .select('*, moderator:users(id, email)');

      final List<Map<String, dynamic>> customRooms = [];
      for (final room in rooms) {
        final roomId = room['id'] as String;

        final participants = await _supabaseClient
            .from('chat_room_participants')
            .select('id, is_speaker')
            .eq('room_id', roomId);

        final speakersCount = participants.where((p) => p['is_speaker'] == true).length;
        final listenersCount = participants.where((p) => p['is_speaker'] == false).length;

        customRooms.add({
          'id': roomId,
          'title': room['title'] as String? ?? 'Sala de Gremio',
          'category': room['category'] as String? ?? 'general',
          'moderator_id': room['moderator_id'] as String?,
          'speakers_count': speakersCount,
          'listeners_count': listenersCount,
          'has_ai_moderator': true,
          'mana_cost_per_min': 1,
          'created_at': room['created_at'] as String?,
        });
      }
      return [...defaultGuildTables, ...customRooms];
    } catch (_) {
      return defaultGuildTables;
    }
  }

  @override
  Future<Map<String, dynamic>> createRoom({
    required String title,
    required String category,
    required String moderatorId,
  }) async {
    final room = await _supabaseClient.from('chat_rooms').insert({
      'title': title,
      'category': category,
      'moderator_id': moderatorId,
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
    await _supabaseClient.from('chat_room_messages').insert({
      'room_id': roomId,
      'user_id': userId,
      'message_text': messageText,
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> streamParticipants(String roomId) {
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
    return _supabaseClient
        .from('chat_room_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((list) {
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        });
  }
}
