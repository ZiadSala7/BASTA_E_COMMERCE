import '../../domain/entities/product_review_entity.dart';

class ProductReviewModel extends ProductReviewEntity {
  const ProductReviewModel({
    required super.id,
    required super.authorName,
    required super.rating,
    required super.comment,
    super.createdAt,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user'] ?? json['customer'] ?? json['author']);
    final name =
        json['authorName'] ??
        json['userName'] ??
        json['name'] ??
        user['name'] ??
        user['fullName'];

    return ProductReviewModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      authorName: _text(name, fallback: 'Customer'),
      rating: _number(json['rating'] ?? json['stars'], fallback: 0),
      comment: _text(
        json['comment'] ?? json['review'] ?? json['message'] ?? json['body'],
      ),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      ),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static String _text(Object? value, {String fallback = ''}) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static double _number(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? fallback;
  }
}
