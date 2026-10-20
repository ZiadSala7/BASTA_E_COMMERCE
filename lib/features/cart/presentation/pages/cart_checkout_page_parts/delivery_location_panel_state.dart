part of '../cart_checkout_page.dart';

class _DeliveryLocationPanelState extends State<_DeliveryLocationPanel> {
  final MapController _mapController = MapController();
  bool _mapControllerReady = false;
  late LatLng _currentMapCenter;
  String? _selectedPlaceName;
  bool _isResolvingPlace = false;
  int _placeLookupGeneration = 0;

  @override
  void initState() {
    super.initState();
    _currentMapCenter = widget.selectedLocation ?? widget.initialLocation;
    final selectedLocation = widget.selectedLocation;
    if (selectedLocation != null) {
      _resolvePlaceName(selectedLocation);
    }
  }

  @override
  void didUpdateWidget(covariant _DeliveryLocationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      _currentMapCenter = widget.selectedLocation ?? widget.initialLocation;
      if (widget.selectedLocation != null) {
        _resolvePlaceName(widget.selectedLocation!);
        if (_mapControllerReady) {
          _mapController.move(widget.selectedLocation!, 15);
        }
      } else {
        _clearPlaceName();
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _selectLocation(LatLng location) {
    widget.onLocationSelected(location);
    setState(() {
      _currentMapCenter = location;
    });
    _resolvePlaceName(location);
    if (_mapControllerReady) {
      _mapController.move(location, 15);
    }
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

  void _clearPlaceName() {
    _placeLookupGeneration++;
    setState(() {
      _selectedPlaceName = null;
      _isResolvingPlace = false;
    });
  }

  Future<void> _openLargeMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialCenter: _currentMapCenter,
          selectedLocation: widget.selectedLocation,
        ),
      ),
    );

    if (result != null) {
      _selectLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedLocation = widget.selectedLocation;

    return _Panel(
      title: l10n.pick(ar: 'موقع التوصيل', en: 'Delivery location'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.pick(
              ar: 'اسحب الخريطة أو اضغط على الموقع لتحديد مكان التوصيل.',
              en: 'Drag the map or tap a point to choose your delivery location.',
            ),
            style: GoogleFonts.cairo(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentMapCenter,
                      initialZoom: 13,
                      minZoom: 3,
                      maxZoom: 19,
                      onMapReady: () => _mapControllerReady = true,
                      onTap: (_, point) => _selectLocation(point),
                      onPositionChanged: (camera, _) =>
                          _currentMapCenter = camera.center,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'busta',
                      ),
                      if (selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                size: 40,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            '© OpenStreetMap contributors',
                            onTap: () =>
                                OpenStreetMapAttribution.openCopyrightPage(
                                  context,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.location_pin,
                    size: 42,
                    color: Color(0xFFE53935),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => _selectLocation(_currentMapCenter),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(
              l10n.pick(ar: 'تأكيد الموقع', en: 'Confirm location'),
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openLargeMap,
            icon: const Icon(Icons.open_in_full_rounded, size: 16),
            label: Text(
              l10n.pick(ar: 'فتح الخريطة', en: 'Open map'),
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: selectedLocation == null
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.38)
                  : AppColors.primaryFor(context).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedLocation == null
                    ? colorScheme.outlineVariant
                    : AppColors.primaryFor(context).withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedLocation == null
                      ? Icons.add_location_alt_outlined
                      : Icons.location_on_rounded,
                  color: selectedLocation == null
                      ? colorScheme.onSurfaceVariant
                      : AppColors.primaryFor(context),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    selectedLocation == null
                        ? l10n.pick(
                            ar: 'لم يتم تحديد موقع بعد',
                            en: 'No location selected yet',
                          )
                        : _isResolvingPlace
                        ? l10n.pick(
                            ar: 'جارٍ تحديد الموقع...',
                            en: 'Resolving location...',
                          )
                        : _selectedPlaceName ??
                              l10n.pick(
                                ar: 'الموقع المحدد',
                                en: 'Selected location',
                              ),
                    style: GoogleFonts.cairo(
                      color: selectedLocation == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _selectLocation(_currentMapCenter),
                  icon: const Icon(Icons.my_location_rounded, size: 16),
                  label: Text(
                    l10n.pick(ar: 'استخدام مركز الخريطة', en: 'Use map center'),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
