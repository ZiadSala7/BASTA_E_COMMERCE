import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import '../../../home/domain/entities/home_product_entity.dart';
import '../../../home/domain/usecases/get_home_products_usecase.dart';
import '../models/product_detail_args.dart';
import '../pages/product_detail_page.dart' show ProductDetailPage;

part 'related_products_section_parts/related_products_section.dart';
part 'related_products_section_parts/related_products_section_state.dart';
