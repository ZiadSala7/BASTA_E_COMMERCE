class SavedAddressModel {
  const SavedAddressModel({
    required this.id,
    required this.label,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  final double latitude;
  final double longitude;
  final bool isDefault;

  String get street => streetAddress;

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      streetAddress: json['streetAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  Map<String, dynamic> toCheckoutPayload() {
    return {
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
    };
  }

  SavedAddressModel copyWith({
    String? id,
    String? label,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return SavedAddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get summary => [
    streetAddress,
    city,
    state,
    country,
  ].where((part) => part.trim().isNotEmpty).join(', ');

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
