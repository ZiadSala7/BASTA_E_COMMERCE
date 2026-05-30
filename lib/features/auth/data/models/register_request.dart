class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String role;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    this.role = 'CUSTOMER',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (phone.trim().isNotEmpty) 'phone': phone,
      'role': role,
    };
  }
}
