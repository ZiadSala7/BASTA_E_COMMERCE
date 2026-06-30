import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extensions/app_localizations_x.dart';
import '../utils/app_colors.dart';
import '../../l10n/app_localizations.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    required this.initialCenter,
    this.selectedLocation,
    this.title,
  });

  final LatLng initialCenter;
  final LatLng? selectedLocation;
  final String? title;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _controller;
  late LatLng _currentCenter;
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.selectedLocation ?? widget.initialCenter;
    _selected = widget.selectedLocation;
  }

  void _confirm() {
    Navigator.of(context).pop<LatLng>(_selected ?? _currentCenter);
  }

  Future<void> _moveToSelection() async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(_selected ?? _currentCenter, 15),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? l10n.pick(ar: 'حدد الموقع', en: 'Choose location'),
        ),
        actions: [
          TextButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            label: Text(
              l10n.pick(ar: 'تأكيد', en: 'Confirm'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(3, 19),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _controller = controller,
            onTap: (point) => setState(() => _selected = point),
            onCameraMove: (position) => _currentCenter = position.target,
            markers: _selected == null
                ? const <Marker>{}
                : {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selected!,
                    ),
                  },
          ),
          IgnorePointer(
            child: Icon(
              Icons.add_location_alt_rounded,
              color: AppColors.primary.withValues(alpha: 0.9),
              size: 36,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18 + MediaQuery.paddingOf(context).bottom,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.pick(
                          ar: 'اضغط على المكان أو حرك الخريطة ثم أكد الموقع.',
                          en: 'Tap a point or move the map, then confirm.',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _confirm,
                      child: Text(l10n.pick(ar: 'استخدام', en: 'Use')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToSelection,
        tooltip: l10n.pick(ar: 'العودة للموقع المحدد', en: 'Return to pin'),
        child: const Icon(Icons.center_focus_strong_rounded),
      ),
    );
  }
}
