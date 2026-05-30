import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'auth_social_button.dart';

class AuthSocialActions extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;

  const AuthSocialActions({super.key, this.onGoogleTap, this.onFacebookTap});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          localizations.orLabel,
          style: AppTextStyles.authHeadingSubtitle(context),
        ),
        const SizedBox(height: 16),
        AuthSocialButton(
          label: localizations.loginWithGoogle,
          badgeText: 'G',
          badgeColor: const Color(0xFFEA4335),
          onTap: onGoogleTap,
        ),
        const SizedBox(height: 12),
        AuthSocialButton(
          label: localizations.loginWithFacebook,
          badgeText: 'f',
          badgeColor: const Color(0xFF1877F2),
          onTap: onFacebookTap,
        ),
      ],
    );
  }
}
