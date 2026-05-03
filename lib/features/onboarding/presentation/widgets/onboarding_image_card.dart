// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'onboarding_image_placeholder.dart';

/// White rounded card that displays a phone-screenshot image.
/// Drop your asset at the path defined in [OnboardingLocalDataSource]
/// and it will appear here automatically.
class OnboardingImageCard extends StatelessWidget {
  final String imagePath;

  const OnboardingImageCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.55),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B5BFF).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 0.52,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              OnboardingImagePlaceholder(path: imagePath),
        ),
      ),
    );
  }
}
