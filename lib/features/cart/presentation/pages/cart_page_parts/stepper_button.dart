part of '../cart_page.dart';

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 30,
        height: 34,
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
