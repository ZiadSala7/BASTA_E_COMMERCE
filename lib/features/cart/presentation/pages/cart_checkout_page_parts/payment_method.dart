part of '../cart_checkout_page.dart';

class _PaymentMethod {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> brands;

  const _PaymentMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.brands = const [],
  });
}
