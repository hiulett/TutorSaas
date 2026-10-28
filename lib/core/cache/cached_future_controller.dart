import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';

/// Cache de datos por-usuario con TTL + stale-while-revalidate (SWR) y
/// persistencia opcional en disco (cold start sin queries).
///
/// - Lectura fresca (dentro de [ttl]) → devuelve el valor cacheado sin red.
/// - Caducado → devuelve el cacheado AL INSTANTE y refresca en segundo plano,
///   tanto al leerse como vía un timer periódico (para datos que expiran por
///   tiempo, p. ej. el estado diario o el maná). El UI nunca espera por una
///   petición cuando ya hay dato.
/// - Sin cache en memoria pero con [diskLoader] → muestra el dato persistido
///   al instante y refresca en background (cero queries en el cold start).
/// - Sin cache → carga bloqueante con estado `loading`.
/// - Cambio de usuario ([userIdGetter]) → descarta la cache automáticamente
///   para no mezclar datos entre cuentas.
/// - El timer reintenta también errores transitorios de la carga inicial.
class CachedFutureController<T> extends StateNotifier<AsyncValue<T>> {
  CachedFutureController({
    required Future<T> Function() fetcher,
    required String? Function() userIdGetter,
    this.ttl,
    this.timerInterval = const Duration(seconds: 60),
    Future<T?> Function()? diskLoader,
    Future<void> Function(T data)? diskWriter,
  })  : _fetcher = fetcher,
        _userIdGetter = userIdGetter,
        _diskLoader = diskLoader,
        _diskWriter = diskWriter,
        super(AsyncValue.loading()) {
    _startTimer();
    unawaited(load());
  }

  final Future<T> Function() _fetcher;
  final String? Function() _userIdGetter;
  final Duration? ttl;
  final Duration timerInterval;
  final Future<T?> Function()? _diskLoader;
  final Future<void> Function(T data)? _diskWriter;

  DateTime? _lastFetched;
  String? _cachedUserId;
  bool _refreshing = false;
  Timer? _timer;

  Future<void> load() async {
    final userId = _userIdGetter();
    final userChanged = userId != _cachedUserId;

    if (userChanged) {
      // Cuenta distinta (o logout): descarta cache para no filtrar datos.
      _lastFetched = null;
      _cachedUserId = userId;
      if (state.hasValue) {
        state = AsyncValue.loading();
      }
    }

    // Sin dato en memoria → intenta la cache persistida (lectura instantánea).
    if (!state.hasValue && _diskLoader != null) {
      try {
        final disk = await _diskLoader();
        if (disk != null) {
          state = AsyncValue.data(disk);
        }
      } catch (e, st) {
        ErrorTracker.logSilent('lib/core/cache/cached_future_controller.dart:68', e, stackTrace: st);
      }
    }

    final isFresh = _isFresh();
    final hasValue = state.hasValue;

    if (hasValue && isFresh && !userChanged) return; // fresco: no hacer nada.

    if (hasValue) {
      // Caducado (o recién leído de disco): SWR — mantener el valor visible y
      // refrescar en background.
      unawaited(_refresh());
      return;
    }

    // Sin cache (o usuario cambió): carga bloqueante.
    if (!state.isLoading) {
      state = AsyncValue.loading();
    }
    await _refresh();
  }

  bool _isFresh() {
    if (_lastFetched == null || ttl == null) return false;
    return DateTime.now().difference(_lastFetched!) < ttl!;
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final data = await _fetcher();
      _lastFetched = DateTime.now();
      _cachedUserId = _userIdGetter();
      if (mounted) {
        state = AsyncValue.data(data);
      }
      if (_diskWriter != null) {
        unawaited(_diskWriter(data));
      }
    } catch (e, st) {
      // Si ya hay dato (memoria/disco) se conserva: un refresh fallido no debe
      // vaciar la pantalla. Solo se marca error cuando no hay nada que mostrar.
      if (mounted && !state.hasValue) {
        state = AsyncError(e, st);
      }
    } finally {
      _refreshing = false;
    }
  }

  /// Invalida la cache (equivale a `ref.invalidate`): el siguiente read vuelve
  /// a consultar. Si hay valor previo lo mantiene hasta el refresco (SWR).
  void invalidate() {
    _lastFetched = null;
    unawaited(load());
  }

  void _startTimer() {
    _timer = Timer.periodic(timerInterval, (_) {
      if (state.isLoading) return; // carga inicial en curso
      if (_isFresh()) return;
      unawaited(_refresh());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
