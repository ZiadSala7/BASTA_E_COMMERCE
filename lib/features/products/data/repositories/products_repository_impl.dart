import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/product_details_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductDetailsRemoteDataSource _remoteDataSource;

  const ProductsRepositoryImpl({
    required ProductDetailsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<ProductEntity> getProductDetails(String slugOrId) {
    return _remoteDataSource.getProductDetails(slugOrId);
  }
}
