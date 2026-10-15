part of '../account_menu_sections.dart';

class AccountSocialSection extends StatelessWidget {
  const AccountSocialSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSection(
      title: l10n.socialAccounts,
      children: [
        AccountMenuItem(
          icon: Icons.camera_alt_outlined,
          title: l10n.instagram,
          onTap: () => _openSocialLink(
            context,
            Uri.parse('https://www.instagram.com/bs6a.jo/'),
          ),
        ),
        const AccountDivider(),
        AccountMenuItem(
          icon: Icons.facebook,
          title: l10n.facebook,
          onTap: () => _openSocialLink(
            context,
            Uri.parse(
              'https://www.facebook.com/share/19jsDwKUXa/?mibextid=wwXIfr',
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openSocialLink(BuildContext context, Uri uri) async {
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showSocialLinkError(context);
    }
  } on PlatformException {
    if (context.mounted) {
      _showSocialLinkError(context);
    }
  }
}

void _showSocialLinkError(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.socialLinkError)));
}
