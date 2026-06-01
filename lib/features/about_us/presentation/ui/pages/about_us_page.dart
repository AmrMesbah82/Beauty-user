// ******************* FILE INFO *******************
// File Name: about_us_page.dart
// Contains: Tab 0 (About Us) and Tab 1 (Our Strategy)
// UPDATED: Split from original about_us_page.dart — UI unchanged
// UPDATED: Added headings SVG hero banner display from model.svgUrl
// UPDATED: Fixed Row layout — SVG + title now render side by side correctly
// FIXED:   AboutPage + _AboutPageView now accept initialTab (String) so that
//          Navigator.push() from the footer deep-links to the correct tab
//          without relying on GoRouterState (which is unavailable outside the
//          GoRouter widget tree).
// FIXED:   Hero Row now explicitly builds LTR vs RTL child order so SVG and
//          title always align correctly regardless of language direction.
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
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:beauty_user/core/custom_svg.dart';

import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/new_theme.dart';

import '../../../../home/data/models/home_model.dart';
import '../../../../home/presentation/controller/gender_cubit.dart';
import '../../../../home/presentation/controller/gender_state.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../data/models/about_us_model.dart';
import '../../controller/about_us_cubit.dart';
import '../../controller/about_us_state.dart';

part '../widgets/about_us_page/about_helpers.dart';
part '../widgets/about_us_page/reveal_coordinator.dart';
part '../widgets/about_us_page/reveal_coordinator_widget.dart';
part '../widgets/about_us_page/reveal.dart';
part '../widgets/about_us_page/svg_pulse_loader.dart';
part '../widgets/about_us_page/about_page_view.dart';
part '../widgets/about_us_page/headings_svg_desktop.dart';
part '../widgets/about_us_page/headings_svg_mobile.dart';
part '../widgets/about_us_page/about_header_desktop.dart';
part '../widgets/about_us_page/about_header_mobile.dart';
part '../widgets/about_us_page/about_body_desktop.dart';
part '../widgets/about_us_page/desktop_top_tab_item.dart';
part '../widgets/about_us_page/desktop_tab_item.dart';
part '../widgets/about_us_page/desktop_right_panel.dart';
part '../widgets/about_us_page/value_detail_panel.dart';
part '../widgets/about_us_page/values_grid_desktop.dart';
part '../widgets/about_us_page/value_grid_card.dart';
part '../widgets/about_us_page/about_body_mobile.dart';
part '../widgets/about_us_page/mobile_top_tab_item.dart';
part '../widgets/about_us_page/mobile_about_us_content.dart';
part '../widgets/about_us_page/mobile_tab_data.dart';
part '../widgets/about_us_page/mobile_accordion_item.dart';
part '../widgets/about_us_page/values_grid_mobile.dart';

const Color _kDefaultGreen = Color(0xFFD16F9A);
const Color _kGreenLight = Color(0xFFE8F5EE);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kDivider = Color(0xFFDDE8DD);
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class AboutPage extends StatelessWidget {
  final String initialTab;

  const AboutPage({super.key, this.initialTab = ''});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AboutCubit()..load()),
        BlocProvider(create: (_) => StrategyCubit()..load()),
      ],
      child: _AboutPageView(initialTab: initialTab),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _AboutPageView
// ══════════════════════════════════════════════════════════════════════════════
