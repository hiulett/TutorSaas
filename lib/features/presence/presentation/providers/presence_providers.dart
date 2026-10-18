import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/router.dart';
import '../../data/repositories/presence_repository_impl.dart';
import '../../domain/repositories/presence_repository.dart';

final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PresenceRepositoryImpl(client);
});

/// Controlador de presencia: reporta la sección actual (ruta go_router) con
/// heartbeat cada ~30s y en los cambios de navegación / ciclo de vida.
/// autoDispose: solo vive mientras haya sesión (se lee desde app.dart de forma
/// condicional); al cerrar sesión se desecha y cancela el heartbeat.
final presenceControllerProvider =
    StateNotifierProvider.autoDispose<PresenceController, String?>((ref) {
  final repo = ref.watch(presenceRepositoryProvider);
  final router = ref.watch(routerProvider);
  return PresenceController(repo: repo, router: router, ref: ref);
});

class PresenceController extends StateNotifier<String?> {
  PresenceController({
    required PresenceRepository repo,
    required GoRouter router,
    required Ref ref,
  })  : _repo = repo,
        _router = router,
        _ref = ref,
        super(null) {
    _router.routeInformationProvider.addListener(_onRouteChanged);
    _lifecycle = AppLifecycleListener(onResume: _onResume, onPause: _onPause);
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) => _reportCurrent());
    _onRouteChanged();
  }

  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const String _backgroundSection = 'background';

  /// Sección por ruta go_router. Cualquier ruta no listada → 'app'.
  static const Map<String, String> _sectionByPath = {
    '/': 'welcome',
    '/splash': 'splash',
    '/onboarding': 'onboarding',
    '/oracle-test': 'oracle',
    '/home': 'dashboard',
    '/voice-room': 'voice_room',
    '/conversation': 'conversation',
    '/summary': 'summary',
    '/paywall': 'paywall',
    '/settings': 'settings',
    '/profile-edit': 'profile_edit',
    '/chat-rooms': 'guild_hall',
    '/shop': 'shop',
    '/inventory': 'inventory',
    '/dungeon-guardian': 'dungeon_guardian',
    '/disruption': 'disruption',
  };

  final PresenceRepository _repo;
  final GoRouter _router;
  final Ref _ref;

  Timer? _heartbeat;
  AppLifecycleListener? _lifecycle;

  String _sectionFromPath(String path) => _sectionByPath[path] ?? 'app';

  void _onRouteChanged() {
    final path = _router.routeInformationProvider.value.uri.path;
    final section = _sectionFromPath(path);
    state = section;
    _report(section);
  }

  void _onResume() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) => _reportCurrent());
    _onRouteChanged();
  }

  void _onPause() {
    _heartbeat?.cancel();
    _report(_backgroundSection);
  }

  bool get _hasSession => _ref.read(currentUserProvider) != null;

  void _reportCurrent() {
    final section = state;
    if (section != null) _report(section);
  }

  void _report(String section) {
    if (!_hasSession) return;
    unawaited(_repo.reportPresence(section));
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    _lifecycle?.dispose();
    _router.routeInformationProvider.removeListener(_onRouteChanged);
    super.dispose();
  }
}
