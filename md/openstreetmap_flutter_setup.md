# OpenStreetMap in Flutter

The app uses `flutter_map` with OpenStreetMap raster tiles for delivery and
saved-address maps. `geolocator` obtains the device's current position when the
user explicitly requests it.

## Packages

```yaml
dependencies:
  flutter_map: ^8.3.2
  latlong2: ^0.10.1
  geolocator: ^14.0.2
```

## Map and attribution

Use the OpenStreetMap tile endpoint and show attribution whenever its tiles are
displayed:

```dart
FlutterMap(
  options: MapOptions(
    initialCenter: const LatLng(31.9539, 35.9106),
    initialZoom: 13,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'busta',
    ),
    RichAttributionWidget(
      attributions: [
        TextSourceAttribution(
          '© OpenStreetMap contributors',
          onTap: () =>
              OpenStreetMapAttribution.openCopyrightPage(context),
        ),
      ],
    ),
  ],
)
```

Make the attribution open the
[`OpenStreetMap copyright page`](https://www.openstreetmap.org/copyright).
Import `package:busta/core/utils/open_street_map_attribution.dart` for the
shared attribution handler.
No Google Maps SDK or Google Maps API key is required for this map.

## Current location

Request location permission only in response to a user action. Check that
location services are enabled, handle denied permissions, and call
`Geolocator.getCurrentPosition` to obtain coordinates. The Android manifest
and iOS usage descriptions must include the location permissions needed by
Geolocator.

## Tile service usage

OpenStreetMap data is open, but the public `tile.openstreetmap.org` service is
community-funded, has a usage policy, and does not provide an availability
guarantee. Keep the required attribution visible, use a valid application
User-Agent, and do not bulk-download or prefetch tiles. If traffic grows beyond
the public service's acceptable use, configure a dedicated tile provider or
self-host tiles; such services may have their own costs.
