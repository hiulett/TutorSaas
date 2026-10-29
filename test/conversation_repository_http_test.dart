import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;
import 'package:tutorsaas/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:tutorsaas/features/conversation/domain/models/ai_stream_exception.dart';

/// Contrato HTTP del repositorio de conversación (P-18 / #103).
///
/// No toca la red: un `HttpClientAdapter` falso devuelve 429, 500, timeout y
/// un SSE partido en varios frames. Lo que se comprueba es la política de
/// reintentos y el mapeo de error a [AiErrorKind] (lo que ve el alumno).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StubAdapter adapter;
  late ConversationRepositoryImpl repository;

  setUp(() {
    adapter = _StubAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    repository = ConversationRepositoryImpl(dio, _UnusedSupabaseClient());
  });

  test('429 se reintenta 3 veces y se reporta como cuota', () async {
    adapter.handler = (options) async => _jsonError(429);

    final error = await _capture(
      repository.getTutorResponseStream(const []).drain<void>(),
    );

    expect(adapter.calls, 3);
    expect(error, isA<AiStreamException>());
    final ai = error as AiStreamException;
    expect(ai.kind, AiErrorKind.quota);
    expect(ai.retries, 2, reason: 'reintentos, no intentos');
    expect(ai.message, contains('límite de uso'));
  });

  test('500 se reintenta y se reporta como fallo del proveedor', () async {
    adapter.handler = (options) async => _jsonError(500);

    final error = await _capture(
      repository.getTutorResponseStream(const []).drain<void>(),
      timeout: const Duration(seconds: 20),
    );

    expect(adapter.calls, 3);
    final ai = error as AiStreamException;
    expect(ai.kind, AiErrorKind.provider);
    expect(ai.message, contains('no está disponible'));
  });

  test('un timeout de recepción se reintenta y se explica', () async {
    adapter.handler = (options) async => throw DioException(
      requestOptions: options,
      type: DioExceptionType.receiveTimeout,
    );

    final error = await _capture(
      repository.getTutorResponseStream(const []).drain<void>(),
      timeout: const Duration(seconds: 20),
    );

    expect(adapter.calls, 3);
    final ai = error as AiStreamException;
    expect(ai.kind, AiErrorKind.timeout);
    expect(ai.message, contains('tardó demasiado'));
  });

  test('402 (sin maná) no se reintenta y dice qué hacer', () async {
    adapter.handler = (options) async => _jsonError(402);

    final error = await _capture(
      repository.getTutorResponseStream(const []).drain<void>(),
    );

    expect(
      adapter.calls,
      1,
      reason: 'sin maná no se quema la cuota reintentando',
    );
    final ai = error as AiStreamException;
    expect(ai.kind, AiErrorKind.quota);
    expect(ai.message, contains('maná'));
  });

  test('un SSE partido en frames se reensambla sin perder texto', () async {
    adapter.handler = (options) async => ResponseBody(
      Stream<Uint8List>.fromIterable([
        // El JSON llega partido en dos frames de red.
        utf8.encode('data: {"choices":[{"delta":{"content":"Hel'),
        utf8.encode('lo"}}]}\n'),
        utf8.encode('data: {"choices":[{"delta":{"content":" there"}}]}\n'),
        utf8.encode('data: [DONE]\n'),
      ]),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    final chunks = await repository.getTutorResponseStream(const []).toList();

    expect(adapter.calls, 1);
    expect(chunks, ['Hello', ' there']);
  });
}

/// Ejecuta [future] y devuelve el error lanzado (falla si no lanza).
Future<Object> _capture(
  Future<void> future, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  try {
    await future.timeout(timeout);
  } catch (e) {
    return e;
  }
  fail('se esperaba una AiStreamException');
}

ResponseBody _jsonError(int status) => ResponseBody.fromString(
  jsonEncode({'error': 'stub', 'status': status}),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// Adaptador de Dio que devuelve lo que diga `handler` y cuenta llamadas.
class _StubAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options) handler = (_) async =>
      ResponseBody.fromString('{}', 200);
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls++;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

/// El repositorio tolera un cliente sin sesión (`_authToken` devuelve '').
class _UnusedSupabaseClient extends Fake implements SupabaseClient {
  final _auth = _NoSessionAuth();

  @override
  GoTrueClient get auth => _auth;
}

/// Sesión vacía: `currentUser` null y `currentSession` null.
class _NoSessionAuth extends Fake implements GoTrueClient {
  @override
  User? get currentUser => null;

  @override
  Session? get currentSession => null;
}
