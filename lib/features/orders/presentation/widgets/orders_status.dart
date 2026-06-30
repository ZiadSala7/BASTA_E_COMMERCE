import 'package:flutter/material.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

enum OrdersStatusFilter { all, pending, delivering, delivered }

OrdersStatusFilter orderStatusFilter(String status) {
  final value = _normalized(status);
  if (value.contains('delivered') ||
      value.contains('completed') ||
      value.contains('complete')) {
    return OrdersStatusFilter.delivered;
  }
  if (value.contains('deliver') ||
      value.contains('shipping') ||
      value.contains('shipped') ||
      value.contains('outfordelivery') ||
      value.contains('processing') ||
      value.contains('confirmed')) {
    return OrdersStatusFilter.delivering;
  }
  return OrdersStatusFilter.pending;
}

String orderStatusLabel(AppLocalizations l10n, String status) {
  return switch (orderStatusFilter(status)) {
    OrdersStatusFilter.delivered => l10n.delivered,
    OrdersStatusFilter.delivering => l10n.delivering,
    OrdersStatusFilter.pending => l10n.pending,
    OrdersStatusFilter.all => status.isEmpty ? l10n.pending : status,
  };
}

Color orderStatusColor(String status) {
  return switch (orderStatusFilter(status)) {
    OrdersStatusFilter.delivered => AppColors.primary,
    OrdersStatusFilter.delivering => Colors.orange,
    OrdersStatusFilter.pending => Colors.blue,
    OrdersStatusFilter.all => Colors.blueGrey,
  };
}

String _normalized(String status) {
  return status.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
}
