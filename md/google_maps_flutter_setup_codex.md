# Google Maps Flutter Setup — Android & iOS

## Goal
Configure Google Maps in the Flutter app for both Android and iOS using the provided Google Maps API key.

> API Key currently provided by the project owner:
>
> ```text
> AIzaSyATkZ4IB1P00fX2zDpt4zRmS-wBm-je84E
> ```

Important: Do not hardcode this key directly in Dart files. Put it in native platform config files or use build-time environment variables.

---

## Required Flutter Packages

Update `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.12.0
  geolocator: ^14.0.2
  geocoding: ^4.0.0
```

Then run:

```bash
flutter pub get
```

---

# Android Setup

## 1. Add Permissions

Open:

```text
android/app/src/main/AndroidManifest.xml
```

Add these permissions above the `<application>` tag:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

## 2. Add Google Maps API Key

Inside the `<application>` tag, add:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyATkZ4IB1P00fX2zDpt4zRmS-wBm-je84E" />
```

Example:

```xml
<application
    android:label="Your App Name"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="AIzaSyATkZ4IB1P00fX2zDpt4zRmS-wBm-je84E" />

</application>
```

## 3. Android Min SDK

Open:

```text
android/app/build.gradle
```

Make sure `minSdk` is at least 21:

```gradle
android {
    defaultConfig {
        minSdk 21
    }
}
```

---

# iOS Setup

## 1. Update iOS Deployment Target

Open:

```text
ios/Podfile
```

Make sure the platform is at least iOS 12:

```ruby
platform :ios, '12.0'
```

Then run:

```bash
cd ios
pod install
cd ..
```

## 2. Add Location Permission Text

Open:

```text
ios/Runner/Info.plist
```

Add these keys inside the main `<dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show your position on the map and select addresses.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location to show your position on the map and select addresses.</string>
```

## 3. Add Google Maps API Key in AppDelegate

Open:

```text
ios/Runner/AppDelegate.swift
```

Add this import:

```swift
import GoogleMaps
```

Then add the API key inside `application(_:didFinishLaunchingWithOptions:)` before `GeneratedPluginRegistrant.register(with: self)`:

```swift
GMSServices.provideAPIKey("AIzaSyATkZ4IB1P00fX2zDpt4zRmS-wBm-je84E")
```

Final example:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyATkZ4IB1P00fX2zDpt4zRmS-wBm-je84E")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

# Create a Test Map Screen

Create a screen like this:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapTestScreen extends StatefulWidget {
  const GoogleMapTestScreen({super.key});

  @override
  State<GoogleMapTestScreen> createState() => _GoogleMapTestScreenState();
}

class _GoogleMapTestScreenState extends State<GoogleMapTestScreen> {
  GoogleMapController? _mapController;

  static const LatLng _initialLocation = LatLng(30.0444, 31.2357); // Cairo

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('initial_location'),
      position: _initialLocation,
      infoWindow: InfoWindow(title: 'Selected Location'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Test'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _initialLocation,
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
```

---

# Optional: Current Location Helper

Use this if the app needs to get the user's current location.

```dart
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position> getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
```

---

# Optional: Location Picker Screen

This screen allows the user to tap on the map and select a location.

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _selectedLocation = const LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation,
          ),
        },
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
      ),
    );
  }
}
```

---

# Google Cloud APIs That Must Be Enabled

In Google Cloud Console, enable these APIs:

## Required for map display

- Maps SDK for Android
- Maps SDK for iOS

## Needed if the app converts coordinates to addresses

- Geocoding API

## Needed if the app searches for places/addresses

- Places API

## Needed only if the app draws routes/navigation

- Routes API

---

# API Key Restrictions Required

The API key should be restricted in Google Cloud.

## Android Restriction

Add Android app restriction:

```text
Package name: com.ionbit.bsTa
SHA-1: debug SHA-1 + release SHA-1 + Play App Signing SHA-1 if published on Google Play
```

## iOS Restriction

If using the same key for iOS, add iOS app restriction using the iOS bundle identifier.

Example:

```text
Bundle ID: com.ionbit.bsTa
```

Note: Google Cloud sometimes requires separate API keys for Android and iOS restrictions. If one key cannot be restricted for both platforms, create two keys:

- Android Maps API Key
- iOS Maps API Key

Then use the Android key in `AndroidManifest.xml` and the iOS key in `AppDelegate.swift`.

---

# Testing Checklist

Run these commands:

```bash
flutter clean
flutter pub get
flutter run
```

Expected result:

- The map appears normally.
- No gray/blank map.
- No `API_KEY_INVALID` error.
- No `REQUEST_DENIED` error.

---

# Common Problems

## Blank or gray map

Check:

- Billing account is active.
- Maps SDK for Android is enabled.
- Maps SDK for iOS is enabled if testing iOS.
- API key is correct.
- Package name is correct.
- SHA-1 is correct.
- API key restrictions are not blocking the app.

## REQUEST_DENIED

Check:

- The required API is enabled.
- API restrictions include the API being used.

## API_KEY_INVALID

Check:

- The API key was copied correctly.
- The key is not deleted.
- Platform restrictions match Android/iOS app details.

---

# Final Requirement

Implement the setup cleanly and confirm the map works on:

- Android debug build
- Android release build
- iOS simulator/device if iOS is supported

Do not commit private keys to public repositories. If possible, move API keys to environment-specific config files that are ignored from Git.
