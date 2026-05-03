// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import 'onboarding_bottom_sheet_actions.dart';

class OnboardingBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentIndex;
  final int totalPages;
  final bool isFirst;
  final bool isLast;

  const OnboardingBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentIndex,
    required this.totalPages,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B5BFF), Color(0xFF7C5CFF)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(28, 36, 28, bottomPad + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.onboardingSheetTitle(context),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTextStyles.onboardingSheetSubtitle(context),
          ),
          const SizedBox(height: 36),
          OnboardingBottomSheetActions(
            currentIndex: currentIndex,
            totalPages: totalPages,
            isFirst: isFirst,
            isLast: isLast,
          ),
        ],
      ),
    );
  }
}
