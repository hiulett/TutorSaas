/// Error tipado de una llamada de IA (chat o transcripcion).
///
/// Se usa para que un fallo del proveedor nunca se convierta en un mensaje
/// del tutor: el notifier lo captura, lo pinta como evento de sistema y ofrece
/// reintentar.
enum AiErrorKind { network, quota, auth, provider, timeout, stt, unknown }

class AiStreamException implements Exception {
  final AiErrorKind kind;
  final String message;
  final int retries;

  const AiStreamException(this.kind, this.message, {this.retries = 0});

  String get code => kind.name;

  @override
  String toString() => 'AiStreamException($code, retries=$retries): $message';
}
