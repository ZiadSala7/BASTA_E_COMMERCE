part of '../offers_page.dart';

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showDot && sl.isRegistered<NotificationsController>()) {
      final controller = sl<NotificationsController>();
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildButton(controller.hasUnread),
      );
    }

    return _buildButton(false);
  }

  Widget _buildButton(bool shouldShowDot) {
    return Material(
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
              if (shouldShowDot)
                PositionedDirectional(
                  top: 9,
                  end: 9,
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
    );
  }
}
