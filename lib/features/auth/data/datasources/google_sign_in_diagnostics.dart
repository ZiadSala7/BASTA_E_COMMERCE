import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract final class GoogleSignInDiagnostics {
  static bool isAccountReauthFailure(GoogleSignInException error) {
    final description = (error.description ?? '').toLowerCase();
    return error.code == GoogleSignInExceptionCode.canceled &&
        description.contains('account reauth failed');
  }

  static String messageFor(GoogleSignInException error) {
    if (isAccountReauthFailure(error)) {
      return 'Google could not authenticate this app. Verify the Android '
          'package name and signing SHA-1 in Firebase, then try again.';
    }

    if (error.code == GoogleSignInExceptionCode.canceled) {
      return 'Google sign-in was cancelled.';
    }

    final description = error.description;
    if (description != null && description.isNotEmpty) {
      return description;
    }

    return 'Google sign-in failed.';
  }

  static void log(String message, [Map<String, Object?>? data]) {
    if (!kDebugMode) return;
    debugPrint('[GoogleSignIn] $message');
    if (data != null) {
      debugPrint('[GoogleSignIn] $data');
    }
  }

  static Future<void> logInstalledAndroidSigningInfo() async {
    try {
      final signingInfo = await const MethodChannel(
        'busta/debug_signing',
      ).invokeMapMethod<String, Object?>('getSigningInfo');
      if (signingInfo == null) {
        log('Installed Android signing information was unavailable');
        return;
      }

      log('Installed Android app signing certificate', signingInfo);
    } on PlatformException catch (error) {
      log('Could not read installed Android signing certificate', {
        'code': error.code,
        'message': error.message,
      });
    } catch (error, stackTrace) {
      log('Unexpected error reading Android signing certificate', {
        'errorType': error.runtimeType.toString(),
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
    }
  }
}
