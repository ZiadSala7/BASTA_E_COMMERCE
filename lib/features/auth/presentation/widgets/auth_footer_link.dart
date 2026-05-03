import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: AppTextStyles.authHelperText(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: AppTextStyles.authLinkText(context),
          ),
        ),
      ],
    );
  }
}
