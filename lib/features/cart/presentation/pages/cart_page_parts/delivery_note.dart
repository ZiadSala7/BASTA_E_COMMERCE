part of '../cart_page.dart';

class _DeliveryNote extends StatelessWidget {
  const _DeliveryNote({required this.message, required this.estimatedDate});

  final String message;
  final String estimatedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB7E8DE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF0F8D7D),
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estimatedDate,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF075E54),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF136C61),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
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
