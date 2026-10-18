/// Repositorio de presencia: reporta en qué sección de la app está el usuario
/// (heartbeat). La escritura pasa por el RPC SECURITY DEFINER `report_presence`,
/// que usa `auth.uid()` server-side.
abstract class PresenceRepository {
  /// Reporta la sección actual del usuario conectado. No bloqueante: ante
  /// cualquier error no lanza y solo hace debugPrint.
  Future<void> reportPresence(String section);
}
