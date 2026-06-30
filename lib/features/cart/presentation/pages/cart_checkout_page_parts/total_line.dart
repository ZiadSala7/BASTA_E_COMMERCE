part of '../cart_checkout_page.dart';

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _TotalLine({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: isBold
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontSize: isBold ? 14.5 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: isBold ? AppColors.primary : colorScheme.onSurface,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
