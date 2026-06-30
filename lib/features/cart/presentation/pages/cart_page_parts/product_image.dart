part of '../cart_page.dart';

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.item});

  final _CartProduct item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 124,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: item.darkImage
            ? const Color(0xFF17171D)
            : item.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.accent.withOpacity(0.18)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.darkImage
                  ? Image.asset(Assets.imagesCart, fit: BoxFit.contain)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [item.accent.withOpacity(0.12), Colors.white],
                        ),
                      ),
                      child: item.imageUrl.isEmpty
                          ? Image.asset(Assets.imagesCart, fit: BoxFit.contain)
                          : Image.network(
                              item.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    Assets.imagesCart,
                                    fit: BoxFit.contain,
                                  ),
                            ),
                    ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: item.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.badge,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
