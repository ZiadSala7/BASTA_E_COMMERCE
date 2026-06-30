part of '../notifications_page.dart';

class _StatusBadge extends StatelessWidget {
  final String type;

  const _StatusBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(type);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(_iconForType(type), color: accent, size: 23),
    );
  }
}
