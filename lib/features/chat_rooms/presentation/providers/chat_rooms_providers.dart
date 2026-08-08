import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/chat_rooms_repository_impl.dart';
import '../../domain/repositories/chat_rooms_repository.dart';

final chatRoomsRepositoryProvider = Provider<ChatRoomsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ChatRoomsRepositoryImpl(client);
});

final chatRoomsListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(chatRoomsRepositoryProvider).getRooms();
});

/// Anuncios del gremio persistidos en BD (`guild_announcements`).
final guildAnnouncementsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(chatRoomsRepositoryProvider).getGuildAnnouncements();
});

final chatRoomParticipantsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, roomId) {
  return ref.read(chatRoomsRepositoryProvider).streamParticipants(roomId);
});

final chatRoomMessagesProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, roomId) {
  return ref.read(chatRoomsRepositoryProvider).streamMessages(roomId);
});
