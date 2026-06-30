part of '../firebase_social_auth_datasource.dart';

abstract class FirebaseSocialAuthDataSource {
  Future<String> getGoogleFirebaseIdToken();
  Future<void> signOut();
}
