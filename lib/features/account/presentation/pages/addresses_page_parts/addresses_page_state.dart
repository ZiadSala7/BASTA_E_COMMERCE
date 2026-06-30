part of '../addresses_page.dart';

class _AddressesPageState extends State<AddressesPage> {
  List<SavedAddressModel> _addresses = const [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _addresses = SavedAddressesLocalDataSource.load();
    });
  }

  Future<void> _openEditor([SavedAddressModel? address]) async {
    final result = await showModalBottomSheet<SavedAddressModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddressEditorSheet(address: address),
    );

    if (result == null) return;

    await SavedAddressesLocalDataSource.upsert(result);
    if (!mounted) return;
    _loadAddresses();
  }

  Future<void> _deleteAddress(SavedAddressModel address) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.pick(ar: 'حذف العنوان', en: 'Delete address')),
        content: Text(
          l10n.pick(
            ar: 'هل تريد حذف هذا العنوان؟',
            en: 'Do you want to delete this address?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.pick(ar: 'إلغاء', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.pick(ar: 'حذف', en: 'Delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await SavedAddressesLocalDataSource.delete(address.id);
    if (!mounted) return;
    _loadAddresses();
  }

  Future<void> _setDefault(SavedAddressModel address) async {
    await SavedAddressesLocalDataSource.setDefault(address.id);
    if (!mounted) return;
    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.addresses,
        centerTitle: true,
        showSearch: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(l10n.pick(ar: 'إضافة عنوان', en: 'Add address')),
      ),
      body: _addresses.isEmpty
          ? EmptyState(
              icon: Icons.location_on_outlined,
              title: l10n.pick(ar: 'لا توجد عناوين', en: 'No addresses yet'),
              message: l10n.pick(
                ar: 'أضف عنوان توصيل لاستخدامه عند تأكيد الطلب.',
                en: 'Add a delivery address to use when confirming orders.',
              ),
              actionLabel: l10n.pick(ar: 'إضافة عنوان', en: 'Add address'),
              onActionTap: () => _openEditor(),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
              itemCount: _addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _AddressCard(
                  address: address,
                  onEdit: () => _openEditor(address),
                  onDelete: () => _deleteAddress(address),
                  onSetDefault: address.isDefault
                      ? null
                      : () => _setDefault(address),
                );
              },
            ),
    );
  }
}
