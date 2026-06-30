// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_bloc.dart';
import 'onboarding_bottom_sheet_buttons.dart';
import 'onboarding_dot_indicator.dart';

class OnboardingBottomSheetActions extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final bool isFirst;
  final bool isLast;

  const OnboardingBottomSheetActions({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330;

        if (compact) {
          return Column(
            children: [
              OnboardingDotIndicator(
                count: totalPages,
                currentIndex: currentIndex,
                activeColor: Colors.white,
                inactiveColor: Colors.white.withOpacity(0.32),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: OnboardingSheetTextButton(
                        label: isFirst
                            ? localizations.skip
                            : localizations.back,
                        onTap: () => isFirst
                            ? context.read<OnboardingBloc>().add(
                                const OnboardingSkipPressed(),
                              )
                            : context.read<OnboardingBloc>().add(
                                const OnboardingBackPressed(),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: OnboardingSheetNextButton(
                      label: isLast
                          ? localizations.startNow
                          : localizations.next,
                      onTap: () => context.read<OnboardingBloc>().add(
                        const OnboardingNextPressed(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: OnboardingSheetTextButton(
                  label: isFirst ? localizations.skip : localizations.back,
                  onTap: () => isFirst
                      ? context.read<OnboardingBloc>().add(
                          const OnboardingSkipPressed(),
                        )
                      : context.read<OnboardingBloc>().add(
                          const OnboardingBackPressed(),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OnboardingDotIndicator(
              count: totalPages,
              currentIndex: currentIndex,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.32),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: OnboardingSheetNextButton(
                  label: isLast ? localizations.startNow : localizations.next,
                  onTap: () => context.read<OnboardingBloc>().add(
                    const OnboardingNextPressed(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
