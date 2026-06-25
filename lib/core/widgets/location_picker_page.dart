import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

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
  final MapController _controller = MapController();
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
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15,
              minZoom: 3,
              maxZoom: 19,
              onTap: (_, point) => setState(() => _selected = point),
              onPositionChanged: (camera, _) {
                _currentCenter = camera.center;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ionbit.bsTa',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFE53935),
                        size: 48,
                      ),
                    ),
                  ],
                ),
            ],
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
        onPressed: () => _controller.move(_selected ?? _currentCenter, 15),
        tooltip: l10n.pick(ar: 'العودة للموقع المحدد', en: 'Return to pin'),
        child: const Icon(Icons.center_focus_strong_rounded),
      ),
    );
  }
}
