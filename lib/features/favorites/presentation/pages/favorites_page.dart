import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/entities/home_product_entity.dart';
import '../../../products/presentation/pages/product_detail_page.dart';
import '../../domain/services/favorites_controller.dart';

part 'favorites_page_parts/favorites_page.dart';
part 'favorites_page_parts/favorites_page_state.dart';
