import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderMeta extends StatelessWidget {
  const OrderMeta({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.cairo(fontSize: 13, color: color)),
      ],
    );
  }
}
