import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/assets.dart';
import '../../../../l10n/app_localizations.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Image.asset(Assets.imagesBastaAuth, width: 160, fit: BoxFit.contain),
        const SizedBox(height: 8),
        Text(localizations.brandName, style: AppTextStyles.authBrand(context)),
      ],
    );
  }
}
