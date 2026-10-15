import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/app_localizations_x.dart';
import '../../l10n/app_localizations.dart';

abstract final class OpenStreetMapAttribution {
  static Future<void> openCopyrightPage(BuildContext context) async {
    try {
      final launched = await launchUrl(
        Uri.parse('https://www.openstreetmap.org/copyright'),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showLaunchError(context);
      }
    } on PlatformException {
      if (context.mounted) {
        _showLaunchError(context);
      }
    }
  }

  static void _showLaunchError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.pick(
              ar: 'تعذر فتح صفحة حقوق OpenStreetMap.',
              en: 'Could not open the OpenStreetMap copyright page.',
            ),
          ),
        ),
      );
  }
}
