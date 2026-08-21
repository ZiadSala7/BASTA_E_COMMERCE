import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_colors.dart';

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
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(title, style: AppTextStyles.authHeadingTitle(context)),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: AppTextStyles.authHeadingSubtitle(context).copyWith(
            height: 1.45,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
      ],
    );
  }
}
