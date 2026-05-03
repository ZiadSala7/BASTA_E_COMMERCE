import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class AuthPageHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthPageHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(title, style: AppTextStyles.authHeadingTitle(context)),
        const SizedBox(height: 10),
        Text(subtitle, style: AppTextStyles.authHeadingSubtitle(context)),
      ],
    );
  }
}
