part of '../offers_page.dart';

class _StoreAvatar extends StatelessWidget {
  final _OfferCoupon offer;

  const _StoreAvatar({required this.offer});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 28;
    const double iconSize = 14;

    return Center(
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [offer.accent.withOpacity(0.24), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(offer.icon, color: offer.accent, size: iconSize),
      ),
    );
  }
}
