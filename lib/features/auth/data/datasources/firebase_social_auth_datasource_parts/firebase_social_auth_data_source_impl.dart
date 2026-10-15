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
      GoogleSignInDiagnostics.log('Credential Manager authentication started');
      final googleUser = await _authenticateGoogleUser();
      final googleIdToken = googleUser.authentication.idToken;

      GoogleSignInDiagnostics.log('Google account returned', {
        'hasIdToken': googleIdToken?.isNotEmpty ?? false,
      });

      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw Exception('Google sign-in did not return an ID token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      GoogleSignInDiagnostics.log('Firebase credential sign-in started');
      final firebaseUserCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      GoogleSignInDiagnostics.log('Firebase credential sign-in succeeded', {
        'hasUser': firebaseUserCredential.user != null,
      });
      GoogleSignInDiagnostics.log('Firebase ID token request started');
      final firebaseIdToken = await firebaseUserCredential.user?.getIdToken();

      GoogleSignInDiagnostics.log('Firebase ID token response', {
        'hasIdToken': firebaseIdToken?.isNotEmpty ?? false,
      });

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Firebase did not return an ID token.');
      }

      return firebaseIdToken;
    } on GoogleSignInException catch (error) {
      GoogleSignInDiagnostics.log('Credential Manager authentication failed', {
        'code': error.code.toString(),
        'description': error.description,
        'details': error.details,
        'accountReauthFailure': GoogleSignInDiagnostics.isAccountReauthFailure(
          error,
        ),
      });
      throw Exception(GoogleSignInDiagnostics.messageFor(error));
    } on FirebaseAuthException catch (error) {
      GoogleSignInDiagnostics.log('Firebase authentication failed', {
        'code': error.code,
        'message': error.message,
      });
      throw Exception(error.message ?? 'Firebase authentication failed.');
    } catch (error, stackTrace) {
      GoogleSignInDiagnostics.log('Google sign-in flow failed', {
        'errorType': error.runtimeType.toString(),
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    GoogleSignInDiagnostics.log('Signing out from Firebase and Google');
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  Future<GoogleSignInAccount> _authenticateGoogleUser() async {
    GoogleSignInDiagnostics.log('Opening Google account chooser');
    return _googleSignIn.authenticate();
  }
}
