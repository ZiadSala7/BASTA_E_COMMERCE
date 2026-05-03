import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Gradient text logo ──────────────────────────────────────────────
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.logoStart,
              AppColors.logoMid,
              AppColors.logoEnd,
              AppColors.logoAccent,
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ).createShader(bounds),
          child: Image.asset(Assets.imagesAppLogo, width: 200, height: 200),
        ),

        const SizedBox(height: 6),
      ],
    );
  }
}
