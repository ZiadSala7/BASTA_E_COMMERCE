part of '../products_page.dart';

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: Material(
        color: Colors.white.withOpacity(0.14),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}
