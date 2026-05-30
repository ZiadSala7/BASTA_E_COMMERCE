class ApiKeys {
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _normalizeBaseUrl(_apiBaseUrlOverride);
    }

    return 'https://api.bs6a.com/';
  }

  static const String apiKey = 'your_api_key_here';

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url : '$url/';
  }
}
