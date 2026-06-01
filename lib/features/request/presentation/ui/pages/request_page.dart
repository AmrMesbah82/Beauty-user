/// ******************* FILE INFO *******************
/// File Name: request_demo_page.dart
/// UPDATED: Gender-aware primary color — uses malePrimaryColor when GenderCubit
///          reports male, primaryColor when female. mainWidgetColor applied to
///          all card/container backgrounds, matching our_products_page.dart pattern.
/// UPDATED: Field/dropdown height increased by 10 (36 → 46).
/// UPDATED: City list is now filtered based on selected country, with expanded
///          city data per country.

import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_user/core/widgets/circle_progress.dart';
import 'package:beauty_user/core/widgets/custom_dropdown.dart';
import 'package:beauty_user/core/widgets/textfield.dart';

import '../../../../../core/main_widgets/app_page_shell.dart';
import '../../../../../core/theme/app_font_style.dart';
import '../../../../home/presentation/controller/gender_cubit.dart';
import '../../../../home/presentation/controller/gender_state.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../data/models/request_model.dart';
import '../../controller/request_cubit.dart';
import '../../controller/request_state.dart';

part '../widgets/request_page/submit_state.dart';
part '../widgets/request_page/submit_initial.dart';
part '../widgets/request_page/submit_loading.dart';
part '../widgets/request_page/submit_success.dart';
part '../widgets/request_page/submit_error.dart';
part '../widgets/request_page/submit_cubit.dart';
part '../widgets/request_page/c.dart';
part '../widgets/request_page/s.dart';
part '../widgets/request_page/inner.dart';
part '../widgets/request_page/form_screen.dart';
part '../widgets/request_page/confirm_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUBMIT — STATE
// ════════════════════════════════════════════════════════════════════════════

class RequestDemoPage extends StatelessWidget {
  final String gender;
  const RequestDemoPage({super.key, this.gender = 'female'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _SubmitCubit(),
      child: _Inner(gender: gender),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _INNER — resolves colors from HomeCmsCubit + GenderCubit
// ════════════════════════════════════════════════════════════════════════════
