import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'auth_social_button.dart';

class AuthSocialActions extends StatelessWidget {
  final VoidCallback? onGoogleTap;

  const AuthSocialActions({super.key, this.onGoogleTap});

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
      ],
    );
  }
}
