part of '../cart_checkout_page.dart';

class _PhoneInputPanel extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneInputPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return _Panel(
      title: l10n.pick(
        ar: 'رقم الهاتف للتوصيل (مطلوب)',
        en: 'Delivery Mobile Number (Required)',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: l10n.pick(
                ar: 'أدخل رقم الهاتف مثل 07XXXXXXXX',
                en: 'Enter mobile number e.g. 07XXXXXXXX',
              ),
              hintStyle: GoogleFonts.cairo(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.pick(
              ar: 'سيتواصل معك مندوب التوصيل عبر هذا الرقم لتسليم الطلب.',
              en: 'The courier will contact you on this number to deliver your order.',
            ),
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
