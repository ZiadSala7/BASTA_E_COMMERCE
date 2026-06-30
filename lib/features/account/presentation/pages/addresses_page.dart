import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/location_picker_page.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/saved_addresses_local_datasource.dart';
import '../../data/models/saved_address_model.dart';

part 'addresses_page_parts/addresses_page.dart';
part 'addresses_page_parts/addresses_page_state.dart';
part 'addresses_page_parts/address_card.dart';
part 'addresses_page_parts/default_badge.dart';
part 'addresses_page_parts/address_editor_sheet.dart';
part 'addresses_page_parts/address_editor_sheet_state.dart';
part 'addresses_page_parts/address_text_field.dart';
part 'addresses_page_parts/address_action.dart';
