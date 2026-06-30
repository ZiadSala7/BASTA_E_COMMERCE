part of '../home_featured_products_section.dart';

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final HomeProductsSectionVariant variant;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionTap,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: variant == HomeProductsSectionVariant.specialOffer
          ? _SpecialOfferHeading(
              title: title,
              subtitle: subtitle,
              actionLabel: actionLabel,
              onActionTap: onActionTap,
            )
          : SectionHeader(
              title: title,
              actionLabel: actionLabel,
              onActionTap: onActionTap,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
    );
  }
}
