class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String role;
  final String? couponCode;
  final String? referralCode;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    this.role = 'CUSTOMER',
    this.couponCode,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (phone.trim().isNotEmpty) 'phone': phone,
      'role': role,
      if (couponCode != null && couponCode!.trim().isNotEmpty)
        'coupon_code': couponCode!.trim(),
      if (referralCode != null && referralCode!.trim().isNotEmpty)
        'referralCode': referralCode!.trim().toUpperCase(),
    };
  }
}
