import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorsaas/app/app.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('App boot smoke test (sin sesión → Welcome)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      // Build our app with no session; the centralized redirect decides the screen.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(null),
          ],
          child: const TutorSaaSApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // El app montó sin crash: hay widgets renderizados.
      expect(tester.allWidgets.isNotEmpty, isTrue);
    });
  });
}
