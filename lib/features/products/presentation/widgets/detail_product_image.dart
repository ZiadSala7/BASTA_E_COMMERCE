import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;

  const DetailProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    if (url.isEmpty) {
      return const _ImagePlaceholder(
        icon: Icons.inventory_2_outlined,
        label: 'No image available',
      );
    }

    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(
        icon: Icons.broken_image_outlined,
        label: 'Image unavailable',
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              value: progress.expectedTotalBytes == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
            ),
          ),
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ImagePlaceholder({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 58, color: colorScheme.outline),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
