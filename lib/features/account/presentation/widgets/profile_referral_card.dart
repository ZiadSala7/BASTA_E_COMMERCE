import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileReferralCard extends StatelessWidget {
  final String? referralCode;

  const ProfileReferralCard({super.key, this.referralCode});

  static const String _appDownloadUrl = 'https://bs6a.com/register';

  void _copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.pick(
                    ar: 'تم نسخ رمز الدعوة ($code) بنجاح! 📋',
                    en: 'Referral code ($code) copied! 📋',
                  ),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _shareInvite(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    final message = l10n.pick(
      ar:
          '🍕 مرحباً! استخدم رمز الدعوة الخاص بي ($code) عند التسجيل في تطبيق بَسطة واحصل على خصم 5 د.أ على طلبك!\n\nرابط التسجيل: $_appDownloadUrl?ref=$code',
      en:
          '🍕 Hello! Use my invite code ($code) when registering on Basta and get a JOD 5 discount on your order!\n\nRegistration link: $_appDownloadUrl?ref=$code',
    );

    Share.share(
      message,
      subject: l10n.pick(
        ar: 'دعوة للانضمام إلى تطبيق بَسطة 🍝',
        en: 'Join Basta with my invite 🍝',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final code = referralCode?.trim().toUpperCase() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top gradient header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pick(
                          ar: 'ادعُ أصدقاءك واكسب 5 د.أ! 🎉',
                          en: 'Invite Friends & Earn 5 JOD! 🎉',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        l10n.pick(
                          ar: 'يحصل صديقك على خصم وتكسب أنت قسيمة عند طلبه الأول',
                          en: 'Friend gets discount & you earn a coupon on their 1st order',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.inviteFriends),
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: l10n.pick(ar: 'تفاصيل المكافآت', en: 'Reward details'),
                ),
              ],
            ),
          ),

          // Code display and actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: code.isNotEmpty
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2430)
                              : const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.pick(
                                    ar: 'رمز الدعوة الخاص بك',
                                    en: 'Your Referral Code',
                                  ),
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  code,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Copy button
                            ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(context, code),
                              icon: const Icon(Icons.copy_rounded, size: 15),
                              label: Text(
                                l10n.pick(ar: 'نسخ', en: 'Copy'),
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () => _shareInvite(context, code),
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: Text(
                            l10n.pick(
                              ar: 'مشاركة رمز الدعوة مع الأصدقاء',
                              en: 'Share referral code with friends',
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.pick(
                            ar: 'ادعُ أصدقاءك واستمتع بخصومات حصرية',
                            en: 'Invite your friends and enjoy exclusive discounts',
                          ),
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push(AppRoutes.inviteFriends),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.pick(ar: 'دعوة الأصدقاء', en: 'Invite Friends'),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
