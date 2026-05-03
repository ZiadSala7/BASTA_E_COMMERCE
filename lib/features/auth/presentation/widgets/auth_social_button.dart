import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final String badgeText;
  final Color badgeColor;
  final VoidCallback? onTap;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.badgeText,
    required this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BrandBadge(
                  text: badgeText,
                  color: badgeColor,
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authSocialButton(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _BrandBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
