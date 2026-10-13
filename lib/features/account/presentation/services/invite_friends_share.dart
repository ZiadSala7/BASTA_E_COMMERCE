import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';

abstract final class InviteFriendsShare {
  static const String _appDownloadUrl = 'https://bs6a.com/register';

  static Future<void> show(BuildContext context, {String? referralCode}) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    var code = referralCode?.trim().toUpperCase() ?? '';
    if (code.isEmpty) {
      try {
        final user = await sl<GetCurrentUserUseCase>()();
        code = user.referralCode?.trim().toUpperCase() ?? '';
      } catch (_) {}
    }
    if (!context.mounted) return;

    if (code.isEmpty) {
      _showMessage(
        context,
        l10n.pick(
          ar: 'تعذر تحميل رمز الدعوة. حاول مرة أخرى.',
          en: 'Could not load your invite code. Please try again.',
        ),
      );
      return;
    }

    final message = l10n.pick(
      ar: '🍕 مرحباً! استخدم رمز الدعوة الخاص بي ($code) عند التسجيل في تطبيق بَسطة واحصل على خصم ${l10n.formatPrice(5, 0)} على طلبك القادم!\n\nرابط التسجيل: $_appDownloadUrl?ref=$code',
      en: '🍕 Hello! Use my invite code ($code) when registering on Basta and get a JOD 5 discount on your next order!\n\nRegistration link: $_appDownloadUrl?ref=$code',
    );
    final renderObject = context.findRenderObject();
    final sharePositionOrigin =
        renderObject is RenderBox && renderObject.hasSize
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : const Rect.fromLTWH(0, 0, 1, 1);

    try {
      await Share.share(
        message,
        subject: l10n.pick(
          ar: 'دعوة للانضمام إلى تطبيق بَسطة 🍝',
          en: 'Join Basta with my invite 🍝',
        ),
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(
        context,
        l10n.pick(
          ar: 'تعذرت مشاركة الدعوة. حاول مرة أخرى.',
          en: 'Could not open sharing. Please try again.',
        ),
      );
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
