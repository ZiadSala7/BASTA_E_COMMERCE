import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/auth_message_response.dart';
import '../models/change_password_request.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/profile_update_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/reset_password_request.dart';
import '../models/social_login_request.dart';
import '../models/update_profile_request.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource_parts/auth_remote_data_source.dart';
part 'auth_remote_datasource_parts/auth_remote_data_source_impl.dart';
