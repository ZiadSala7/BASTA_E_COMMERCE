import '../../domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.code,
    super.storeId,
    super.userId,
    required super.type,
    required super.value,
    super.minOrderAmount,
    super.maxDiscountAmount,
    super.usageLimit,
    super.usedCount,
    super.isActive,
    super.startDate,
    super.endDate,
    super.createdAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: _asString(json['id'] ?? json['_id']),
      code: _asString(json['code']),
      storeId: _nullableString(json['storeId'] ?? json['store_id']),
      userId: _nullableString(json['userId'] ?? json['user_id']),
      type: _asString(json['type'] ?? 'FIXED').toUpperCase(),
      value: _asString(json['value'] ?? '0'),
      minOrderAmount: _nullableString(
        json['minOrderAmount'] ?? json['min_order_amount'],
      ),
      maxDiscountAmount: _nullableString(
        json['maxDiscountAmount'] ?? json['max_discount_amount'],
      ),
      usageLimit: _asInt(json['usageLimit'] ?? json['usage_limit'], 1),
      usedCount: _asInt(json['usedCount'] ?? json['used_count'], 0),
      isActive: _asBool(json['isActive'] ?? json['is_active'], true),
      startDate: _parseDate(json['startDate'] ?? json['start_date']),
      endDate: _parseDate(json['endDate'] ?? json['end_date']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  factory CouponModel.fromEntity(CouponEntity entity) {
    return CouponModel(
      id: entity.id,
      code: entity.code,
      storeId: entity.storeId,
      userId: entity.userId,
      type: entity.type,
      value: entity.value,
      minOrderAmount: entity.minOrderAmount,
      maxDiscountAmount: entity.maxDiscountAmount,
      usageLimit: entity.usageLimit,
      usedCount: entity.usedCount,
      isActive: entity.isActive,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      if (storeId != null) 'storeId': storeId,
      if (userId != null) 'userId': userId,
      'type': type,
      'value': value,
      if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
      if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  static int _asInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static bool _asBool(dynamic value, [bool defaultValue = true]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    final str = value.toString().toLowerCase().trim();
    if (str == 'true' || str == '1') return true;
    if (str == 'false' || str == '0') return false;
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
