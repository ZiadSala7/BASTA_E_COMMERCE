part of '../addresses_page.dart';

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final SavedAddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault
              ? AppColors.primary
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (address.isDefault)
                      _DefaultBadge(
                        label: l10n.pick(ar: 'افتراضي', en: 'Default'),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.summary,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (address.phone.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    address.phone,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<_AddressAction>(
            onSelected: (action) {
              switch (action) {
                case _AddressAction.edit:
                  onEdit();
                  return;
                case _AddressAction.makeDefault:
                  onSetDefault?.call();
                  return;
                case _AddressAction.delete:
                  onDelete();
                  return;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _AddressAction.edit,
                child: Text(l10n.pick(ar: 'تعديل', en: 'Edit')),
              ),
              if (onSetDefault != null)
                PopupMenuItem(
                  value: _AddressAction.makeDefault,
                  child: Text(
                    l10n.pick(ar: 'تعيين كافتراضي', en: 'Make default'),
                  ),
                ),
              PopupMenuItem(
                value: _AddressAction.delete,
                child: Text(l10n.pick(ar: 'حذف', en: 'Delete')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
