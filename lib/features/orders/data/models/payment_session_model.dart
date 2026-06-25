import '../../domain/entities/payment_session_entity.dart';

class PaymentSessionModel extends PaymentSessionEntity {
  const PaymentSessionModel({
    required super.sessionId,
    required super.successIndicator,
    required super.version,
  });

  factory PaymentSessionModel.fromJson(Map<String, dynamic> json) {
    return PaymentSessionModel(
      sessionId: (json['sessionId'] ?? json['id'] ?? '').toString(),
      successIndicator: (json['successIndicator'] ?? '').toString(),
      version: (json['version'] ?? '').toString(),
    );
  }
}
