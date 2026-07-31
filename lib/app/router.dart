import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/conversation/presentation/screens/conversation_screen.dart';
import '../features/dashboard/presentation/screens/session_summary_screen.dart';
import '../features/subscription/presentation/screens/paywall_screen.dart';
import '../features/dashboard/presentation/screens/profile_screen.dart';
import '../features/dashboard/presentation/screens/settings_screen.dart';
import '../features/dashboard/presentation/screens/profile_edit_screen.dart';
import '../features/chat_rooms/presentation/screens/voice_room_screen.dart';
import '../features/chat_rooms/presentation/screens/chat_rooms_screen.dart';
import '../features/conversation/presentation/screens/level_exam_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const DashboardScreen(),
    ),
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
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile-edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/chat-rooms',
      builder: (context, state) => const ChatRoomsScreen(),
    ),
    GoRoute(
      path: '/level-exam',
      builder: (context, state) {
        final levelCode = state.uri.queryParameters['level'] ?? 'A1';
        return LevelExamScreen(levelCode: levelCode);
      },
    ),
  ],
);
