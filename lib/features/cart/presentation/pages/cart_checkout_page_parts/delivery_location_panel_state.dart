part of '../cart_checkout_page.dart';

class _DeliveryLocationPanelState extends State<_DeliveryLocationPanel> {
  GoogleMapController? _mapController;
  late LatLng _currentMapCenter;

  @override
  void initState() {
    super.initState();
    _currentMapCenter = widget.selectedLocation ?? widget.initialLocation;
  }

  @override
  void didUpdateWidget(covariant _DeliveryLocationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      _currentMapCenter = widget.selectedLocation ?? widget.initialLocation;
      if (widget.selectedLocation != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(widget.selectedLocation!, 15),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _selectLocation(LatLng location) async {
    widget.onLocationSelected(location);
    setState(() {
      _currentMapCenter = location;
    });
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
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
      await _selectLocation(result);
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
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentMapCenter,
                      zoom: 13,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (controller) => _mapController = controller,
                    onTap: _selectLocation,
                    onCameraMove: (position) {
                      _currentMapCenter = position.target;
                    },
                    markers: selectedLocation == null
                        ? const <Marker>{}
                        : {
                            Marker(
                              markerId: const MarkerId('delivery_location'),
                              position: selectedLocation,
                            ),
                          },
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
                  : AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedLocation == null
                    ? colorScheme.outlineVariant
                    : AppColors.primary.withOpacity(0.35),
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
                      : AppColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    selectedLocation == null
                        ? l10n.pick(
                            ar: 'لم يتم تحديد موقع بعد',
                            en: 'No location selected yet',
                          )
                        : '${selectedLocation.latitude.toStringAsFixed(5)}, ${selectedLocation.longitude.toStringAsFixed(5)}',
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
