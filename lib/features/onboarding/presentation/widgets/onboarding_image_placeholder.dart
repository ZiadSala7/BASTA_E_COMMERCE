import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class OnboardingImagePlaceholder extends StatelessWidget {
  final String path;

  const OnboardingImagePlaceholder({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      color: const Color(0xFFF0EEFF),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.phone_android_rounded,
            size: 64,
            color: Color(0xFF1800AD),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.imagePlaceholder,
            style: const TextStyle(
              color: Color(0xFF1800AD),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            path,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9090CC), fontSize: 11),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.replaceImagePathHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9090CC),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
