import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentWebViewBody extends StatelessWidget {
  const PaymentWebViewBody({
    required this.controller,
    required this.isLoading,
    required this.onClose,
    super.key,
  });

  final WebViewController controller;
  final bool isLoading;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pick(ar: 'الدفع بالبطاقة', en: 'Card payment')),
        leading: IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }
}
