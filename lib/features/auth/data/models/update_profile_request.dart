class UpdateProfileRequest {
  final String? name;
  final String? phone;
  final String? email;

  const UpdateProfileRequest({this.name, this.phone, this.email});

  Map<String, dynamic> toJson() {
    return {
      if (name != null && name!.trim().isNotEmpty) 'name': name,
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone,
      if (email != null && email!.trim().isNotEmpty) 'email': email,
    };
  }
}
