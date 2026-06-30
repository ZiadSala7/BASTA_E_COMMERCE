import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class OrdersTabBar extends StatelessWidget {
  const OrdersTabBar({required this.controller, super.key});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelColor: AppColors.primary,
          unselectedLabelColor: colors.onSurfaceVariant,
          labelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: [
            l10n.all,
            l10n.pending,
            l10n.delivering,
            l10n.delivered,
          ].map((label) => Tab(text: label)).toList(),
        ),
      ),
    );
  }
}
