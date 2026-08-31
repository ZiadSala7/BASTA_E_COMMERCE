import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/coupon_entity.dart';

class CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final VoidCallback? onApply;

  const CouponCard({
    super.key,
    required this.coupon,
    this.onApply,
  });

  void _copyCouponCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
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
                    ar: 'تم نسخ الكوبون (${coupon.code}) بنجاح! 📋',
                    en: 'Coupon code (${coupon.code}) copied! 📋',
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

  String _formatDiscount(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numVal = coupon.numericValue;
    final valStr = numVal % 1 == 0 ? numVal.toInt().toString() : numVal.toStringAsFixed(2);

    if (coupon.isFixed) {
      return l10n.pick(
        ar: '$valStr د.أ خصم',
        en: '$valStr JOD OFF',
      );
    } else {
      return l10n.pick(
        ar: 'خصم $valStr%',
        en: '$valStr% OFF',
      );
    }
  }

  String _formatDate(DateTime? date, String locale) {
    if (date == null) return '';
    try {
      return DateFormat('yyyy-MM-dd', locale).format(date);
    } catch (_) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isValid = coupon.isValid;
    final isUsed = coupon.isUsed;
    final isExpired = coupon.isExpired;

    // Badge styling
    final Color badgeColor;
    final Color badgeTextColor;
    final String badgeLabel;
    final IconData badgeIcon;

    if (isValid) {
      badgeColor = AppColors.accentGreen.withValues(alpha: 0.14);
      badgeTextColor = AppColors.accentGreen;
      badgeLabel = l10n.pick(ar: 'نشط', en: 'Active');
      badgeIcon = Icons.check_circle_rounded;
    } else if (isUsed) {
      badgeColor = AppColors.badgeRed.withValues(alpha: 0.12);
      badgeTextColor = AppColors.badgeRed;
      badgeLabel = l10n.pick(ar: 'مستخدَم', en: 'Used');
      badgeIcon = Icons.remove_circle_outline_rounded;
    } else if (isExpired) {
      badgeColor = Colors.grey.withValues(alpha: 0.18);
      badgeTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
      badgeLabel = l10n.pick(ar: 'منتهي الصلاحية', en: 'Expired');
      badgeIcon = Icons.timer_off_outlined;
    } else {
      badgeColor = Colors.grey.withValues(alpha: 0.18);
      badgeTextColor = Colors.grey;
      badgeLabel = l10n.pick(ar: 'غير صالح', en: 'Inactive');
      badgeIcon = Icons.cancel_outlined;
    }

    final accentColor = isValid ? AppColors.primary : Colors.grey.shade500;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid
              ? accentColor.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: isValid ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isValid
                ? accentColor.withValues(alpha: isDark ? 0.18 : 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Top Section: Discount and Badge
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              decoration: BoxDecoration(
                color: isValid
                    ? accentColor.withValues(alpha: isDark ? 0.12 : 0.05)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isValid
                          ? accentColor.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDiscount(context),
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isValid ? accentColor : colorScheme.onSurface,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coupon.code.startsWith('REF')
                              ? l10n.pick(
                                  ar: 'مكافأة دعوة الأصدقاء',
                                  en: 'Referral Reward Coupon',
                                )
                              : l10n.pick(
                                  ar: 'قسيمة خصم ترويجية',
                                  en: 'Discount Voucher',
                                ),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 14, color: badgeTextColor),
                        const SizedBox(width: 4),
                        Text(
                          badgeLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: badgeTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dashed Divider simulation
            _CouponDivider(color: colorScheme.outlineVariant),

            // Middle Section: Monospace Code & Copy Button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                children: [
                  Material(
                    color: isValid
                        ? (isDark ? const Color(0xFF1E2430) : const Color(0xFFF3F5FA))
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => _copyCouponCode(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isValid
                                ? accentColor.withValues(alpha: 0.25)
                                : colorScheme.outlineVariant.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                coupon.code,
                                style: GoogleFonts.spaceMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(
                                    l10n.pick(ar: 'نسخ', en: 'Copy'),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom metadata details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (coupon.endDate != null)
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.pick(
                                ar: 'ينتهي: ${_formatDate(coupon.endDate, l10n.isArabic ? 'ar' : 'en')}',
                                en: 'Expires: ${_formatDate(coupon.endDate, 'en')}',
                              ),
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      Row(
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.pick(
                              ar: 'الاستخدام: ${coupon.usedCount}/${coupon.usageLimit}',
                              en: 'Usage: ${coupon.usedCount}/${coupon.usageLimit}',
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (coupon.numericMinOrder > 0) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.pick(
                          ar: '• الحد الأدنى للطلب: ${coupon.numericMinOrder.toStringAsFixed(2)} د.أ',
                          en: '• Minimum order amount: JD ${coupon.numericMinOrder.toStringAsFixed(2)}',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponDivider extends StatelessWidget {
  final Color color;

  const _CouponDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color.withValues(alpha: 0.6)),
              ),
            );
          }),
        );
      },
    );
  }
}
