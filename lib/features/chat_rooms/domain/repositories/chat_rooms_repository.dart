/// Error semántico de una operación de mesa del gremio (silla ocupada, mesa
/// llena, usuario sentado en otra mesa, sin permiso de moderador, etc).
class ChatRoomException implements Exception {
  final String code;
  final String message;

  const ChatRoomException(this.code, this.message);

  @override
  String toString() => message;
}

abstract class ChatRoomsRepository {  Future<List<Map<String, dynamic>>> getRooms();
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

  // ── Mesas del gremio: presencia de pie/sentado (RPC server-side) ────────────

  /// Entra a la mesa en estado "de pie" (escucha + chat, sin publicar audio).
  /// Abandona automáticamente cualquier otra mesa activa (una mesa por sesión).
  Future<void> joinTable(String roomId);

  /// Se sienta en una silla concreta (1-8). Lanza [ChatRoomException] si la
  /// silla está ocupada, la mesa está llena o el usuario está en otra mesa.
  Future<void> sitDown(String roomId, int seat);

  /// Pide silla: si hay una libre se sienta, si no entra a la cola FIFO.
  /// Devuelve 'seated' o 'queued'.
  Future<String> requestSeat(String roomId);

  /// Se levanta: libera la silla y vuelve a "de pie". Auto-asienta al primero
  /// de la cola en la silla liberada (server-side).
  Future<void> standUp(String roomId);

  /// Moderador: pone "de pie" a un participante (expulsión suave). Devuelve
  /// true si el moderador tiene permiso sobre la mesa.
  Future<bool> moderatorStand(String roomId, String targetUserId);

  /// Heartbeat de presencia (llamar cada ~30s mientras se está en la mesa).
  Future<void> touchPresence(String roomId);

  /// Cola FIFO de petición de silla de la mesa (stream realtime).
  Stream<List<Map<String, dynamic>>> streamSeatRequests(String roomId);

  /// Perfiles (id → {display_name, avatar_url}) de los usuarios dados.
  Future<Map<String, Map<String, dynamic>>> getParticipantProfiles(List<String> userIds);

  /// Cazadores actualmente conectados al gremio (presencia real en mesas
  /// activas). Devuelve hasta [limit] usuarios con {user_id, display_name,
  /// avatar_url}. Presencia real = filas en chat_room_participants de mesas
  /// activas (una mesa por sesión ⇒ cada usuario aparece una vez).
  Future<List<Map<String, dynamic>>> getOnlineGuildUsers({int limit = 8});

  /// Anuncios activos del gremio, persistidos en BD (`guild_announcements`).
  Future<List<Map<String, dynamic>>> getGuildAnnouncements();
}
