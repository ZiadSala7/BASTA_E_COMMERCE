part of '../cart_checkout_page.dart';

class _ProductThumb extends StatelessWidget {
  final String imageUrl;

  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? Image.asset(Assets.imagesCart, fit: BoxFit.contain)
          : Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(Assets.imagesCart, fit: BoxFit.contain),
            ),
    );
  }
}
