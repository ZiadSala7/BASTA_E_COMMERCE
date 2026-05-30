import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';

class SelectionSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final int selectedItem;
  final ValueChanged<int> onItemSelected;
  final bool isColor;

  const SelectionSection({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.isColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == selectedItem;

            return GestureDetector(
              onTap: () => onItemSelected(index),
              child: Container(
                width: isColor ? 40 : null,
                height: isColor ? 40 : 36,
                padding: isColor
                    ? null
                    : const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isColor ? _colorFromHex(item) : null,
                  borderRadius: BorderRadius.circular(isColor ? 20 : 18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: !isColor
                    ? Center(
                        child: Text(
                          item,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black,
                          ),
                        ),
                      )
                    : isSelected
                    ? const Center(
                        child: Icon(Icons.check, color: Colors.white, size: 18),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _colorFromHex(String value) {
    final hex = value.replaceFirst('#', '');
    final normalized = hex.length == 6 ? 'FF$hex' : hex;
    final colorValue = int.tryParse(normalized, radix: 16);

    return Color(colorValue ?? 0xFF9CA3AF);
  }
}
