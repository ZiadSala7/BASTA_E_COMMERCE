import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/location_picker_page.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/saved_addresses_local_datasource.dart';
import '../../data/models/saved_address_model.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

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

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AddressEditorSheet extends StatefulWidget {
  const _AddressEditorSheet({this.address});

  final SavedAddressModel? address;

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  static const LatLng _defaultLocation = LatLng(31.9539, 35.9106);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  late LatLng _location;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.label ?? '');
    _streetController = TextEditingController(
      text: address?.streetAddress ?? '',
    );
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _postalCodeController = TextEditingController(
      text: address?.postalCode ?? '',
    );
    _countryController = TextEditingController(
      text: address?.country ?? 'Jordan',
    );
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _location = address == null
        ? _defaultLocation
        : LatLng(address.latitude, address.longitude);
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _chooseLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialCenter: _location,
          selectedLocation: _location,
        ),
      ),
    );

    if (result == null) return;
    setState(() => _location = result);
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final existing = widget.address;
    Navigator.of(context).pop(
      SavedAddressModel(
        id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        label: _labelController.text.trim(),
        streetAddress: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        phone: _phoneController.text.trim(),
        latitude: _location.latitude,
        longitude: _location.longitude,
        isDefault: _isDefault || existing == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.address == null
                    ? l10n.pick(ar: 'إضافة عنوان', en: 'Add address')
                    : l10n.pick(ar: 'تعديل العنوان', en: 'Edit address'),
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _AddressTextField(
                controller: _labelController,
                label: l10n.pick(ar: 'اسم العنوان', en: 'Address name'),
                hint: l10n.pick(ar: 'المنزل، العمل...', en: 'Home, work...'),
              ),
              _AddressTextField(
                controller: _streetController,
                label: l10n.pick(ar: 'العنوان التفصيلي', en: 'Street address'),
                hint: l10n.pick(
                  ar: 'الشارع، المبنى، رقم الشقة',
                  en: 'Street, building, apartment',
                ),
                minLines: 2,
              ),
              Row(
                children: [
                  Expanded(
                    child: _AddressTextField(
                      controller: _cityController,
                      label: l10n.pick(ar: 'المدينة', en: 'City'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AddressTextField(
                      controller: _stateController,
                      label: l10n.pick(ar: 'المحافظة', en: 'State'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _AddressTextField(
                      controller: _postalCodeController,
                      label: l10n.pick(ar: 'الرمز البريدي', en: 'Postal code'),
                      requiredField: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AddressTextField(
                      controller: _countryController,
                      label: l10n.pick(ar: 'الدولة', en: 'Country'),
                    ),
                  ),
                ],
              ),
              _AddressTextField(
                controller: _phoneController,
                label: l10n.pick(ar: 'رقم الهاتف', en: 'Phone number'),
                keyboardType: TextInputType.phone,
                requiredField: false,
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: _chooseLocation,
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  '${l10n.pick(ar: 'اختيار الموقع على الخريطة', en: 'Choose on map')} '
                  '(${_location.latitude.toStringAsFixed(4)}, ${_location.longitude.toStringAsFixed(4)})',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                title: Text(
                  l10n.pick(
                    ar: 'استخدام كعنوان افتراضي',
                    en: 'Use as default address',
                  ),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.pick(ar: 'حفظ العنوان', en: 'Save address')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressTextField extends StatelessWidget {
  const _AddressTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.minLines = 1,
    this.keyboardType,
    this.requiredField = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;
  final TextInputType? keyboardType;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines > 1 ? 3 : 1,
        keyboardType: keyboardType,
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pick(
                    ar: 'هذا الحقل مطلوب',
                    en: 'This field is required',
                  );
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

enum _AddressAction { edit, makeDefault, delete }
