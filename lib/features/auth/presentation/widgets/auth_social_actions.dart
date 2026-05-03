import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'auth_social_button.dart';

class AuthSocialActions extends StatelessWidget {
  const AuthSocialActions({super.key});

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
          onTap: () {},
        ),
        const SizedBox(height: 12),
        AuthSocialButton(
          label: localizations.loginWithFacebook,
          badgeText: 'f',
          badgeColor: const Color(0xFF1877F2),
          onTap: () {},
        ),
      ],
    );
  }
}
