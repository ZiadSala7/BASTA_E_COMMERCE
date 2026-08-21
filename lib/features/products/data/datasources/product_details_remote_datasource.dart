import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/product_model.dart';

abstract class ProductDetailsRemoteDataSource {
  Future<ProductModel> getProductDetails(String slugOrId);
}

class ProductDetailsRemoteDataSourceImpl
    implements ProductDetailsRemoteDataSource {
  final DioConsumer _dioConsumer;

  const ProductDetailsRemoteDataSourceImpl({
    required DioConsumer dioConsumer,
  }) : _dioConsumer = dioConsumer;

  @override
  Future<ProductModel> getProductDetails(String slugOrId) async {
    final cleanSlug = slugOrId.trim();
    if (cleanSlug.isEmpty) {
      throw Exception('Product slug or ID cannot be empty.');
    }

    try {
      final response = await _dioConsumer.get(
        Endpoints.productDetails(cleanSlug),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ProductModel.fromJson(data);
      }
      if (data is Map) {
        return ProductModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw Exception('Invalid response format for product details.');
    } on DioException catch (error, stackTrace) {
      log(
        'Get product details request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(
        _messageFromDio(error, fallback: 'Could not load product details.'),
      );
    } catch (error, stackTrace) {
      log(
        'Unexpected error getting product details',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Could not load product details: $error');
    }
  }

  String _messageFromDio(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message.trim();

      final errorValue = data['error']?.toString();
      if (errorValue != null && errorValue.trim().isNotEmpty) {
        return errorValue.trim();
      }
    }

    if (error.response?.statusCode == 404) {
      return 'Product not found.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your internet connection.';
    }

    return error.message ?? fallback;
  }
}
