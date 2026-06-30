import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

String orderDateLabel(BuildContext context, DateTime? date) {
  if (date == null) return '-';
  final locale = AppLocalizations.of(context)!.localeName;
  return DateFormat.yMMMd(locale).format(date.toLocal());
}
