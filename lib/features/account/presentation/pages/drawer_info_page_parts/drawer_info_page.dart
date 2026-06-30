part of '../drawer_info_page.dart';

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
          icon: Icon(
            l10n.isArabic
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        children: [
          _InfoHero(content: content),
          const SizedBox(height: 18),
          ...content.sections.expand(
            (section) => [section, const SizedBox(height: 14)],
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
          subtitle: l10n.pick(
            ar: 'إدارة عناوين التوصيل الخاصة بك ستكون متاحة من هنا.',
            en: 'You will be able to manage your delivery addresses here.',
          ),
          icon: Icons.location_on_outlined,
          sections: const [],
        );
      case DrawerInfoPageType.inviteFriends:
        return _DrawerInfoContent(
          title: l10n.inviteFriends,
          subtitle: l10n.pick(
            ar: 'شارك بَسطة مع أصدقائك لتسهيل تجربة التسوق عليهم.',
            en: 'Share Basta with friends so they can enjoy easier shopping.',
          ),
          icon: Icons.group_add_outlined,
          sections: const [],
        );
      case DrawerInfoPageType.privacyPolicy:
        return _privacyContent(l10n);
      case DrawerInfoPageType.aboutUs:
        return _aboutContent(l10n);
      case DrawerInfoPageType.faq:
        return _faqContent(l10n);
      case DrawerInfoPageType.contactUs:
        return _contactContent(l10n);
    }
  }

  _DrawerInfoContent _aboutContent(AppLocalizations l10n) {
    return _DrawerInfoContent(
      title: l10n.aboutUs,
      subtitle: l10n.pick(
        ar: 'بَسطة هي منصة تسوق إلكترونية أردنية تجمع الجودة والسعر المناسب والخدمة الاحترافية في مكان واحد.',
        en: 'Basta is a Jordanian e-commerce platform that brings quality, fair pricing, and professional service together in one place.',
      ),
      icon: Icons.storefront_outlined,
      sections: [
        _InfoCard(
          title: l10n.pick(ar: 'ما الذي نقدمه؟', en: 'What we offer'),
          children: [
            _FeatureTile(
              icon: Icons.shopping_bag_outlined,
              title: l10n.pick(ar: 'تسوق سهل', en: 'Easy shopping'),
              body: l10n.pick(
                ar: 'واجهة بسيطة وسلسة تجعل الشراء ممتعاً وسريعاً بلا تعقيد.',
                en: 'A simple, smooth interface that makes buying fast, clear, and enjoyable.',
              ),
            ),
            _FeatureTile(
              icon: Icons.verified_outlined,
              title: l10n.pick(ar: 'جودة مضمونة', en: 'Guaranteed quality'),
              body: l10n.pick(
                ar: 'نختار بعناية كل منتج على منصتنا لضمان رضاك التام.',
                en: 'Every product on the platform is selected carefully to help ensure your satisfaction.',
              ),
            ),
            _FeatureTile(
              icon: Icons.local_shipping_outlined,
              title: l10n.pick(ar: 'توصيل سريع', en: 'Fast delivery'),
              body: l10n.pick(
                ar: 'شراكات مع أبرز شركات الشحن في الأردن لوصول آمن وسريع.',
                en: 'Partnerships with leading shipping companies in Jordan for safe and fast delivery.',
              ),
            ),
          ],
        ),
        _InfoCard(
          title: l10n.pick(ar: 'رؤيتنا', en: 'Our vision'),
          children: [
            _QuoteBlock(
              text: l10n.pick(
                ar: 'نؤمن بأن التجارة الإلكترونية في الأردن قادرة على تحقيق نقلة نوعية في الاقتصاد الوطني.',
                en: 'We believe e-commerce in Jordan can create a meaningful shift in the national economy.',
              ),
            ),
            _FeatureTile(
              icon: Icons.handshake_outlined,
              title: l10n.pick(ar: 'تمكين التجار', en: 'Empowering merchants'),
              body: l10n.pick(
                ar: 'نوفر للتجار الأردنيين أدوات ذكية لإدارة متاجرهم وزيادة دخلهم بشكل مستدام.',
                en: 'We provide Jordanian merchants with smart tools to manage stores and grow sustainably.',
              ),
            ),
            _FeatureTile(
              icon: Icons.lock_open_outlined,
              title: l10n.pick(ar: 'تيسير العملاء', en: 'Serving customers'),
              body: l10n.pick(
                ar: 'نضمن لكل عميل وصولاً سهلاً وآمناً لأفضل المنتجات بأسعار تنافسية.',
                en: 'We help every customer reach great products easily and securely at competitive prices.',
              ),
            ),
          ],
        ),
        _InfoCard(
          title: l10n.pick(ar: 'أهدافنا الاستراتيجية', en: 'Strategic goals'),
          children: [
            _NumberedPoint(
              number: '1',
              text: l10n.pick(
                ar: 'المنصة الأولى في الأردن من حيث ثقة المتسوقين.',
                en: "Become Jordan's most trusted shopping platform.",
              ),
            ),
            _NumberedPoint(
              number: '2',
              text: l10n.pick(
                ar: 'بيئة تجارية عادلة لصغار التجار والمشاريع الناشئة.',
                en: 'Create a fair commercial environment for small merchants and startups.',
              ),
            ),
            _NumberedPoint(
              number: '3',
              text: l10n.pick(
                ar: 'دعم التحول الرقمي للمملكة الأردنية الهاشمية.',
                en: 'Support digital transformation in the Hashemite Kingdom.',
              ),
            ),
            _NumberedPoint(
              number: '4',
              text: l10n.pick(
                ar: 'التوسع لجميع محافظات المملكة.',
                en: 'Expand across all governorates of Jordan.',
              ),
            ),
          ],
        ),
        _TagWrap(
          tags: [
            l10n.pick(ar: 'الشفافية في الأسعار', en: 'Transparent pricing'),
            l10n.pick(ar: 'الابتكار المستمر', en: 'Continuous innovation'),
            l10n.pick(ar: 'دعم المجتمع الأردني', en: 'Supporting Jordan'),
          ],
        ),
      ],
    );
  }

  _DrawerInfoContent _faqContent(AppLocalizations l10n) {
    final faqs = [
      _FaqItem(
        question: l10n.pick(ar: 'ما هي بَسطة؟', en: 'What is Basta?'),
        answer: l10n.pick(
          ar: 'منصة تسوق إلكترونية أردنية تجمع الجودة والسعر والخدمة.',
          en: 'A Jordanian e-commerce platform that combines quality, pricing, and service.',
        ),
      ),
      _FaqItem(
        question: l10n.pick(ar: 'كيف أشتري؟', en: 'How do I buy?'),
        answer: l10n.pick(
          ar: 'اختر المنتج، أضفه للسلة، وأكمل الدفع. ستصلك رسالة تأكيد فوراً.',
          en: 'Choose a product, add it to the cart, and complete payment. You will receive a confirmation message right away.',
        ),
      ),
      _FaqItem(
        question: l10n.pick(
          ar: 'ما طرق الدفع المتاحة؟',
          en: 'What payment methods are available?',
        ),
        answer: l10n.pick(
          ar: 'نقداً عند الاستلام، بطاقات Visa/Mastercard، ومحافظ إلكترونية.',
          en: 'Cash on delivery, Visa/Mastercard cards, and electronic wallets.',
        ),
      ),
      _FaqItem(
        question: l10n.pick(
          ar: 'هل يمكن إرجاع المنتج؟',
          en: 'Can I return a product?',
        ),
        answer: l10n.pick(
          ar: 'نعم، خلال 7 أيام للمنتجات غير المستخدمة وبغلافها الأصلي.',
          en: 'Yes. Returns are accepted within 7 days for unused products in their original packaging.',
        ),
      ),
      _FaqItem(
        question: l10n.pick(
          ar: 'كيف أتابع طلبي؟',
          en: 'How do I track my order?',
        ),
        answer: l10n.pick(
          ar: 'ستصلك رسالة برقم التتبع بعد التأكيد للمتابعة عبر شركة الشحن.',
          en: 'After confirmation, you will receive a tracking number to follow the shipment with the carrier.',
        ),
      ),
      _FaqItem(
        question: l10n.pick(
          ar: 'هل تشحنون لجميع المحافظات؟',
          en: 'Do you ship to all governorates?',
        ),
        answer: l10n.pick(
          ar: 'نعم، نغطي جميع محافظات المملكة الأردنية الهاشمية.',
          en: 'Yes, we cover all governorates of the Hashemite Kingdom of Jordan.',
        ),
      ),
    ];

    return _DrawerInfoContent(
      title: l10n.faq,
      subtitle: l10n.pick(
        ar: 'إجابات سريعة على أكثر الأسئلة شيوعاً عن التسوق عبر بَسطة.',
        en: 'Quick answers to the most common questions about shopping with Basta.',
      ),
      icon: Icons.help_outline_rounded,
      sections: [_FaqList(items: faqs)],
    );
  }

  _DrawerInfoContent _contactContent(AppLocalizations l10n) {
    return _DrawerInfoContent(
      title: l10n.contactUs,
      subtitle: l10n.pick(
        ar: 'فريق بَسطة جاهز لمساعدتك في الطلبات، الإرجاع، الدفع، ودعم التجار.',
        en: 'The Basta team is ready to help with orders, returns, payments, and merchant support.',
      ),
      icon: Icons.contact_support_outlined,
      sections: [
        _InfoCard(
          title: l10n.pick(ar: 'بيانات التواصل', en: 'Contact details'),
          children: [
            _ContactTile(
              icon: Icons.phone_outlined,
              label: l10n.pick(ar: 'الهاتف', en: 'Phone'),
              value: '0798951212',
            ),
            _ContactTile(
              icon: Icons.email_outlined,
              label: l10n.pick(ar: 'البريد الإلكتروني', en: 'Email'),
              value: 'Bs6a@info.com',
            ),
            _ContactTile(
              icon: Icons.schedule_outlined,
              label: l10n.pick(ar: 'أوقات العمل', en: 'Working hours'),
              value: l10n.pick(
                ar: 'أحد - خميس، 9ص - 6م',
                en: 'Sunday - Thursday, 9 AM - 6 PM',
              ),
            ),
            _ContactTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: l10n.pick(ar: 'واتساب', en: 'WhatsApp'),
              value: l10n.pick(
                ar: 'ابدأ محادثة ورد سريع خلال دقائق',
                en: 'Start a chat and get a quick reply within minutes',
              ),
            ),
          ],
        ),
        _InfoCard(
          title: l10n.pick(
            ar: 'مواضيع الدعم الشائعة',
            en: 'Common support topics',
          ),
          children: [
            _NumberedPoint(
              number: '1',
              text: l10n.pick(
                ar: 'تتبع الطلبات: أرسل رقم الطلب وسنتابعه فوراً.',
                en: 'Order tracking: send your order number and we will follow it right away.',
              ),
            ),
            _NumberedPoint(
              number: '2',
              text: l10n.pick(
                ar: 'الإرجاع والاستبدال خلال 7 أيام بدون تعقيد.',
                en: 'Returns and exchanges within 7 days without complications.',
              ),
            ),
            _NumberedPoint(
              number: '3',
              text: l10n.pick(
                ar: 'مشاكل الدفع: نحلها في أقل وقت ممكن.',
                en: 'Payment issues: we resolve them as quickly as possible.',
              ),
            ),
            _NumberedPoint(
              number: '4',
              text: l10n.pick(
                ar: 'دعم التجار عبر قناة مخصصة لإدارة المتاجر.',
                en: 'Merchant support through a dedicated store-management channel.',
              ),
            ),
          ],
        ),
        const _TagWrap(tags: ['X', 'Instagram']),
      ],
    );
  }

  _DrawerInfoContent _privacyContent(AppLocalizations l10n) {
    return _DrawerInfoContent(
      title: l10n.privacyPolicy,
      subtitle: l10n.pick(
        ar: 'نحافظ على بياناتك ونستخدمها فقط لتشغيل تجربة التسوق وتنفيذ الطلبات وتحسين الخدمة.',
        en: 'We protect your data and use it only to run shopping, process orders, and improve the service.',
      ),
      icon: Icons.shield_outlined,
      sections: [
        _InfoCard(
          title: l10n.pick(
            ar: 'المعلومات التي نجمعها',
            en: 'Information we collect',
          ),
          children: [
            _BulletPoint(
              text: l10n.pick(
                ar: 'معلومات الحساب مثل الاسم ورقم الهاتف والبريد الإلكتروني.',
                en: 'Account details such as name, phone number, and email.',
              ),
            ),
            _BulletPoint(
              text: l10n.pick(
                ar: 'معلومات الطلب والتوصيل اللازمة لمعالجة مشترياتك.',
                en: 'Order and delivery details needed to process your purchases.',
              ),
            ),
            _BulletPoint(
              text: l10n.pick(
                ar: 'معلومات تقنية تساعدنا على تحسين الأداء والأمان.',
                en: 'Technical information that helps us improve performance and security.',
              ),
            ),
          ],
        ),
        _InfoCard(
          title: l10n.pick(ar: 'كيف نستخدم البيانات', en: 'How we use data'),
          children: [
            _BulletPoint(
              text: l10n.pick(
                ar: 'تأكيد الطلبات وإرسال تحديثات الشحن والتتبع.',
                en: 'Confirm orders and send shipping and tracking updates.',
              ),
            ),
            _BulletPoint(
              text: l10n.pick(
                ar: 'التواصل معك بخصوص الدعم الفني أو الإرجاع والاستبدال.',
                en: 'Contact you about support, returns, and exchanges.',
              ),
            ),
            _BulletPoint(
              text: l10n.pick(
                ar: 'تحسين المنتجات والعروض وتجربة استخدام التطبيق.',
                en: 'Improve products, offers, and the app experience.',
              ),
            ),
          ],
        ),
        _InfoCard(
          title: l10n.pick(
            ar: 'حماية البيانات ومشاركتها',
            en: 'Data protection and sharing',
          ),
          children: [
            _BulletPoint(
              text: l10n.pick(
                ar: 'لا نبيع بياناتك الشخصية، ولا نشاركها إلا عند الحاجة لإتمام الخدمة.',
                en: 'We do not sell your personal data and only share it when needed to complete the service.',
              ),
            ),
            _BulletPoint(
              text: l10n.pick(
                ar: 'قد نشارك بيانات التوصيل مع شركات الشحن لإيصال الطلب بأمان.',
                en: 'Delivery details may be shared with shipping partners to deliver orders safely.',
              ),
            ),
            _BulletPoint(
              text: l10n.pick(
                ar: 'نستخدم إجراءات أمان مناسبة لحماية الحسابات وعمليات الدفع.',
                en: 'We use appropriate security measures to protect accounts and payments.',
              ),
            ),
          ],
        ),
        _InfoCard(
          title: l10n.pick(ar: 'حقوقك', en: 'Your rights'),
          children: [
            _BulletPoint(
              text: l10n.pick(
                ar: 'يمكنك طلب تحديث بياناتك أو تصحيحها عند الحاجة.',
                en: 'You can request updates or corrections to your data when needed.',
              ),
            ),
            _BulletPoint(
              text: l10n.pick(
                ar: 'يمكنك التواصل معنا لأي سؤال متعلق بالخصوصية عبر Bs6a@info.com.',
                en: 'You can contact us about privacy questions at Bs6a@info.com.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
