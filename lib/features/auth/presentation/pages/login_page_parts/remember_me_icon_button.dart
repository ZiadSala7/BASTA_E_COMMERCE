part of '../login_page.dart';

class _RememberMeIconButton extends StatelessWidget {
  final bool value;
  final VoidCallback onPressed;

  const _RememberMeIconButton({required this.value, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 28),
      icon: Icon(
        value ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
        color: value ? const Color(0xFF1800AD) : const Color(0xFFB1B4C8),
        size: 34,
      ),
    );
  }
}
