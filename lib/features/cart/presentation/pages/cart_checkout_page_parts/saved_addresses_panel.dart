part of '../cart_checkout_page.dart';

class _SavedAddressesPanel extends StatelessWidget {
  const _SavedAddressesPanel({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelected,
    required this.onManageAddresses,
  });

  final List<SavedAddressModel> addresses;
  final String? selectedAddressId;
  final ValueChanged<SavedAddressModel> onSelected;
  final VoidCallback onManageAddresses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return _Panel(
      title: l10n.pick(ar: 'عنوان التوصيل', en: 'Delivery address'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (addresses.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.38),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_location_alt_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.pick(
                        ar: 'أضف عنوان توصيل لاستخدامه عند تأكيد الطلب.',
                        en: 'Add a delivery address to use at checkout.',
                      ),
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var index = 0; index < addresses.length; index++) ...[
              _SavedAddressTile(
                address: addresses[index],
                selected: addresses[index].id == selectedAddressId,
                onTap: () => onSelected(addresses[index]),
              ),
              if (index != addresses.length - 1) const SizedBox(height: 8),
            ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onManageAddresses,
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: Text(
              addresses.isEmpty
                  ? l10n.pick(ar: 'إضافة عنوان', en: 'Add address')
                  : l10n.pick(ar: 'إدارة العناوين', en: 'Manage addresses'),
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
