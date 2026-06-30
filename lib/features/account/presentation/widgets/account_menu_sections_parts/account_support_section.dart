part of '../account_menu_sections.dart';

class AccountSupportSection extends StatelessWidget {
  const AccountSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSection(
      title: l10n.supportAndHelp,
      children: [
        AccountMenuItem(
          icon: Icons.help_outline,
          title: l10n.faq,
          onTap: () => context.push(AppRoutes.faq),
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.contact_support_outlined,
          title: l10n.contactUs,
          onTap: () => context.push(AppRoutes.contactUs),
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.policy_outlined,
          title: l10n.privacyPolicy,
          onTap: () => context.push(AppRoutes.privacyPolicy),
        ),
      ],
    );
  }
}
