import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/screens/mini_conversation_screen.dart';
import '../features/conversation/presentation/screens/conversation_screen.dart';
import '../features/dashboard/presentation/screens/session_summary_screen.dart';
import '../features/subscription/presentation/screens/paywall_screen.dart';
import '../features/dashboard/presentation/screens/profile_edit_screen.dart';
import '../features/chat_rooms/presentation/screens/voice_room_screen.dart';
import '../features/chat_rooms/presentation/screens/chat_rooms_screen.dart';
import '../features/missions/presentation/screens/missions_screen.dart';
import '../features/economy/presentation/screens/shop_screen.dart';
import '../features/economy/presentation/screens/inventory_screen.dart';
import '../features/economy/presentation/screens/dungeon_guardian_screen.dart';
import '../features/corrections/presentation/screens/my_errors_screen.dart';
import '../features/weekly_report/presentation/screens/weekly_report_screen.dart';
import '../features/listening/presentation/screens/listening_quiz_screen.dart';
import '../features/boss_exam/domain/models/boss_exam_outcome.dart';
import '../features/boss_exam/presentation/screens/boss_exam_result_screen.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import 'splash_screen.dart';
import 'navigation_resolver.dart';

/// Router con redirección centralizada (Navigation-Audit · F3).
///
/// El `redirect` resuelve la pantalla inicial con el Navigation Decision Engine.
/// `refreshListenable` re-evalúa el redirect cuando cambia la sesión o el modo dev.
/// Rutas de la app. P-18 (#103): expuestas para el test de contrato de
/// navegacion; el router solo las consume.
final List<RouteBase> appRoutes = <RouteBase>[
  GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => const OnboardingScreen(),
  ),

  // P-25 (#110): prueba de valor de 60 s tras crear el personaje.
  GoRoute(
    path: '/mini-conversation',
    builder: (context, state) => const MiniConversationScreen(),
  ),
  GoRoute(
    path: '/oracle-test',
    builder: (context, state) {
      final target = state.uri.queryParameters['target'];
      final native = state.uri.queryParameters['native'];
      // mode=promotion&level=B1 → reto del Oráculo (no baja de nivel).
      // P-31 (#116): `mode=promotion` activa la capa de jefe de mazmorra
      // (barra de vida y pantalla de resultado); el nivel lo decide el servidor.
      final promotion = state.uri.queryParameters['mode'] == 'promotion';
      return ConversationScreen(
        oracleMode: true,
        oraclePromotion: promotion,
        oracleTargetLanguage: target ?? 'en',
        oracleNativeLanguage: native,
      );
    },
  ),
  GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
  GoRoute(
    path: '/voice-room',
    builder: (context, state) {
      final roomId = state.uri.queryParameters['roomId'] ?? '';
      return VoiceRoomScreen(roomId: roomId);
    },
  ),
  GoRoute(
    path: '/conversation',
    builder: (context, state) {
      final scenarioId = state.uri.queryParameters['scenarioId'];
      final scenarioTitle = state.uri.queryParameters['scenarioTitle'];
      return ConversationScreen(
        scenarioId: scenarioId,
        scenarioTitle: scenarioTitle,
      );
    },
  ),
  GoRoute(
    path: '/summary',
    builder: (context, state) => const SessionSummaryScreen(),
  ),
  GoRoute(path: '/paywall', builder: (context, state) => const PaywallScreen()),
  GoRoute(
    path: '/profile-edit',
    builder: (context, state) => const ProfileEditScreen(),
  ),
  GoRoute(
    path: '/chat-rooms',
    builder: (context, state) => const ChatRoomsScreen(),
  ),
  GoRoute(path: '/shop', builder: (context, state) => const ShopScreen()),
  GoRoute(
    path: '/inventory',
    builder: (context, state) => const InventoryScreen(),
  ),
  GoRoute(
    path: '/dungeon-guardian',
    builder: (context, state) => const DungeonGuardianScreen(),
  ),

  // P-31 (#116): resultado del jefe de mazmorra (rúbrica, motivo, reintento).
  GoRoute(
    path: '/boss-result',
    builder: (context, state) {
      final extra = state.extra;
      return BossExamResultScreen(
        outcome: extra is BossExamOutcome ? extra : null,
      );
    },
  ),

  // P-29: historial de errores agrupado por tipo y recurrencia.
  GoRoute(
    path: '/my-errors',
    builder: (context, state) => const MyErrorsScreen(),
  ),

  // P-43 (#128): informe semanal calculado en servidor.
  GoRoute(
    path: '/weekly-report',
    builder: (context, state) => const WeeklyReportScreen(),
  ),

  // P-30 (#115): comprensión auditiva (audio por TTS, corrección en servidor).
  GoRoute(
    path: '/listening',
    builder: (context, state) {
      final exerciseId = state.uri.queryParameters['exerciseId'] ?? '';
      return ListeningQuizScreen(exerciseId: exerciseId);
    },
  ),
  GoRoute(
    path: '/missions',
    builder: (context, state) => const MissionsScreen(),
  ),
];

final routerProvider = Provider<GoRouter>((ref) {
  // Listenable que notifica al router cuando cambia la sesión o el modo dev.
  final navigationRefresh = _NavigationRefreshListenable(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: navigationRefresh,
    redirect: (context, state) async {
      final path = state.uri.path;
      // Rutas internas de onboarding que no deben ser redirigidas.
      final internalRoutes = const {'/splash', '/onboarding', '/oracle-test'};
      if (internalRoutes.contains(path)) return null;

      final user = ref.read(currentUserProvider);
      final devMode = ref.read(devModeProvider);
      final destination = await NavigationDecisionEngine.resolve(
        user: user,
        devMode: devMode,
      );
      final target = navDestinationToPath(destination);

      if (target == '/home') {
        // Con perfil → dashboard. La raíz '/' (welcome tras splash) se lleva al
        // dashboard, pero el resto de secciones navegan libremente.
        if (path == '/') return '/home';
        return null;
      }

      // Sin sesión (welcome) o sin perfil (onboarding): forzar el destino.
      if (path == target) return null;
      return target;
    },
    routes: appRoutes,
  );
});

/// Listenable que re-evalúa el redirect cuando cambia la sesión o el modo dev.
class _NavigationRefreshListenable extends ChangeNotifier {
  _NavigationRefreshListenable(this._ref) {
    // Observa cambios de sesión (currentUserProvider).
    _subscription = _ref.listen(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    // Observa cambios del modo desarrollador.
    _devSub = _ref.listen(devModeProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
  late final ProviderSubscription _subscription;
  late final ProviderSubscription _devSub;

  @override
  void dispose() {
    _subscription.close();
    _devSub.close();
    super.dispose();
  }
}
