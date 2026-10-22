import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/api_keys.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/order_model.dart';
import 'orders_dio_error.dart';
import 'orders_response_parser.dart';

class OrdersApiClient {
  const OrdersApiClient(this._dio);

  final DioConsumer _dio;

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dio.get(Endpoints.myOrders);
      return ordersDataList(response.data)
          .whereType<Map>()
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error, stackTrace) {
      log('Get my orders request failed', error: error, stackTrace: stackTrace);
      throw Exception(ordersDioMessage(error));
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await _dio.get(Endpoints.orderDetails(orderId));
      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data is Map
                ? Map<String, dynamic>.from(response.data as Map)
                : <String, dynamic>{});

      final orderData = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      return OrderModel.fromJson(orderData);
    } on DioException catch (error, stackTrace) {
      log('Get order by id failed', error: error, stackTrace: stackTrace);
      throw Exception(ordersDioMessage(error));
    }
  }

  Future<String?> getOrderInvoiceUrl(String orderId) async {
    try {
      final response = await _dio.get(Endpoints.orderInvoice(orderId));
      return _extractInvoiceUrl(response.data);
    } on DioException catch (error, stackTrace) {
      log(
        'Get order invoice link failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(ordersDioMessage(error));
    }
  }

  Future<List<int>?> downloadOrderInvoice(String orderId) async {
    final Response<List<int>> response;
    try {
      response = await _dio.dio.get<List<int>>(
        Endpoints.orderInvoice(orderId),
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (error, stackTrace) {
      log(
        'Download order invoice request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(ordersDioMessage(error));
    }

    final responseBytes = response.data;
    if (responseBytes == null || responseBytes.isEmpty) return null;
    if (_isPdf(responseBytes)) return responseBytes;

    final responseText = utf8
        .decode(responseBytes, allowMalformed: true)
        .trim();
    dynamic responseBody;
    try {
      responseBody = jsonDecode(responseText);
    } on FormatException {
      if (_isInvoiceUrl(responseText)) {
        return _downloadInvoiceFile(responseText);
      }
      throw const FormatException(
        'The invoice response is neither a PDF nor an invoice link.',
      );
    }

    final invoiceUrl = _extractInvoiceUrl(responseBody);
    if (invoiceUrl == null || invoiceUrl.trim().isEmpty) return null;
    return _downloadInvoiceFile(invoiceUrl);
  }

  String? _extractInvoiceUrl(dynamic response) {
    if (response is String) {
      final value = response.trim();
      return _isInvoiceUrl(value) ? value : null;
    }

    final body = _asMap(response);
    final data = _asMap(body['data']);
    final invoice = _asMap(body['invoice']);
    final dataInvoice = _asMap(data['invoice']);
    final candidates = [
      body['data'],
      body['invoiceUrl'],
      body['invoice_url'],
      body['pdfUrl'],
      body['downloadUrl'],
      body['download_url'],
      body['url'],
      body['invoice'],
      data['invoiceUrl'],
      data['invoice_url'],
      data['pdfUrl'],
      data['downloadUrl'],
      data['download_url'],
      data['url'],
      data['invoice'],
      invoice['url'],
      invoice['invoiceUrl'],
      invoice['invoice_url'],
      invoice['pdfUrl'],
      invoice['downloadUrl'],
      invoice['download_url'],
      dataInvoice['url'],
      dataInvoice['invoiceUrl'],
      dataInvoice['invoice_url'],
      dataInvoice['pdfUrl'],
      dataInvoice['downloadUrl'],
      dataInvoice['download_url'],
    ];

    for (final candidate in candidates) {
      if (candidate is String) {
        final value = candidate.trim();
        if (_isInvoiceUrl(value)) return value;
      }
    }
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  bool _isInvoiceUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || value.isEmpty) return false;
    if (uri.hasScheme) {
      return uri.scheme == 'https' || uri.scheme == 'http';
    }
    return value.startsWith('/') ||
        value.contains('/') ||
        uri.path.toLowerCase().endsWith('.pdf');
  }

  bool _isPdf(List<int> bytes) =>
      bytes.length >= 5 && String.fromCharCodes(bytes.take(5)) == '%PDF-';

  Future<List<int>?> _downloadInvoiceFile(String invoiceUrl) async {
    final parsedUrl = Uri.tryParse(invoiceUrl.trim());
    if (parsedUrl == null) throw const FormatException('Invalid invoice URL.');
    final invoiceUri = parsedUrl.hasScheme
        ? parsedUrl
        : Uri.parse(ApiKeys.baseUrl).resolve(invoiceUrl.trim());
    if (invoiceUri.scheme != 'https' && invoiceUri.scheme != 'http') {
      throw const FormatException('Unsupported invoice URL scheme.');
    }

    final apiUri = Uri.parse(ApiKeys.baseUrl);
    final client = invoiceUri.origin == apiUri.origin ? _dio.dio : Dio();
    final Response<List<int>> response;
    try {
      response = await client.get<List<int>>(
        invoiceUri.toString(),
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (error, stackTrace) {
      log('Download invoice file failed', error: error, stackTrace: stackTrace);
      throw Exception(ordersDioMessage(error));
    }

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) return null;
    if (!_isPdf(bytes)) {
      throw const FormatException('The invoice response is not a PDF.');
    }
    return bytes;
  }
}
