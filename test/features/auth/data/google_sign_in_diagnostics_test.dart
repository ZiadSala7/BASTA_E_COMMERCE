import 'package:busta/features/auth/data/datasources/google_sign_in_diagnostics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  group('GoogleSignInDiagnostics', () {
    test('recognizes Credential Manager account reauthentication failures', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: '[16] Account reauth failed.',
      );

      expect(GoogleSignInDiagnostics.isAccountReauthFailure(error), isTrue);
      expect(
        GoogleSignInDiagnostics.messageFor(error),
        contains('signing SHA-1 in Firebase'),
      );
    });

    test('does not classify ordinary user cancellation as reauth failure', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: 'User canceled the sign-in flow.',
      );

      expect(GoogleSignInDiagnostics.isAccountReauthFailure(error), isFalse);
      expect(
        GoogleSignInDiagnostics.messageFor(error),
        'Google sign-in was cancelled.',
      );
    });

    test('preserves useful errors from other Google sign-in failures', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
        description: 'serverClientId is missing.',
      );

      expect(GoogleSignInDiagnostics.isAccountReauthFailure(error), isFalse);
      expect(
        GoogleSignInDiagnostics.messageFor(error),
        'serverClientId is missing.',
      );
    });
  });
}
