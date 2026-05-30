class AuthMessageResponse {
  final String message;

  const AuthMessageResponse({required this.message});

  factory AuthMessageResponse.fromJson(Map<String, dynamic> json) {
    final directMessage = json['message']?.toString();
    if (directMessage != null && directMessage.isNotEmpty) {
      return AuthMessageResponse(message: directMessage);
    }

    final data = json['data'];
    if (data is Map) {
      final nestedMessage = data['message']?.toString();
      if (nestedMessage != null && nestedMessage.isNotEmpty) {
        return AuthMessageResponse(message: nestedMessage);
      }
    }

    return const AuthMessageResponse(
      message: 'Request completed successfully.',
    );
  }
}
