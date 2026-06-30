import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/home_store_entity.dart';
import '../../domain/usecases/get_home_stores_usecase.dart';
import '../../../products/presentation/pages/products_listing_page.dart';

part 'stores_listing_page_parts/stores_listing_page.dart';
part 'stores_listing_page_parts/stores_listing_page_state.dart';
part 'stores_listing_page_parts/store_listing_card.dart';
part 'stores_listing_page_parts/store_search_field.dart';
part 'stores_listing_page_parts/store_icon.dart';
