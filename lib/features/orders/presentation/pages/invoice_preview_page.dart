import 'dart:developer';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';

class InvoicePreviewPage extends StatefulWidget {
  const InvoicePreviewPage({super.key, required this.order});

  final OrderEntity order;

  @override
  State<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends State<InvoicePreviewPage> {
  bool _isSaving = false;

  OrderEntity get order => widget.order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isArabic = l10n.isArabic;
    final address = order.shippingAddress;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.pick(
            ar: 'الفاتورة الإلكترونية',
            en: 'Electronic Invoice',
          ),
          centerTitle: true,
          showSearch: false,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primaryFor(context),
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.pick(ar: 'بسطة', en: 'Basta'),
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accentGreen,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.pick(
                      ar: 'ملخص الفاتورة اعتمادًا على بيانات الطلب',
                      en: 'Invoice summary based on your order details',
                    ),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const Divider(height: 28),
                  _infoRow(
                    context,
                    label: l10n.pick(ar: 'رقم الطلب', en: 'Order number'),
                    value: order.id,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    context,
                    label: l10n.pick(ar: 'تاريخ الطلب', en: 'Order date'),
                    value: order.createdAt == null
                        ? l10n.pick(ar: 'غير متوفر', en: 'Not available')
                        : DateFormat(
                            'yyyy/MM/dd - HH:mm',
                            isArabic ? 'ar' : 'en',
                          ).format(order.createdAt!.toLocal()),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    context,
                    label: l10n.pick(ar: 'طريقة الدفع', en: 'Payment method'),
                    value: _paymentMethod(order.paymentMethod, l10n),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    context,
                    label: l10n.pick(ar: 'حالة الدفع', en: 'Payment status'),
                    value: _paymentStatus(order.paymentStatus, l10n),
                  ),
                  if (address != null && address.fullAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      context,
                      label: l10n.pick(
                        ar: 'عنوان التوصيل',
                        en: 'Delivery address',
                      ),
                      value: address.fullAddress,
                    ),
                  ],
                  const Divider(height: 28),
                  Text(
                    l10n.pick(ar: 'المنتجات', en: 'Items'),
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.pick(
                          ar: 'لا توجد تفاصيل للمنتجات في بيانات هذا الطلب.',
                          en: 'Product details are not available for this order.',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                item.productName,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.quantity} × ${CurrencyHelper.format(item.priceAtPurchase, context: context)}',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              CurrencyHelper.format(
                                item.totalPrice,
                                context: context,
                              ),
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 24),
                  _infoRow(
                    context,
                    label: l10n.pick(ar: 'مجموع المنتجات', en: 'Subtotal'),
                    value: CurrencyHelper.format(
                      order.subtotal,
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    context,
                    label: l10n.pick(ar: 'رسوم التوصيل', en: 'Delivery fee'),
                    value: CurrencyHelper.format(
                      order.shippingCost,
                      context: context,
                    ),
                  ),
                  if (order.discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      context,
                      label: l10n.pick(ar: 'الخصم', en: 'Discount'),
                      value:
                          '- ${CurrencyHelper.format(order.discountAmount, context: context)}',
                      valueColor: AppColors.accentGreen,
                    ),
                  ],
                  const Divider(height: 24),
                  _infoRow(
                    context,
                    label: l10n.pick(ar: 'الإجمالي', en: 'Total'),
                    value: CurrencyHelper.format(order.total, context: context),
                    valueColor: AppColors.primaryFor(context),
                    emphasize: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : () => _downloadInvoice(l10n),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(
                  _isSaving
                      ? l10n.pick(
                          ar: 'جارٍ تجهيز الفاتورة...',
                          en: 'Preparing invoice...',
                        )
                      : l10n.pick(ar: 'تحميل الفاتورة', en: 'Download invoice'),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadInvoice(AppLocalizations l10n) async {
    setState(() => _isSaving = true);
    try {
      final regularFont = await rootBundle.load(
        'assets/fonts/NotoSansArabic-Regular.ttf',
      );
      final boldFont = await rootBundle.load(
        'assets/fonts/NotoSansArabic-Bold.ttf',
      );
      final pdfBytes = await _buildInvoicePdf(
        l10n,
        regularFont: regularFont,
        boldFont: boldFont,
      );
      if (!mounted) return;

      final savedPath = await FileSaver.instance.saveAs(
        name: 'invoice-${_safeFileName(order.id)}',
        bytes: pdfBytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (savedPath == null || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.pick(
              ar: 'تم حفظ الفاتورة على جهازك',
              en: 'Invoice saved to your device',
            ),
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'Download order invoice failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.pick(
              ar: 'تعذر حفظ الفاتورة. حاول مرة أخرى.',
              en: 'Could not save the invoice. Please try again.',
            ),
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<Uint8List> _buildInvoicePdf(
    AppLocalizations l10n, {
    required ByteData regularFont,
    required ByteData boldFont,
  }) async {
    final isArabic = l10n.isArabic;
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(regularFont),
        bold: pw.Font.ttf(boldFont),
      ),
    );
    final rows = <pw.Widget>[
      _pdfRow(l10n.pick(ar: 'رقم الطلب', en: 'Order number'), order.id),
      _pdfRow(
        l10n.pick(ar: 'تاريخ الطلب', en: 'Order date'),
        order.createdAt == null
            ? l10n.pick(ar: 'غير متوفر', en: 'Not available')
            : DateFormat(
                'yyyy/MM/dd - HH:mm',
                isArabic ? 'ar' : 'en',
              ).format(order.createdAt!.toLocal()),
      ),
      _pdfRow(
        l10n.pick(ar: 'طريقة الدفع', en: 'Payment method'),
        _paymentMethod(order.paymentMethod, l10n),
      ),
      _pdfRow(
        l10n.pick(ar: 'حالة الدفع', en: 'Payment status'),
        _paymentStatus(order.paymentStatus, l10n),
      ),
    ];

    final address = order.shippingAddress;
    if (address != null && address.fullAddress.isNotEmpty) {
      rows.add(
        _pdfRow(
          l10n.pick(ar: 'عنوان التوصيل', en: 'Delivery address'),
          address.fullAddress,
        ),
      );
    }

    rows.addAll([
      pw.SizedBox(height: 16),
      pw.Text(
        l10n.pick(ar: 'المنتجات', en: 'Items'),
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
      ),
      pw.Divider(),
    ]);

    if (order.items.isEmpty) {
      rows.add(
        pw.Text(
          l10n.pick(
            ar: 'لا توجد تفاصيل للمنتجات في بيانات هذا الطلب.',
            en: 'Product details are not available for this order.',
          ),
        ),
      );
    } else {
      for (final item in order.items) {
        rows.add(
          _pdfRow(
            '${item.productName} (${item.quantity} × ${_formatAmount(item.priceAtPurchase, l10n)})',
            _formatAmount(item.totalPrice, l10n),
          ),
        );
      }
    }

    rows.addAll([
      pw.Divider(),
      _pdfRow(
        l10n.pick(ar: 'مجموع المنتجات', en: 'Subtotal'),
        _formatAmount(order.subtotal, l10n),
      ),
      _pdfRow(
        l10n.pick(ar: 'رسوم التوصيل', en: 'Delivery fee'),
        _formatAmount(order.shippingCost, l10n),
      ),
    ]);
    if (order.discountAmount > 0) {
      rows.add(
        _pdfRow(
          l10n.pick(ar: 'الخصم', en: 'Discount'),
          '- ${_formatAmount(order.discountAmount, l10n)}',
        ),
      );
    }
    rows.addAll([
      pw.Divider(),
      _pdfRow(
        l10n.pick(ar: 'الإجمالي', en: 'Total'),
        _formatAmount(order.total, l10n),
        emphasized: true,
      ),
    ]);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => [
          pw.Text(
            l10n.pick(ar: 'الفاتورة الإلكترونية', en: 'Electronic Invoice'),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            l10n.pick(ar: 'بسطة', en: 'Basta'),
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Divider(height: 28),
          ...rows,
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value, {bool emphasized = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: emphasized ? 13 : 10,
                  fontWeight: emphasized ? pw.FontWeight.bold : null,
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: emphasized ? 14 : 10,
                fontWeight: emphasized ? pw.FontWeight.bold : null,
              ),
            ),
          ],
        ),
      );

  String _formatAmount(num amount, AppLocalizations l10n) {
    final formatted = amount.toStringAsFixed(2);
    return l10n.isArabic ? '$formatted د.أ' : 'JD $formatted';
  }

  String _safeFileName(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');
    return cleaned.isEmpty ? 'order' : cleaned;
  }

  String _paymentMethod(String value, AppLocalizations l10n) {
    if (value.toUpperCase() == 'CARD') {
      return l10n.pick(ar: 'بطاقة بنكية', en: 'Bank card');
    }
    if (value.toUpperCase() == 'COD') {
      return l10n.pick(ar: 'الدفع عند الاستلام', en: 'Cash on delivery');
    }
    return value;
  }

  String _paymentStatus(String value, AppLocalizations l10n) {
    switch (value.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
        return l10n.pick(ar: 'مدفوع', en: 'Paid');
      case 'FAILED':
      case 'CANCELLED':
        return l10n.pick(ar: 'غير مكتمل', en: 'Failed');
      default:
        return l10n.pick(ar: 'قيد الانتظار', en: 'Pending');
    }
  }

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool emphasize = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: emphasize ? 15 : 12,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.cairo(
              fontSize: emphasize ? 17 : 12,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              color: valueColor ?? colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
