import 'package:equatable/equatable.dart';

class CouponEntity extends Equatable {
  final String id;
  final String code;
  final String? storeId;
  final String? userId;
  final String type; // 'FIXED' or 'PERCENTAGE'
  final String value;
  final String? minOrderAmount;
  final String? maxDiscountAmount;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  const CouponEntity({
    required this.id,
    required this.code,
    this.storeId,
    this.userId,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.usageLimit = 1,
    this.usedCount = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  /// A coupon is valid if active, not reached usage limit, and not expired.
  bool get isValid {
    final now = DateTime.now();
    final notExpired = endDate == null || endDate!.isAfter(now);
    return isActive && usedCount < usageLimit && notExpired;
  }

  bool get isFixed => type.toUpperCase() == 'FIXED';
  bool get isPercentage => type.toUpperCase() == 'PERCENTAGE';
  bool get isExpired => endDate != null && endDate!.isBefore(DateTime.now());
  bool get isUsed => usedCount >= usageLimit;

  double get numericValue => double.tryParse(value) ?? 0.0;
  double get numericMinOrder =>
      minOrderAmount != null ? (double.tryParse(minOrderAmount!) ?? 0.0) : 0.0;

  @override
  List<Object?> get props => [
    id,
    code,
    storeId,
    userId,
    type,
    value,
    minOrderAmount,
    maxDiscountAmount,
    usageLimit,
    usedCount,
    isActive,
    startDate,
    endDate,
    createdAt,
  ];
}
