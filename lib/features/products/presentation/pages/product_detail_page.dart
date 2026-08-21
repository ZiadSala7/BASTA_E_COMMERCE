import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/usecases/add_cart_item_usecase.dart';
import '../../../cart/presentation/pages/cart_checkout_page.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/usecases/add_product_review_usecase.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import '../../domain/usecases/get_product_reviews_usecase.dart';
import '../models/product_detail_args.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/description_section.dart';
import '../widgets/product_detail_states.dart';
import '../widgets/product_header.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_variant_selector.dart';
import '../widgets/related_products_section.dart';
import '../widgets/reviews_section.dart';

export '../models/product_detail_args.dart';

part 'product_detail_page_parts/product_detail_page.dart';
part 'product_detail_page_parts/product_detail_page_state.dart';
