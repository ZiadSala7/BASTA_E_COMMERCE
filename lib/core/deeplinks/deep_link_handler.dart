import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../utils/app_router.dart';

/// Handles referral invite deep links.
///
/// URL pattern: `https://bs6a.com/register?ref=A1B2C3D4`
/// Opens the Registration screen with the referral code pre-filled.
class DeepLinkHandler {
  DeepLinkHandler._();

  static AppLinks? _appLinks;
  static StreamSubscription<Uri>? _subscription;

  static Future<void> initialize() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleUri(initialUri);
        });
      }
    } catch (error) {
      debugPrint('AppLinks initial link error: $error');
    }

    _subscription = _appLinks!.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) _handleUri(uri);
      },
      onError: (Object error) {
        debugPrint('AppLinks stream error: $error');
      },
    );
  }

  static void _handleUri(Uri uri) {
    final isRegisterLink = uri.path == '/register' || uri.path == '/register/';
    final refCode = uri.queryParameters['ref']?.trim().toUpperCase();

    if (!isRegisterLink || refCode == null || refCode.isEmpty) return;

    debugPrint('Referral deep link -> ref: $refCode');
    sl<GoRouter>().push(AppRoutes.register, extra: refCode);
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _appLinks = null;
  }
}
