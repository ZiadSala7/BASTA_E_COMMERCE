import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_detail_args.dart';

class ProductVariantSelector extends StatelessWidget {
  final ProductDetailArgs product;
  final ProductVariantEntity? selectedVariant;
  final String? selectedSize;
  final String? selectedColor;
  final ValueChanged<String> onSizeSelected;
  final ValueChanged<String> onColorSelected;

  const ProductVariantSelector({
    super.key,
    required this.product,
    required this.selectedVariant,
    required this.selectedSize,
    required this.selectedColor,
    required this.onSizeSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = product.availableSizes;
    final colors = product.availableColors;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (sizes.isEmpty && colors.isEmpty && product.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Color Selection
        if (colors.isNotEmpty) ...[
          Row(
            children: [
              Text(
                l10n.pick(ar: 'اللون', en: 'Color'),
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              if (selectedColor != null && selectedColor!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  selectedColor!,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: colors.map((colorValue) {
              final isSelected = selectedColor == colorValue;
              final parsedColor = _tryParseHex(colorValue);

              if (parsedColor != null) {
                return InkWell(
                  onTap: () => onColorSelected(colorValue),
                  borderRadius: BorderRadius.circular(99),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: parsedColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: _contrastColor(parsedColor),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }

              // Text color chip fallback
              return ChoiceChip(
                label: Text(
                  colorValue,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                onSelected: (_) => onColorSelected(colorValue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : colorScheme.outlineVariant,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
        ],

        // Size / Weight / Variant Options
        if (sizes.isNotEmpty) ...[
          Row(
            children: [
              Text(
                l10n.pick(ar: 'الحجم / الوزن', en: 'Size / Weight'),
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              if (selectedSize != null && selectedSize!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  selectedSize!,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: sizes.map((sizeValue) {
              final isSelected = selectedSize == sizeValue;
              final matchingVariant = product.findVariant(
                size: sizeValue,
                color: selectedColor,
              );
              final isOutOfStock =
                  matchingVariant != null && matchingVariant.isOutOfStock;

              return InkWell(
                onTap: isOutOfStock ? null : () => onSizeSelected(sizeValue),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isOutOfStock
                          ? colorScheme.outlineVariant.withValues(alpha: 0.35)
                          : colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sizeValue,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isOutOfStock
                              ? colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                )
                              : isSelected
                              ? AppColors.primary
                              : colorScheme.onSurface,
                          decoration: isOutOfStock
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (matchingVariant != null &&
                          matchingVariant.price > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.formatPrice(matchingVariant.price),
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    ),
  );
  }

  Color? _tryParseHex(String value) {
    var hex = value.trim();
    if (!hex.startsWith('#') && hex.length != 6 && hex.length != 8) {
      return null;
    }
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final intVal = int.tryParse(hex, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }

  Color _contrastColor(Color color) {
    // Calculate luminance
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
