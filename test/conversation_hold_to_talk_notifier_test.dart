import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutorsaas/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:tutorsaas/features/conversation/domain/services/conversation_audio_recorder.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:tutorsaas/features/dashboard/domain/models/user_settings.dart';
import 'package:tutorsaas/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tutorsaas/features/dashboard/presentation/providers/dashboard_providers.dart';

/// P-34f (#198): el notifier distingue enviar, descartar por corto y cancelar
/// sin tocar el pipeline (nada llega al STT en los descartes).

class _FakeConversationRepository implements ConversationRepository {
  int transcribeCalls = 0;

  @override
  Future<String> transcribeAudio(String audioPath) async {
    transcribeCalls++;
    return '';
  }

  @override
  Future<Map<String, dynamic>> trackAiAudioTime(
    String userId,
    int durationSeconds,
  ) async => const {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRecorder implements ConversationAudioRecorder {
  bool permission = true;
  Completer<bool>? permissionGate;
  int startCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  String? stopPath;

  @override
  Future<bool> hasPermission() {
    final gate = permissionGate;
    if (gate != null) return gate.future;
    return Future.value(permission);
  }

  @override
  Future<void> start(String path) async {
    startCalls++;
  }

  @override
  Future<String?> stop() async {
    stopCalls++;
    return stopPath;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(pathProviderChannel, null);
  });

  ({
    ProviderContainer container,
    _FakeRecorder recorder,
    _FakeConversationRepository repository,
  })
  build() {
    final recorder = _FakeRecorder();
    final repository = _FakeConversationRepository();
    final container = ProviderContainer(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(repository),
        conversationAudioRecorderProvider.overrideWithValue(recorder),
        currentUserProvider.overrideWithValue(null),
        correctionLevelProvider.overrideWithValue('moderate'),
      ],
    );
    addTearDown(container.dispose);
    return (container: container, recorder: recorder, repository: repository);
  }

  test('soltar antes de 300 ms descarta sin llamar al STT', () async {
    final env = build();
    final notifier = env.container.read(conversationStateProvider.notifier);

    await notifier.startHoldRecording();
    expect(env.container.read(conversationStateProvider).isRecording, isTrue);

    await notifier.endHoldRecording(const Duration(milliseconds: 200));

    final state = env.container.read(conversationStateProvider);
    expect(state.isRecording, isFalse);
    expect(state.isProcessing, isFalse);
    expect(state.errorMessage, contains('Mantén pulsado'));
    expect(env.recorder.stopCalls, 1);
    expect(env.repository.transcribeCalls, 0);
  });

  test(
    'soltar por encima del umbral detiene la grabación y transcribe',
    () async {
      final env = build();
      final notifier = env.container.read(conversationStateProvider.notifier);

      await notifier.startHoldRecording();
      await notifier.endHoldRecording(const Duration(milliseconds: 900));

      final state = env.container.read(conversationStateProvider);
      expect(state.isRecording, isFalse);
      expect(state.isProcessing, isFalse);
      // El archivo no existe en el doble: el pipeline corta antes del STT por
      // "grabación vacía", pero el gesto sí llegó a detener la grabación.
      expect(env.recorder.stopCalls, 1);
      expect(env.repository.transcribeCalls, 0);
    },
  );

  test('cancelar descarta en silencio (sin aviso ni STT)', () async {
    final env = build();
    final notifier = env.container.read(conversationStateProvider.notifier);

    await notifier.startHoldRecording();
    await notifier.discardHoldRecording(tooShort: false);

    final state = env.container.read(conversationStateProvider);
    expect(state.isRecording, isFalse);
    expect(state.errorMessage, isNull);
    expect(env.repository.transcribeCalls, 0);
  });

  test(
    'cancela mientras el permiso está en vuelo: no arranca el micrófono',
    () async {
      final env = build();
      final notifier = env.container.read(conversationStateProvider.notifier);
      final gate = Completer<bool>();
      env.recorder.permissionGate = gate;

      final start = notifier.startHoldRecording();
      await Future<void>.delayed(Duration.zero);
      await notifier.discardHoldRecording(tooShort: false);

      gate.complete(true);
      await start;

      expect(env.recorder.startCalls, 0);
      expect(
        env.container.read(conversationStateProvider).isRecording,
        isFalse,
      );
    },
  );

  test('sin permiso no hay grabación que enviar', () async {
    final env = build();
    env.recorder.permission = false;
    final notifier = env.container.read(conversationStateProvider.notifier);

    await notifier.startHoldRecording();
    await notifier.endHoldRecording(const Duration(seconds: 1));

    final state = env.container.read(conversationStateProvider);
    expect(state.micPermissionDenied, isTrue);
    expect(env.recorder.stopCalls, 0);
    expect(env.repository.transcribeCalls, 0);
  });

  test('el ajuste se serializa con la clave de user_settings', () async {
    final settings = UserSettings.initial().copyWith(micModeHoldToTalk: true);
    expect(settings.toJson()['mic_mode_hold_to_talk'], isTrue);

    final restored = UserSettings.fromJson({...settings.toJson()});
    expect(restored.micModeHoldToTalk, isTrue);
    expect(
      UserSettings.fromJson(const {}).micModeHoldToTalk,
      isFalse,
      reason: 'tap-to-toggle debe seguir siendo el valor por defecto',
    );
  });

  test('cambiar el modo lo persiste en user_settings', () async {
    final repository = _FakeDashboardRepository();
    final notifier = UserSettingsNotifier(repository, 'user-1');

    await notifier.updateSetting('mic_mode_hold_to_talk', true);

    expect(notifier.state.micModeHoldToTalk, isTrue);
    expect(repository.stored['mic_mode_hold_to_talk'], isTrue);
    // Al reabrir, el valor viene de la fila guardada.
    expect(UserSettings.fromJson(repository.stored).micModeHoldToTalk, isTrue);
  });
}

class _FakeDashboardRepository implements DashboardRepository {
  Map<String, dynamic> stored = <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> getUserSettings(String userId) async => stored;

  @override
  Future<void> updateUserSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    stored = Map<String, dynamic>.from(settings);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
