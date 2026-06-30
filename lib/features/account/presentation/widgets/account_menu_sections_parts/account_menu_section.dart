part of '../account_menu_sections.dart';

class AccountMenuSection extends StatelessWidget {
  final VoidCallback? onEditProfile;

  const AccountMenuSection({super.key, this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSection(
      children: [
        AccountMenuItem(
          icon: Icons.person_outline,
          title: l10n.editAccount,
          onTap: onEditProfile,
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: l10n.myOrders,
          onTap: () => context.push(AppRoutes.orders),
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.location_on_outlined,
          title: l10n.myAddresses,
          onTap: () => context.push(AppRoutes.addresses),
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.credit_card_outlined,
          title: l10n.paymentMethods,
          onTap: () => _showComingSoon(context, l10n.paymentMethods),
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
          onTap: () => _showComingSoon(context, l10n.coupons),
        ),
      ],
    );
  }
}
