import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import 'account_section.dart';

class AccountMenuSection extends StatelessWidget {
  const AccountMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSection(
      children: [
        AccountMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: l10n.myOrders,
          onTap: () {},
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.location_on_outlined,
          title: l10n.myAddresses,
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.credit_card_outlined,
          title: l10n.paymentMethods,
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.favorite_border_outlined,
          title: l10n.favorites,
          onTap: () => context.push(AppRoutes.favorites),
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.card_giftcard_outlined,
          title: l10n.coupons,
        ),
      ],
    );
  }
}

class AccountSupportSection extends StatelessWidget {
  const AccountSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSection(
      title: l10n.supportAndHelp,
      children: [
        AccountMenuItem(icon: Icons.help_outline, title: l10n.faq),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.contact_support_outlined,
          title: l10n.contactUs,
        ),
        const AccountDivider(),
        AccountMenuItem(icon: Icons.policy_outlined, title: l10n.privacyPolicy),
      ],
    );
  }
}

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
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.notifications_none,
          title: l10n.notificationSettings,
          showSwitch: true,
        ),
      ],
    );
  }
}
