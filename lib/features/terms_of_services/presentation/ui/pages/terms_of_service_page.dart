// ******************* FILE INFO *******************
// File Name: terms_of_service_page.dart
// Contains: Tab 0 (Terms and Conditions) and Tab 1 (Privacy Policy)
// UPDATED: Added initialTab parameter support for direct navigation
// FIXED:   Download buttons now show language-aware label and URL
//          AR mode → Arabic PDF button only
//          EN mode → English PDF button only
// FIXED:   svgUrl now passed to _TermsHeaderDesktop and _TermsHeaderMobile
// UPDATED: Primary color is now gender-aware — uses malePrimaryColor when
//          GenderCubit reports male, primaryColor when female.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:beauty_user/core/custom_svg.dart';

import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';

import '../../../../about_us/data/models/about_us_model.dart';
import '../../../../about_us/presentation/controller/about_us_cubit.dart';
import '../../../../about_us/presentation/controller/about_us_state.dart';
import '../../../../home/data/models/home_model.dart';
import '../../../../home/presentation/controller/gender_cubit.dart';
import '../../../../home/presentation/controller/gender_state.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';

part '../widget/terms_of_service_page/b_p.dart';
part '../widget/terms_of_service_page/reveal_coordinator.dart';
part '../widget/terms_of_service_page/reveal_coordinator_widget.dart';
part '../widget/terms_of_service_page/reveal.dart';
part '../widget/terms_of_service_page/svg_pulse_loader.dart';
part '../widget/terms_of_service_page/terms_of_service_page_view.dart';
part '../widget/terms_of_service_page/terms_header_desktop.dart';
part '../widget/terms_of_service_page/terms_header_mobile.dart';
part '../widget/terms_of_service_page/terms_body_desktop.dart';
part '../widget/terms_of_service_page/desktop_top_tab_item.dart';
part '../widget/terms_of_service_page/terms_body_mobile.dart';
part '../widget/terms_of_service_page/mobile_top_tab_item.dart';
part '../widget/terms_of_service_page/mobile_doc_panel.dart';

const Color _kDefaultGreen = Color(0xFFD16F9A);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kDivider = Color(0xFFDDE8DD);
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class TermsOfServicePage extends StatelessWidget {
  final String initialTab;

  const TermsOfServicePage({super.key, this.initialTab = ''});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TermsCubit()..load()),
      ],
      child: _TermsOfServicePageView(initialTab: initialTab),
    );
  }
}
