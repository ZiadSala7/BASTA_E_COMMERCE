part of '../enhanced_checkout_page.dart';

class _PaymentMethodSection extends StatelessWidget {
  final List<Map<String, dynamic>> methods;
  final int selected;
  final ValueChanged<int> onChanged;

  const _PaymentMethodSection({
    required this.methods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: methods.asMap().entries.map((entry) {
        final index = entry.key;
        final method = entry.value;
        final isSelected = index == selected;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableTile(
            onTap: () => onChanged(index),
            selected: isSelected,
            leading: Icon(
              method['icon'],
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
            ),
            title: method['label'],
            subtitle: method['description'],
          ),
        );
      }).toList(),
    );
  }
}
