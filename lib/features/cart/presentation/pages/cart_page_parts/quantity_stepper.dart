part of '../cart_page.dart';

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: onDecrement),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: AppColors.primaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}
