part of '../enhanced_checkout_page.dart';

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isHighlighted;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isHighlighted ? AppColors.primary : null,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}
