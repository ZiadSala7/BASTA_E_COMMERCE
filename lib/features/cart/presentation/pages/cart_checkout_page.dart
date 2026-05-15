// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets.dart';
import '../../../../l10n/app_localizations.dart';

class CartCheckoutPage extends StatelessWidget {
  const CartCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _CheckoutHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                children: const [
                  _CartPreview(),
                  SizedBox(height: 12),
                  _TotalsPanel(),
                  SizedBox(height: 10),
                  _ContinueButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 96 + MediaQuery.paddingOf(context).top,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4747C2), Color(0xFF5B5BD6), Color(0xFF20B7A8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        textDirection: l10n.inverseAppBarDirection,
        children: [
          _CheckoutHeaderButton(
            icon: Icons.arrow_back_rounded,
            tooltip: l10n.back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 10),
          _CheckoutHeaderButton(
            icon: Icons.notifications_none_rounded,
            tooltip: l10n.notifications,
            onTap: () {},
            showDot: true,
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.cart,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.pick(ar: 'مراجعة الطلب', en: 'Order review'),
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutHeaderButton extends StatelessWidget {
  const _CheckoutHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.14),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                if (showDot)
                  PositionedDirectional(
                    top: 9,
                    end: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.badgeRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartPreview extends StatelessWidget {
  const _CartPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 294,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Image.asset(
              Assets.imagesCart,
              width: 190,
              height: 292,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(top: 26, right: 54, child: _SummaryProductBubble()),
          Positioned(
            top: 88,
            right: 82,
            child: _PlacedProductCard(
              width: 88,
              height: 78,
              angle: -0.04,
              color: const Color(0xFFEAF7FF),
              label: l10n.thailand,
            ),
          ),
          const Positioned(
            top: 166,
            right: 60,
            child: _PlacedProductCard(
              width: 88,
              height: 74,
              angle: -0.08,
              color: Color(0xFFDDEEEB),
              label: 'Digital',
            ),
          ),
          const Positioned(
            top: 158,
            left: 63,
            child: _PlacedProductCard(
              width: 78,
              height: 56,
              angle: 0.14,
              color: Colors.white,
              label: 'Toys',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryProductBubble extends StatelessWidget {
  const _SummaryProductBubble();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 154,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.cartProductTicket,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(
              color: const Color(0xFF4D4D4D),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.dinarPrice(39),
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacedProductCard extends StatelessWidget {
  const _PlacedProductCard({
    required this.width,
    required this.height,
    required this.angle,
    required this.color,
    required this.label,
  });

  final double width;
  final double height;
  final double angle;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(Assets.imagesCart, fit: BoxFit.contain),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF1688E8),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsPanel extends StatelessWidget {
  const _TotalsPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _TotalLine(label: l10n.subtotal, value: 'JO 48,500'),
          const SizedBox(height: 3),
          _TotalLine(label: l10n.discount, value: '0'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: Color(0xFFD6D6D6)),
          ),
          _TotalLine(label: l10n.grandTotal, value: 'JO 48,500', isBold: true),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final weight = isBold ? FontWeight.w800 : FontWeight.w500;
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: isBold ? Colors.black : const Color(0xFF4F5165),
            fontSize: 12,
            fontWeight: weight,
          ),
        ),
        const Spacer(),
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            color: Colors.black,
            fontSize: 12,
            fontWeight: weight,
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF0A8BFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.proceedToCheckout,
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
