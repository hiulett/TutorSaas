import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/cache/cached_future_controller.dart';
import '../../../../core/cache/json_disk_cache.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/chat_rooms_repository_impl.dart';
import '../../domain/repositories/chat_rooms_repository.dart';

export '../../domain/repositories/chat_rooms_repository.dart' show ChatRoomException;

final chatRoomsRepositoryProvider = Provider<ChatRoomsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ChatRoomsRepositoryImpl(client);
});

/// Salas del gremio (cambian raramente). Cache TTL 10 min + disco.
final chatRoomsListProvider = StateNotifierProvider<CachedFutureController<List<Map<String, dynamic>>>, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return CachedFutureController<List<Map<String, dynamic>>>(
    ttl: const Duration(minutes: 10),
    userIdGetter: () => 'guild',
    diskLoader: () => JsonDiskCache.readList('cache_chat_rooms'),
    diskWriter: (data) => JsonDiskCache.writeList('cache_chat_rooms', data),
    fetcher: () => ref.read(chatRoomsRepositoryProvider).getRooms(),
  );
});

/// Anuncios del gremio persistidos en BD (`guild_announcements`).
/// Cache TTL 10 min + disco.
final guildAnnouncementsProvider = StateNotifierProvider<CachedFutureController<List<Map<String, dynamic>>>, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return CachedFutureController<List<Map<String, dynamic>>>(
    ttl: const Duration(minutes: 10),
    userIdGetter: () => 'guild',
    diskLoader: () => JsonDiskCache.readList('cache_guild_announcements'),
    diskWriter: (data) => JsonDiskCache.writeList('cache_guild_announcements', data),
    fetcher: () => ref.read(chatRoomsRepositoryProvider).getGuildAnnouncements(),
  );
});

/// Cazadores actualmente conectados al gremio (presencia REAL en mesas
/// activas). Reemplaza el roster hardcodeado del encabezado del Guild Hall.
final guildOnlineUsersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(chatRoomsRepositoryProvider).getOnlineGuildUsers();
});

final chatRoomParticipantsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, roomId) {
  return ref.read(chatRoomsRepositoryProvider).streamParticipants(roomId);
});

final chatRoomMessagesProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, roomId) {
  return ref.read(chatRoomsRepositoryProvider).streamMessages(roomId);
});

/// Cola FIFO de petición de silla de la mesa (stream realtime).
final chatRoomSeatRequestsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, roomId) {
  return ref.read(chatRoomsRepositoryProvider).streamSeatRequests(roomId);
});

/// Perfiles (id → {display_name, avatar_url}) de los participantes conectados
/// a una sala. Usado para mostrar nombre/avatar reales en el voice room.
final participantProfilesProvider = FutureProvider.autoDispose.family<Map<String, Map<String, dynamic>>, String>((ref, roomId) async {
  final participants = ref.watch(chatRoomParticipantsProvider(roomId)).value ?? [];
  final userIds = participants
      .map((p) => p['user_id'] as String?)
      .whereType<String>()
      .where((u) => u.isNotEmpty)
      .toSet()
      .toList();
  if (userIds.isEmpty) return const {};
  return ref.read(chatRoomsRepositoryProvider).getParticipantProfiles(userIds);
});
