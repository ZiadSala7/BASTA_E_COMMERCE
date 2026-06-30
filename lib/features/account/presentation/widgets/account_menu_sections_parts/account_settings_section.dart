part of '../account_menu_sections.dart';

class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSection(
      title: l10n.settings,
      children: [
        AccountMenuItem(
          icon: Icons.language_outlined,
          title: l10n.language,
          subtitle: l10n.isArabic ? l10n.arabic : l10n.english,
          onTap: () => context.read<LanguageCubit>().toggleLanguage(),
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.notifications_none,
          title: l10n.notificationSettings,
          showSwitch: true,
          onSwitchChanged: (_) =>
              _showComingSoon(context, l10n.notificationSettings),
        ),
      ],
    );
  }
}

void _showComingSoon(BuildContext context, String featureName) {
  final l10n = AppLocalizations.of(context)!;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          l10n.pick(
            ar: '$featureName ستكون متاحة قريباً',
            en: '$featureName will be available soon',
          ),
        ),
      ),
    );
}
