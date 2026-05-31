import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

extension AppLocalizationsX on AppLocalizations {
  bool get isArabic => localeName.startsWith('ar');
  TextDirection get inverseAppBarDirection =>
      isArabic ? TextDirection.ltr : TextDirection.rtl;

  String pick({required String ar, required String en}) => isArabic ? ar : en;

  String get storeName => pick(ar: 'بسطة الثقافي', en: 'Basta Cultural');
  String get home => pick(ar: 'الرئيسية', en: 'Home');
  String get offers => pick(ar: 'العروض', en: 'Offers');
  String get myOrders => pick(ar: 'طلباتي', en: 'My orders');
  String get myAccount => pick(ar: 'حسابي', en: 'My account');
  String get editAccount => pick(ar: 'تعديل الحساب', en: 'Edit account');
  String get profileDisplayName => myAccount;
  String get products => pick(ar: 'المنتجات', en: 'Products');
  String get favorites => pick(ar: 'المفضلة', en: 'Favorites');
  String get addresses => pick(ar: 'العناوين', en: 'Addresses');
  String get myAddresses => pick(ar: 'عناويني', en: 'My addresses');
  String get paymentMethods => pick(ar: 'طرق الدفع', en: 'Payment methods');
  String get coupons => pick(ar: 'الكوبونات', en: 'Coupons');
  String get accountSettings =>
      pick(ar: 'إعدادات الحساب', en: 'Account settings');
  String get information => pick(ar: 'المعلومات', en: 'Information');
  String get inviteFriends => pick(ar: 'دعوة الأصدقاء', en: 'Invite friends');
  String get privacyPolicy => pick(ar: 'سياسة الخصوصية', en: 'Privacy policy');
  String get aboutUs => pick(ar: 'من نحن', en: 'About us');
  String get logout => pick(ar: 'تسجيل الخروج', en: 'Log out');
  String get supportAndHelp =>
      pick(ar: 'الدعم والمساعدة', en: 'Support and help');
  String get faq => pick(ar: 'الأسئلة الشائعة', en: 'FAQ');
  String get contactUs => pick(ar: 'تواصل معنا', en: 'Contact us');
  String get settings => pick(ar: 'الإعدادات', en: 'Settings');
  String get language => pick(ar: 'اللغة', en: 'Language');
  String get notificationSettings => pick(ar: 'الإشعارات', en: 'Notifications');
  String get currentLanguageLabel =>
      pick(ar: 'اللغة: العربية', en: 'Language: English');
  String get lightMode => pick(ar: 'الوضع الفاتح', en: 'Light mode');
  String get darkMode => pick(ar: 'الوضع الداكن', en: 'Dark mode');

  String get showAll => pick(ar: 'عرض الكل', en: 'Show all');
  String get all => pick(ar: 'الكل', en: 'All');
  String get jewelry => pick(ar: 'مجوهرات', en: 'Jewelry');
  String get coffee => pick(ar: 'القهوة', en: 'Coffee');
  String get oud => pick(ar: 'العود', en: 'Oud');
  String get perfumes => pick(ar: 'عطور', en: 'Perfumes');
  String get fashion => pick(ar: 'أزياء', en: 'Fashion');
  String get chosenForYou => pick(ar: 'اخترنا لك', en: 'Chosen for you');
  String get discoverSchoolDesigns =>
      pick(ar: 'اكتشف تصاميم مدرسية', en: 'Discover school designs');
  String get featuredStores => pick(ar: 'متاجر مميزة', en: 'Featured stores');
  String get storeSindibad => pick(ar: 'متجر السندي', en: 'Sindibad store');
  String get storeShamiBikes =>
      pick(ar: 'الشامي للدراجات', en: 'Al Shami bikes');
  String get storeDukhanOud => pick(ar: 'دخان للعود', en: 'Dukhan Oud');
  String get storeSmartLibrary => pick(ar: 'مكتبة سماره', en: 'Samara library');
  String get rising => pick(ar: 'صاعد', en: 'Rising');
  String get shopNow => pick(ar: 'تسوق الآن', en: 'Shop now');

  String get adTitle1 => pick(
    ar: 'فخامة تملأ المكان حيث\nتلتقي الأصالة بالجودة\nفي كل منتج',
    en: 'Luxury fills the place\nwhere authenticity meets quality\nin every product',
  );
  String get adTitle2 => pick(
    ar: 'اكتشف أجمل العروض\nمن متاجرك المفضلة',
    en: 'Discover the best offers\nfrom your favorite stores',
  );
  String get adTitle3 => pick(
    ar: 'منتجات مميزة\nبجودة تستحقها',
    en: 'Featured products\nwith quality you deserve',
  );
  String get featuredProductThailand =>
      pick(ar: 'تايلاند - الباقة المميزة', en: 'Thailand - Premium package');
  String get featuredProductBakhoor =>
      pick(ar: 'بخ عيّنات الروف', en: 'Roof samples incense');
  String get featuredProductGifts =>
      pick(ar: 'مجموعة هدايا مميزة', en: 'Featured gift set');
  String get schoolDesignAwarenessFile => pick(
    ar: 'ملف الوعي الفكري 194هـ',
    en: 'Intellectual awareness file 194H',
  );
  String get schoolDesignCertificateLink =>
      pick(ar: 'رابط شهادة -035', en: 'Certificate link -035');
  String get schoolDesignStudentFile =>
      pick(ar: 'رابط ملف الطالب', en: 'Student file link');
  String jdPrice(String value) => isArabic ? '$value د.أ' : 'JOD $value';

  String productNumber(int number) =>
      pick(ar: 'منتج رقم $number', en: 'Product $number');
  String featuredProductNumber(int number) =>
      pick(ar: 'منتج مميز $number', en: 'Featured product $number');
  String currencyAmount(Object amount) =>
      isArabic ? '$amount جنيه' : 'EGP $amount';
  String get specialOfferTitle => pick(
    ar: 'عرض خاص على المنتجات المميزة',
    en: 'Special offer on featured products',
  );
  String get specialOfferBody => pick(
    ar: 'استفد من الخصم المذهل على أحدث المنتجات',
    en: 'Enjoy an amazing discount on the latest products',
  );
  String discountPercent(num value) => isArabic ? 'خصم $value%' : '$value% off';
  String get offerEnds =>
      pick(ar: 'ينتهي في: 25 ديسمبر 2024', en: 'Ends on: December 25, 2024');

  String get offersAndNotifications =>
      pick(ar: 'العروض والإشعارات', en: 'Offers and notifications');
  String get orderConfirmed =>
      pick(ar: 'طلبك مؤكد!', en: 'Your order is confirmed!');
  String get newDiscountAvailable =>
      pick(ar: 'خصم جديد متاح!', en: 'New discount available!');
  String get accountUpdated =>
      pick(ar: 'تم تحديث حسابك', en: 'Your account was updated');
  String get notificationOrderBody => pick(
    ar: 'تم تأكيد طلبك رقم #12345 ومغادرة المتجر',
    en: 'Your order #12345 was confirmed and left the store',
  );
  String hoursAgo(int count) =>
      isArabic ? 'منذ $count ساعات' : '$count hours ago';

  String get pending => pick(ar: 'قيد الانتظار', en: 'Pending');
  String get delivering => pick(ar: 'قيد التوصيل', en: 'Delivering');
  String get delivered => pick(ar: 'تم التوصيل', en: 'Delivered');
  String get orderLabel => pick(ar: 'طلب #', en: 'Order #');
  String itemCount(int count) => isArabic ? '$count منتجات' : '$count items';
  String get total => pick(ar: 'المجموع', en: 'Total');
  String get estimatedDelivery =>
      pick(ar: 'موعد التوصيل المتوقع', en: 'Estimated delivery');
  String get tomorrow => pick(ar: 'غداً', en: 'Tomorrow');
  String get december15 => pick(ar: '15 ديسمبر 2024', en: 'December 15, 2024');
  String get december14 => pick(ar: '14 ديسمبر 2024', en: 'December 14, 2024');
  String get december12 => pick(ar: '12 ديسمبر 2024', en: 'December 12, 2024');
  String get december10 => pick(ar: '10 ديسمبر 2024', en: 'December 10, 2024');
  String get december25 => pick(ar: '25 ديسمبر', en: 'December 25');

  String get discountOffer => pick(ar: 'عرض خصم', en: 'Discount offer');
  String get specialOfferForYou =>
      pick(ar: 'عرض خاص لك', en: 'Special offer for you');
  String get orderReceived => pick(ar: 'استلام الطلب', en: 'Order received');
  String get notificationDiscountBody => pick(
    ar: 'سارع الآن! احصل على خصم 50% على كل منتج تشتريه',
    en: 'Hurry now! Get 50% off every product you buy',
  );
  String get notificationSpecialOfferBody => pick(
    ar: 'لقد حصلت على خصم حصري 20%! استخدم الكود MYDEAL20 قبل منتصف الليل',
    en: 'You got an exclusive 20% discount! Use code MYDEAL20 before midnight',
  );
  String get notificationOrderReceivedBody => pick(
    ar: 'شكراً لنا تم تأكيد طلبك رقم #123123 بنجاح',
    en: 'Thanks! Your order #123123 has been confirmed successfully',
  );
  String get unread => pick(ar: 'غير مقروء', en: 'Unread');
  String get read => pick(ar: 'مقروء', en: 'Read');
  String get today => pick(ar: 'اليوم', en: 'Today');
  String get clearAll => pick(ar: 'مسح الكل', en: 'Clear all');
  String get oneHourAgo => pick(ar: 'منذ ساعة', en: '1 hour ago');

  String get cartProductTicket =>
      pick(ar: 'تايلاند - التذكرة المصغرة', en: 'Thailand - Mini ticket');
  String get thailand => pick(ar: 'تايلاند', en: 'Thailand');
  String get cartProductPrime =>
      pick(ar: 'اشتراك برايم امازون', en: 'Amazon Prime subscription');
  String dinarPrice(num value) =>
      isArabic ? '$value دينار اردني' : 'JOD $value';
  String get subtotal => pick(ar: 'الإجمالي الفرعي:', en: 'Subtotal:');
  String get discount => pick(ar: 'الخصم :', en: 'Discount:');
  String get grandTotal => pick(ar: 'الإجمالي:', en: 'Total:');
}
