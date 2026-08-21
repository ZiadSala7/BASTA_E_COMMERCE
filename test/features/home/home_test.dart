import 'package:busta/features/home/data/models/home_banner_model.dart';
import 'package:busta/features/home/data/models/home_store_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home Integration according to FLUTTER_FULL_CLIENT_BACKEND_DOCUMENTATION.md', () {
    test('HomeBannerModel parses /api/banners payload correctly', () {
      final json = {
        "id": "banner-001",
        "title": "Fresh Italian Pasta Weekend Sale",
        "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/banner1.jpg",
        "targetUrl": "/products/handmade-artisan-fettuccine"
      };

      final banner = HomeBannerModel.fromJson(json);
      expect(banner.id, 'banner-001');
      expect(banner.title, 'Fresh Italian Pasta Weekend Sale');
      expect(banner.imageUrl, 'https://res.cloudinary.com/pasta/image/upload/v1/banner1.jpg');
      expect(banner.targetUrl, '/products/handmade-artisan-fettuccine');
    });

    test('HomeStoreModel parses store details correctly', () {
      final json = {
        "id": "store-101",
        "name": "La Pasta Bella",
        "slug": "la-pasta-bella",
        "description": "Authentic Italian fresh pasta store in Amman",
        "logoUrl": "https://res.cloudinary.com/pasta/image/upload/v1/logo.png",
        "bannerUrl": "https://res.cloudinary.com/pasta/image/upload/v1/store-banner.jpg",
        "rating": 4.8
      };

      final store = HomeStoreModel.fromJson(json);
      expect(store.id, 'store-101');
      expect(store.name, 'La Pasta Bella');
      expect(store.slug, 'la-pasta-bella');
      expect(store.description, 'Authentic Italian fresh pasta store in Amman');
    });
  });
}
