import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/assets.dart';
import '../models/onboarding_page_model.dart';

abstract class OnboardingLocalDataSource {
  Future<List<OnboardingPageModel>> getOnboardingPages();
  Future<void> markOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const _kOnboardingDone = 'onboarding_done';

  final SharedPreferences prefs;

  const OnboardingLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<OnboardingPageModel>> getOnboardingPages() async {
    return const [
      OnboardingPageModel(
        id: 1,
        title: 'onboardingTitle1',
        subtitle: 'onboardingSubtitle1',
        imagePath: Assets.imagesOnboarding1,
      ),
      OnboardingPageModel(
        id: 2,
        title: 'onboardingTitle2',
        subtitle: 'onboardingSubtitle2',
        imagePath: Assets.imagesOnboarding2,
      ),
    ];
  }

  @override
  Future<void> markOnboardingCompleted() async {
    await prefs.setBool(_kOnboardingDone, true);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return prefs.getBool(_kOnboardingDone) ?? false;
  }
}
