part of '../firebase_social_auth_datasource.dart';

class FirebaseSocialAuthDataSourceImpl implements FirebaseSocialAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseSocialAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<String> getGoogleFirebaseIdToken() async {
    try {
      _debugLog('Google sign-in request started');
      final googleUser = await _authenticateGoogleUser();
      final googleIdToken = googleUser.authentication.idToken;

      _debugLog('Google sign-in response', {
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'id': googleUser.id,
        'googleIdToken': _tokenPreview(googleIdToken),
      });

      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw Exception('Google sign-in did not return an ID token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      _debugLog('Firebase credential request started');
      final firebaseUserCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await firebaseUserCredential.user?.getIdToken();

      _debugLog('Firebase credential response', {
        'uid': firebaseUserCredential.user?.uid,
        'email': firebaseUserCredential.user?.email,
        'displayName': firebaseUserCredential.user?.displayName,
        'firebaseIdToken': _tokenPreview(firebaseIdToken),
      });

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Firebase did not return an ID token.');
      }

      return firebaseIdToken;
    } on GoogleSignInException catch (error) {
      _debugLog('Google sign-in error', {
        'code': error.code.toString(),
        'description': error.description,
      });
      throw Exception(_messageFromGoogleSignIn(error));
    } on FirebaseAuthException catch (error) {
      _debugLog('Firebase auth error', {
        'code': error.code,
        'message': error.message,
      });
      throw Exception(error.message ?? 'Firebase authentication failed.');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  Future<GoogleSignInAccount> _authenticateGoogleUser() async {
    try {
      return await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (!_isAccountReauthFailure(error)) rethrow;

      _debugLog('Google account reauth failed; signing out and retrying');
      await _clearCachedGoogleSession(disconnect: false);

      try {
        return await _googleSignIn.authenticate();
      } on GoogleSignInException catch (retryError) {
        if (!_isAccountReauthFailure(retryError)) rethrow;

        _debugLog(
          'Google account reauth failed again; disconnecting and retrying',
          {
            'code': retryError.code.toString(),
            'description': retryError.description,
          },
        );
        await _clearCachedGoogleSession(disconnect: true);
        return _googleSignIn.authenticate();
      }
    }
  }

  Future<void> _clearCachedGoogleSession({required bool disconnect}) async {
    await _firebaseAuth.signOut();

    try {
      if (disconnect) {
        await _googleSignIn.disconnect();
      } else {
        await _googleSignIn.signOut();
      }
    } on GoogleSignInException catch (error) {
      _debugLog('Google disconnect failed; falling back to signOut', {
        'code': error.code.toString(),
        'description': error.description,
      });
      await _googleSignIn.signOut();
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  bool _isAccountReauthFailure(GoogleSignInException error) {
    final description = (error.description ?? '').toLowerCase();
    return error.code == GoogleSignInExceptionCode.canceled &&
        description.contains('account reauth failed');
  }

  String _messageFromGoogleSignIn(GoogleSignInException error) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      return 'Google sign-in was cancelled.';
    }

    final description = error.description;
    if (description != null && description.isNotEmpty) {
      return description;
    }

    return 'Google sign-in failed.';
  }

  void _debugLog(String message, [Map<String, Object?>? data]) {
    if (!kDebugMode) return;
    debugPrint('[GoogleSignIn] $message');
    if (data != null) {
      debugPrint('[GoogleSignIn] $data');
    }
  }

  String _tokenPreview(String? token) {
    if (token == null || token.isEmpty) return '<empty>';
    final start = token.length <= 12 ? token : token.substring(0, 12);
    final end = token.length <= 8 ? '' : token.substring(token.length - 8);
    return '$start...$end (${token.length} chars)';
  }
}
