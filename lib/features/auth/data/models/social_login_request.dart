class SocialLoginRequest {
  final String idToken;
  final String? role;
  final String? fcmToken;

  const SocialLoginRequest({required this.idToken, this.role, this.fcmToken});

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      if (role != null && role!.isNotEmpty) 'role': role,
      if (fcmToken != null && fcmToken!.isNotEmpty) 'fcmToken': fcmToken,
    };
  }
}
