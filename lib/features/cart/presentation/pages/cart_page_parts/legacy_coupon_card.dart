part of '../cart_page.dart';

class LegacyCouponCard extends StatelessWidget {
  const LegacyCouponCard({
    super.key,
    required this.controller,
    required this.hasDiscount,
    required this.isLoading,
    required this.onApply,
  });

  final TextEditingController controller;
  final bool hasDiscount;
  final bool isLoading;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasDiscount
              ? AppColors.accentGreen.withOpacity(0.35)
              : colorScheme.outlineVariant.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasDiscount
                  ? AppColors.accentGreen.withOpacity(0.12)
                  : AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              hasDiscount
                  ? Icons.check_circle_outline_rounded
                  : Icons.local_offer_outlined,
              color: hasDiscount ? AppColors.accentGreen : AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: l10n.coupon,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                  0.35,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.pick(ar: 'تم تطبيق الكوبون', en: 'Coupon applied'),
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
              },
              child: Text(l10n.applyCoupon),
            ),
          ),
        ],
      ),
    );
  }
}
