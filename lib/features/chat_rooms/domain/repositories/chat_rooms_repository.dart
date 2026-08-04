abstract class ChatRoomsRepository {
  Future<List<Map<String, dynamic>>> getRooms();
  Future<Map<String, dynamic>> createRoom({
    required String title,
    required String category,
    required String moderatorId,
    String? roomType,
  });
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required bool isSpeaker,
    int? speakerSlot,
  });
  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  });
  Future<void> claimSpeakerSlot({
    required String roomId,
    required String userId,
    required int speakerSlot,
  });
  Future<void> sendChatMessage({
    required String roomId,
    required String userId,
    required String messageText,
  });
  Stream<List<Map<String, dynamic>>> streamParticipants(String roomId);
  Stream<List<Map<String, dynamic>>> streamMessages(String roomId);
  Future<int> countActiveSpeakers(String roomId);
  Future<void> joinRoomAsCurrentUser(String roomId);
  Future<void> leaveRoomAsCurrentUser(String roomId);
  Future<List<Map<String, dynamic>>> getRecentRooms(int limit);
}
