import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorsaas/app/app.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame wrapped in ProviderScope.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
        ],
        child: const TutorSaaSApp(),
      ),
    );

    // Verify that our welcome text is present.
    expect(find.text('Aprende hablando'), findsOneWidget);
  });
}
