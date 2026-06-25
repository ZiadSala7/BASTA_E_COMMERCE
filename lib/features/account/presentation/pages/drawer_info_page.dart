import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

enum DrawerInfoPageType { addresses, inviteFriends, privacyPolicy, aboutUs }

class DrawerInfoPage extends StatelessWidget {
  const DrawerInfoPage({super.key, required this.type});

  final DrawerInfoPageType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = _contentFor(l10n);

    return Scaffold(
      appBar: CustomAppBar(
        title: content.title,
        centerTitle: true,
        showSearch: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(content.icon, size: 54, color: Theme.of(context).primaryColor),
          const SizedBox(height: 18),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  _DrawerInfoContent _contentFor(AppLocalizations l10n) {
    switch (type) {
      case DrawerInfoPageType.addresses:
        return _DrawerInfoContent(
          title: l10n.addresses,
          icon: Icons.location_on_outlined,
          body: l10n.pick(
            ar: 'ستتمكن من إدارة عناوين التوصيل الخاصة بك من هنا.',
            en: 'You will be able to manage your delivery addresses here.',
          ),
        );
      case DrawerInfoPageType.inviteFriends:
        return _DrawerInfoContent(
          title: l10n.inviteFriends,
          icon: Icons.group_add_outlined,
          body: l10n.pick(
            ar: 'شارك التطبيق مع أصدقائك لتسهيل تجربة التسوق عليهم.',
            en: 'Share the app with friends so they can enjoy easier shopping.',
          ),
        );
      case DrawerInfoPageType.privacyPolicy:
        return _DrawerInfoContent(
          title: l10n.privacyPolicy,
          icon: Icons.shield_outlined,
          body: l10n.pick(
            ar: 'نحافظ على بياناتك ونستخدمها فقط لتحسين تجربة التسوق وتنفيذ الطلبات.',
            en: 'We protect your data and use it only to improve shopping and process orders.',
          ),
        );
      case DrawerInfoPageType.aboutUs:
        return _DrawerInfoContent(
          title: l10n.aboutUs,
          icon: Icons.info_outline_rounded,
          body: l10n.pick(
            ar: 'Ionbit E-Commerce يجمع المنتجات والمتاجر في تجربة تسوق سهلة وواضحة.',
            en: 'Ionbit E-Commerce brings products and stores together in a clear, simple shopping experience.',
          ),
        );
    }
  }
}

class _DrawerInfoContent {
  const _DrawerInfoContent({
    required this.title,
    required this.icon,
    required this.body,
  });

  final String title;
  final IconData icon;
  final String body;
}
