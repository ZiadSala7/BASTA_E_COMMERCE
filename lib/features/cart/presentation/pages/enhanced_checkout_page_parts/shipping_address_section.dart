part of '../enhanced_checkout_page.dart';

class _ShippingAddressSection extends StatelessWidget {
  final List<Map<String, dynamic>> addresses;
  final int selected;
  final ValueChanged<int> onChanged;

  const _ShippingAddressSection({
    required this.addresses,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: addresses.asMap().entries.map((entry) {
        final index = entry.key;
        final address = entry.value;
        final isSelected = index == selected;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableTile(
            onTap: () => onChanged(index),
            selected: isSelected,
            leading: Icon(
              Icons.location_on_outlined,
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
            ),
            title: address['name'],
            subtitle: '${address['address']}\n${address['phone']}',
          ),
        );
      }).toList(),
    );
  }
}
