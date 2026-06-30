part of '../offers_page.dart';

class _OfferCoupon {
  final String storeName;
  final String category;
  final String amount;
  final String description;
  final String expiry;
  final String code;
  final Color accent;
  final Color buttonColor;
  final IconData icon;
  final List<Color> imageColors;

  const _OfferCoupon({
    required this.storeName,
    required this.category,
    required this.amount,
    required this.description,
    required this.expiry,
    required this.code,
    required this.accent,
    required this.buttonColor,
    required this.icon,
    required this.imageColors,
  });
}

List<_OfferCoupon> _demoOffers(AppLocalizations l10n) {
  final isArabic = l10n.isArabic;
  final dinar20 = isArabic ? '20 دينار' : '20 JOD';
  final dinar49 = isArabic ? '49 دينار' : '49 JOD';
  final discount20 = isArabic ? 'خصم كوبون' : 'Coupon discount';
  final freeShipping = isArabic ? 'شحن مجاني' : 'Free shipping';
  final expiresGreen = isArabic ? 'ينتهي في 8 أيام' : 'Ends in 8 days';
  final expiresGold = isArabic ? 'ينتهي في 24 أيام' : 'Ends in 24 days';
  final beauty = l10n.pick(
    ar: 'مستحضرات التجميل والعناية',
    en: 'Beauty and care',
  );
  final electronics = l10n.pick(ar: 'إلكترونيات', en: 'Electronics');

  return [
    _OfferCoupon(
      storeName: l10n.storeDukhanOud,
      category: l10n.fashion,
      amount: dinar20,
      description: discount20,
      expiry: expiresGreen,
      code: 'm3453',
      accent: const Color(0xFF6B6046),
      buttonColor: const Color(0xFF24D84E),
      icon: Icons.spa_rounded,
      imageColors: const [Color(0xFF082A52), Color(0xFF1B6BA6)],
    ),
    _OfferCoupon(
      storeName: l10n.storeSindibad,
      category: beauty,
      amount: dinar49,
      description: freeShipping,
      expiry: expiresGold,
      code: isArabic ? 'مفعل' : 'Active',
      accent: const Color(0xFFD98A2B),
      buttonColor: const Color(0xFFFFC85C),
      icon: Icons.storefront_rounded,
      imageColors: const [Color(0xFF101B48), Color(0xFF4976D8)],
    ),
    _OfferCoupon(
      storeName: l10n.storeSindibad,
      category: beauty,
      amount: dinar49,
      description: freeShipping,
      expiry: expiresGold,
      code: 'm6B',
      accent: const Color(0xFFD98A2B),
      buttonColor: const Color(0xFFFFC85C),
      icon: Icons.shopping_bag_rounded,
      imageColors: const [Color(0xFF1A2D62), Color(0xFF123E8A)],
    ),
    _OfferCoupon(
      storeName: l10n.storeDukhanOud,
      category: electronics,
      amount: dinar20,
      description: discount20,
      expiry: expiresGreen,
      code: 'np8567',
      accent: const Color(0xFF6B6046),
      buttonColor: const Color(0xFF24D84E),
      icon: Icons.card_giftcard_rounded,
      imageColors: const [Color(0xFF0B3D5E), Color(0xFF26A2C8)],
    ),
    _OfferCoupon(
      storeName: l10n.storeDukhanOud,
      category: l10n.fashion,
      amount: dinar20,
      description: discount20,
      expiry: expiresGreen,
      code: 'ouD20',
      accent: const Color(0xFF6B6046),
      buttonColor: const Color(0xFF24D84E),
      icon: Icons.local_mall_rounded,
      imageColors: const [Color(0xFF12304B), Color(0xFF59B7D4)],
    ),
    _OfferCoupon(
      storeName: l10n.storeSindibad,
      category: electronics,
      amount: dinar49,
      description: freeShipping,
      expiry: expiresGold,
      code: isArabic ? 'مفعل' : 'Active',
      accent: const Color(0xFFD98A2B),
      buttonColor: const Color(0xFFFFC85C),
      icon: Icons.workspace_premium_rounded,
      imageColors: const [Color(0xFF07143A), Color(0xFF385AD1)],
    ),
  ];
}
