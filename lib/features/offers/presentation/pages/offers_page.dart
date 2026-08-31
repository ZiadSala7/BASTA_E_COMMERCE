// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coupons/presentation/cubits/coupons_cubit.dart';
import '../../../coupons/presentation/widgets/coupon_card.dart';
import '../../../coupons/presentation/widgets/empty_coupons_view.dart';
import '../../../notifications/domain/services/notifications_controller.dart';

part 'offers_page_parts/offers_page.dart';
part 'offers_page_parts/offers_page_state.dart';
part 'offers_page_parts/offers_header_delegate.dart';
part 'offers_page_parts/offers_header.dart';
part 'offers_page_parts/header_icon_button.dart';
part 'offers_page_parts/category_filters.dart';
part 'offers_page_parts/offer_coupon_card.dart';
part 'offers_page_parts/store_avatar.dart';
part 'offers_page_parts/offer_hero_band.dart';
part 'offers_page_parts/filter_action_tile.dart';
part 'offers_page_parts/offer_coupon.dart';
