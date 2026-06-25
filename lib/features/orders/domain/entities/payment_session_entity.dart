class PaymentSessionEntity {
  final String sessionId;
  final String successIndicator;
  final String version;

  const PaymentSessionEntity({
    required this.sessionId,
    required this.successIndicator,
    required this.version,
  });

  bool get isValid => sessionId.trim().isNotEmpty;
}
