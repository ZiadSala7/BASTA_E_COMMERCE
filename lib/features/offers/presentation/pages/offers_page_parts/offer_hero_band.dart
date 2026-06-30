part of '../offers_page.dart';

class _OfferHeroBand extends StatelessWidget {
  final _OfferCoupon offer;

  const _OfferHeroBand({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: offer.imageColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -8,
            left: -6,
            child: Icon(
              offer.icon,
              color: Colors.white.withOpacity(0.16),
              size: 40,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Text(
                'HOT',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(offer.icon, color: offer.accent, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
