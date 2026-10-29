import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/auth/domain/google_sign_in_error.dart';

void main() {
  test('ApiException 10 se reconoce como firma no registrada', () {
    final error = PlatformException(
      code: 'sign_in_failed',
      message:
          'com.google.android.gms.common.api.ApiException: 10: DEVELOPER_ERROR',
    );

    expect(isGoogleSignInConfigError(error), isTrue);
  });

  test('otros fallos de Google no se confunden', () {
    expect(
      isGoogleSignInConfigError(
        PlatformException(code: 'sign_in_failed', message: 'network'),
      ),
      isFalse,
    );
    expect(
      isGoogleSignInConfigError(PlatformException(code: 'other')),
      isFalse,
    );
    expect(isGoogleSignInConfigError(StateError('x')), isFalse);
  });
}
