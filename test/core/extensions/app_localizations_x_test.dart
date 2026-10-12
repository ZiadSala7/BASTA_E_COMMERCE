import 'package:busta/core/extensions/app_localizations_x.dart';
import 'package:busta/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic relative times and item counts use correct forms', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    expect(l10n.hoursAgo(0), 'الآن');
    expect(l10n.hoursAgo(1), 'منذ ساعة');
    expect(l10n.hoursAgo(2), 'منذ ساعتين');
    expect(l10n.hoursAgo(4), 'منذ 4 ساعات');
    expect(l10n.hoursAgo(12), 'منذ 12 ساعة');

    expect(l10n.itemCount(0), '0 منتجًا');
    expect(l10n.itemCount(1), 'منتج واحد');
    expect(l10n.itemCount(2), 'منتجان');
    expect(l10n.itemCount(6), '6 منتجات');
    expect(l10n.itemCount(12), '12 منتجًا');
    expect(l10n.back, 'رجوع');
    expect(l10n.noImageAvailable, 'لا توجد صورة متاحة');
    expect(l10n.imageUnavailable, 'تعذر تحميل الصورة');
    expect(l10n.verificationCode, 'رمز التحقق');
  });

  test('English relative times and item counts use singular forms', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(l10n.hoursAgo(0), 'Just now');
    expect(l10n.hoursAgo(1), '1 hour ago');
    expect(l10n.hoursAgo(2), '2 hours ago');
    expect(l10n.itemCount(1), '1 item');
    expect(l10n.itemCount(2), '2 items');
  });
}
