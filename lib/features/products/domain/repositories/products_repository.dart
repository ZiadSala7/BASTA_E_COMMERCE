import '../entities/product_entity.dart';

abstract class ProductsRepository {
  Future<ProductEntity> getProductDetails(String slugOrId);
}
