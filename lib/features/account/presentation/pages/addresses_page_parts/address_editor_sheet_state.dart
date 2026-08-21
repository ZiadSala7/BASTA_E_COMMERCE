part of '../addresses_page.dart';

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
  String? _selectedPlaceName;
  bool _isResolvingPlace = false;
  int _placeLookupGeneration = 0;

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
    _resolvePlaceName(_location);
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
    setState(() {
      _location = result;
      _selectedPlaceName = null;
      _isResolvingPlace = true;
    });
    _resolvePlaceName(result);
  }

  Future<void> _resolvePlaceName(LatLng location) async {
    final lookupGeneration = ++_placeLookupGeneration;
    setState(() {
      _isResolvingPlace = true;
      _selectedPlaceName = null;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (!mounted || lookupGeneration != _placeLookupGeneration) return;

      setState(() {
        _selectedPlaceName = _placeNameFromPlacemarks(placemarks);
        _isResolvingPlace = false;
      });
    } catch (_) {
      if (!mounted || lookupGeneration != _placeLookupGeneration) return;
      setState(() {
        _selectedPlaceName = null;
        _isResolvingPlace = false;
      });
    }
  }

  String? _placeNameFromPlacemarks(List<Placemark> placemarks) {
    if (placemarks.isEmpty) return null;
    final p = placemarks.first;
    final parts = <String>[
      if (p.street != null && p.street!.isNotEmpty) p.street!,
      if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
      if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
    ];
    return parts.isEmpty ? null : parts.join(', ');
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
                  _isResolvingPlace
                      ? l10n.pick(
                          ar: 'جارٍ تحديد الموقع...',
                          en: 'Resolving location...',
                        )
                      : _selectedPlaceName != null
                      ? '${l10n.pick(ar: 'اختيار الموقع على الخريطة', en: 'Choose on map')} — $_selectedPlaceName'
                      : '${l10n.pick(ar: 'اختيار الموقع على الخريطة', en: 'Choose on map')} '
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
