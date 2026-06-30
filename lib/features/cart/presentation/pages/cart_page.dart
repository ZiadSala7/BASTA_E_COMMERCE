// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/services/cart_badge_controller.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import 'cart_checkout_page.dart';

part 'cart_page_parts/cart_page.dart';
part 'cart_page_parts/cart_page_state.dart';
part 'cart_page_parts/cart_product.dart';
part 'cart_page_parts/indexed_cart_product.dart';
part 'cart_page_parts/vendor_cart_group.dart';
part 'cart_page_parts/vendor_cart_section.dart';
part 'cart_page_parts/cart_header.dart';
part 'cart_page_parts/header_icon_button.dart';
part 'cart_page_parts/header_metric.dart';
part 'cart_page_parts/order_readiness_panel.dart';
part 'cart_page_parts/readiness_chip.dart';
part 'cart_page_parts/section_title.dart';
part 'cart_page_parts/cart_item_card.dart';
part 'cart_page_parts/swipe_delete_background.dart';
part 'cart_page_parts/product_image.dart';
part 'cart_page_parts/cart_item_details.dart';
part 'cart_page_parts/round_icon_button.dart';
part 'cart_page_parts/quantity_stepper.dart';
part 'cart_page_parts/stepper_button.dart';
part 'cart_page_parts/legacy_coupon_card.dart';
part 'cart_page_parts/backend_coupon_card.dart';
part 'cart_page_parts/delivery_note.dart';
part 'cart_page_parts/cart_checkout_summary.dart';
part 'cart_page_parts/summary_row.dart';
