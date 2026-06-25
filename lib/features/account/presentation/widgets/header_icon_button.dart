// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../notifications/domain/services/notifications_controller.dart';

class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  const HeaderIconButton({
    super.key,
    required this.icon,
    this.onTap,
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
              if (shouldShowDot) const _HeaderNotificationDot(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderNotificationDot extends StatelessWidget {
  const _HeaderNotificationDot();

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
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
    );
  }
}
