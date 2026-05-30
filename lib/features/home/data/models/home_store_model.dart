import 'dart:convert';

import '../../domain/entities/home_store_entity.dart';

class HomeStoreModel extends HomeStoreEntity {
  const HomeStoreModel({
    required super.id,
    required super.vendorId,
    required super.name,
    required super.slug,
    required super.description,
    required super.status,
    required super.createdAt,
  });

  factory HomeStoreModel.fromJson(Map<String, dynamic> json) {
    return HomeStoreModel(
      id: (json['id'] ?? '').toString(),
      vendorId: (json['vendorId'] ?? '').toString(),
      name: _textFromJson(json['name']),
      slug: (json['slug'] ?? '').toString(),
      description: _textFromJson(json['description']),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }

  static String _textFromJson(Object? value) {
    final text = (value ?? '').toString();
    if (!text.contains('\u00d8') && !text.contains('\u00d9')) return text;

    try {
      return utf8.decode(latin1.encode(text));
    } on FormatException {
      return text;
    }
  }
}
