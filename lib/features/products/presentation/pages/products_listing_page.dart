import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/common/selectable_tile.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/usecases/add_cart_item_usecase.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import '../../../home/domain/entities/home_product_entity.dart';
import '../../../home/domain/usecases/get_home_products_usecase.dart';
import 'product_detail_page.dart';

part 'products_listing_page_parts/products_listing_args.dart';
part 'products_listing_page_parts/products_listing_page.dart';
part 'products_listing_page_parts/products_listing_page_state.dart';
part 'products_listing_page_parts/active_filters_bar.dart';
part 'products_listing_page_parts/filter_bottom_sheet.dart';
part 'products_listing_page_parts/filter_bottom_sheet_state.dart';
