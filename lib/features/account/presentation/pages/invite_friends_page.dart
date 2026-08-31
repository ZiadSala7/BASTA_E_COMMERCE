import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  State<InviteFriendsPage> createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  static const String _appDownloadUrl = 'https://bs6a.com/register';

  late final Future<UserEntity?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<UserEntity?> _loadUser() async {
    try {
      return await sl<GetCurrentUserUseCase>()();
    } catch (_) {
      return null;
    }
  }

  String _referralCode(UserEntity? user) =>
      user?.referralCode?.trim().toUpperCase() ?? '';

  String _shareMessage(String referralCode) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.pick(
      ar:
          '🍕 مرحباً! استخدم رمز الدعوة الخاص بي ($referralCode) عند التسجيل في تطبيق بَسطة واحصل على خصم 5 د.أ على طلبك القادم!\n\nرابط التسجيل: $_appDownloadUrl?ref=$referralCode',
      en:
          '🍕 Hello! Use my invite code ($referralCode) when registering on Basta and get a JOD 5 discount on your next order!\n\nRegistration link: $_appDownloadUrl?ref=$referralCode',
    );
  }

  Future<void> _copyToClipboard(String referralCode) async {
    await Clipboard.setData(ClipboardData(text: referralCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(
            context,
          )!.pick(ar: 'تم نسخ رمز الدعوة بنجاح! 📋', en: 'Referral code copied! 📋'),
        ),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareInvite(String referralCode) async {
    await Share.share(
      _shareMessage(referralCode),
      subject: AppLocalizations.of(
          context,
        )!.pick(ar: 'دعوة للانضمام إلى تطبيق بَسطة 🍝', en: 'Join Basta with my invite 🍝'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.inviteFriends,
        showSearch: false,
        showNotificationButton: false,
        showBackButton: true,
        onNotificationPressed: () => Navigator.of(context).maybePop(),
      ),
      body: FutureBuilder<UserEntity?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final referralCode = _referralCode(snapshot.data);
          if (referralCode.isEmpty) {
            return _MissingCodeView(onRetry: () {
              setState(() {
                _userFuture = _loadUser();
              });
            });
          }

          return _InviteContent(
            referralCode: referralCode,
            onCopy: () => _copyToClipboard(referralCode),
            onShare: () => _shareInvite(referralCode),
          );
        },
      ),
    );
  }
}

class _InviteContent extends StatelessWidget {
  final String referralCode;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _InviteContent({
    required this.referralCode,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.pick(
              ar: 'ادعُ أصدقاءك واكسب 5 د.أ! 🎉',
              en: 'Invite friends and earn JOD 5! 🎉',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pick(
              ar:
                  'شارك رمز الدعوة مع أصدقائك. يحصل صديقك على قسيمة خصم فور التسجيل، وتحصل أنت على مكافأتك تلقائياً عند إتمام طلبه الأول!',
              en:
                  'Share your invite code with friends. Your friend gets a discount coupon upon sign-up, and you automatically receive your reward when their first order is delivered!',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: l10n.isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pick(
                          ar: 'رمز الدعوة الخاص بك',
                          en: 'Your referral code',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        referralCode,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(
                    l10n.pick(ar: 'نسخ', en: 'Copy'),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded),
              label: Text(
                l10n.pick(
                  ar: 'مشاركة رابط الدعوة',
                  en: 'Share invite link',
                ),
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.pick(ar: 'كيف تعمل المكافآت؟', en: 'How rewards work?'),
            textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          _StepTile(
            stepNumber: '1',
            title: l10n.pick(ar: 'شارك الرمز', en: 'Share the code'),
            description: l10n.pick(
              ar: 'أرسل رمز الدعوة أو الرابط إلى أصدقائك عبر وسائل التواصل.',
              en: 'Send your invite code or link to friends on social media.',
            ),
            icon: Icons.send_rounded,
          ),
          _StepTile(
            stepNumber: '2',
            title: l10n.pick(ar: 'صديقك يسجل', en: 'Your friend registers'),
            description: l10n.pick(
              ar:
                  'يقوم صديقك بإنشاء حساب جديد وإدخال رمزك في حقل رمز الدعوة.',
              en: 'Your friend creates a new account and enters your code in the referral field.',
            ),
            icon: Icons.person_add_alt_1_rounded,
          ),
          _StepTile(
            stepNumber: '3',
            title: l10n.pick(ar: 'اربح مكافأتك!', en: 'Earn your reward!'),
            description: l10n.pick(
              ar:
                  'يحصل صديقك فوراً على قسيمة ترحيبية، وعند تسليم طلبه الأول، ستصلك قسيمة الخصم الخاصة بك مع إشعار فوري!',
              en:
                  'Your friend gets an instant welcome coupon, and once their first order is delivered, you receive your reward coupon and a push notification!',
            ),
            icon: Icons.celebration_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final bool isLast;

  const _StepTile({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rowDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Row(
      textDirection: rowDirection,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 35,
                color: AppColors.primary.withValues(alpha: 0.18),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: l10n.isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: rowDirection,
                children: [
                  if (l10n.isArabic) ...[
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(icon, size: 18, color: AppColors.primary),
                  ] else ...[
                    Icon(icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign:
                    l10n.isArabic ? TextAlign.right : TextAlign.left,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _MissingCodeView extends StatelessWidget {
  final VoidCallback onRetry;

  const _MissingCodeView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_giftcard_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.pick(
                ar: 'رمز الدعوة غير متوفر',
                en: 'Referral code unavailable',
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pick(
                ar:
                    'تعذر العثور على رمز الدعوة الخاص بك. حاول مرة أخرى أو تواصل مع الدعم.',
                en:
                    'We could not find your referral code. Try again or contact support.',
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                l10n.tryAgain,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
