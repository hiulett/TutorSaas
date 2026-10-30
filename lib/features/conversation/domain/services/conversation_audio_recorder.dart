import 'package:record/record.dart';

/// P-34f (#198): frontera entre el notifier y el plugin `record`.
///
/// Existe solo para poder probar la interacción (inicio, fin y descarte de una
/// grabación) sin el plugin nativo. Los parámetros de audio son los mismos que
/// usa el pipeline desde P-34: AAC-LC, 128 kbps, 16 kHz mono.
abstract class ConversationAudioRecorder {
  Future<bool> hasPermission();

  Future<void> start(String path);

  /// Detiene la grabación y devuelve la ruta del archivo (o `null`).
  Future<String?> stop();

  Future<void> dispose();
}

class RecordAudioRecorder implements ConversationAudioRecorder {
  RecordAudioRecorder([Record? recorder]) : _recorder = recorder ?? Record();

  final Record _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start(String path) {
    return _recorder.start(
      path: path,
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      samplingRate: 16000,
    );
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> dispose() => _recorder.dispose();
}
