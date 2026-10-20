part of '../cart_checkout_page.dart';

class _PaymentTile extends StatelessWidget {
  final _PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryFor(context).withOpacity(0.12)
              : colorScheme.surfaceContainerHighest.withOpacity(0.38),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primaryFor(context)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              color: selected
                  ? AppColors.primaryFor(context)
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    method.subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (method.brands.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final brand in method.brands)
                          _PaymentBrandMark(brand: brand),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? AppColors.primaryFor(context)
                  : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBrandMark extends StatelessWidget {
  const _PaymentBrandMark({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    final isVisa = brand == 'VISA';

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9DCE3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: isVisa
            ? Text(
                brand,
                style: const TextStyle(
                  color: Color(0xFF1A1F71),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 12,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: _BrandCircle(color: Color(0xFFE31B23)),
                        ),
                        Positioned(
                          left: 7,
                          child: _BrandCircle(color: Color(0xFFF79E1B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    brand,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BrandCircle extends StatelessWidget {
  const _BrandCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
