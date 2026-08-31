import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets.dart';

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({
    super.key,
    this.size = 136.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 2.5,
        ),
        boxShadow: [
          // Primary Brand Glow Shadow
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 36,
            offset: const Offset(0, 14),
            spreadRadius: 2,
          ),
          // Deep Depth Shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(
          Assets.imagesPlayStore512,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
