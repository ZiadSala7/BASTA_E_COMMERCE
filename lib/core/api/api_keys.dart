import 'package:flutter/foundation.dart';

class ApiKeys {
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _normalizeBaseUrl(_apiBaseUrlOverride);
    }

    if (kIsWeb) {
      return 'http://localhost:3000/';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulators use 10.0.2.2 to reach the host machine.
        return 'http://10.0.2.2:3000/';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost:3000/';
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000/';
    }
  }

  static const String apiKey = 'your_api_key_here';

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url : '$url/';
  }
}
