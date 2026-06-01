// ******************* FILE INFO *******************
// File Name: contact_us_page.dart  (public-facing website page)
// Created by: Amr Mesbah
// UPDATED: Full redesign to match Figma — Client/Owner toggle,
//          illustration left panel, Personal Info + Salon Info sections,
//          pink selectable option cards, simplified success dialog.
//          PRIMARY COLOR: Fully dynamic from HomeCmsCubit branding.
//          OTP verification via Twilio before form submission.
//          SendGrid sends emails on submit.
//          Full AR / EN bilingual support with RTL/LTR.
//          All sizes normalized to match main.dart ScreenUtil design sizes:
//          Desktop (≥1366) → 1366×768, Tablet (768–1365) → 1024×768,
//          Mobile (<768)   → 375×812
//          UPDATED: Prefix SVG icons on all dropdowns (mobile + desktop)
//          UPDATED: Reason dropdown now populated from CMS data
//                   (clientDescription.reasons / ownerDescription.reasons)
//                   Description text from CMS clientDescription / ownerDescription
//          FIXED: cmsData was never assigned from cmsState — all CMS fields now render
//          FIXED: title, subtitle, SVG now read from Firebase, no static fallback shown
//                 unless Firebase field is empty
//          UPDATED: Gender + Country dropdowns now shown for ALL users (client & owner)
//                   per Figma design — moved out of owner-only section into Personal Info
//          FIXED: Tablet overflow in title/subtitle row — wrapped in Flexible
//          UPDATED: Phone field replaced with demo-page style
//                   (label row with SVG prefix + code picker + text field)
//          UPDATED: Primary color is now gender-aware — uses malePrimaryColor when
//                   GenderCubit reports male, primaryColor when female.

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui_web' as ui_web;

import 'package:beauty_user/core/widgets/button.dart';
import 'package:beauty_user/core/widgets/circle_progress.dart';
import 'package:beauty_user/core/widgets/custom_dropdown.dart';
import 'package:beauty_user/core/widgets/textfield.dart';

import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/constant.dart';
import '../../../../../core/custom_tab.dart';
import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';
import '../../../../home/presentation/controller/gender_cubit.dart';
import '../../../../home/presentation/controller/gender_state.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../../overview/presentation/controller/overview_cubit.dart';
import '../../../../overview/presentation/controller/overview_state.dart';
import '../../../data/models/contact_us_location_model.dart';
import '../../../data/models/contact_us_model.dart';
import '../../controller/contact_us_otp_cubit.dart';
import '../../controller/contact_us_otp_state.dart';
import '../../controller/contact_us_location_cubit.dart';
import '../../controller/contact_us_location_state.dart';
import '../../controller/contact_us_cubit.dart';
import '../../controller/contact_us_state.dart';

part '../widgets/contact_us_page/breakpoints.dart';
part '../widgets/contact_us_page/reveal_coordinator.dart';
part '../widgets/contact_us_page/reveal_coordinator_widget.dart';
part '../widgets/contact_us_page/reveal.dart';
part '../widgets/contact_us_page/svg_pulse_loader.dart';
part '../widgets/contact_us_page/contact_page_view.dart';
part '../widgets/contact_us_page/otp_dialog.dart';
part '../widgets/contact_us_page/success_dialog.dart';
part '../widgets/contact_us_page/desktop_body.dart';
part '../widgets/contact_us_page/form_card.dart';
part '../widgets/contact_us_page/desktop_icon_field.dart';
part '../widgets/contact_us_page/dropdown_field.dart';
part '../widgets/contact_us_page/demo_style_phone_field.dart';
part '../widgets/contact_us_page/section_header.dart';
part '../widgets/contact_us_page/form_label.dart';
part '../widgets/contact_us_page/left_illustration_panel.dart';
part '../widgets/contact_us_page/mobile_body.dart';
part '../widgets/contact_us_page/mobile_toggle.dart';
part '../widgets/contact_us_page/mobile_description_text.dart';
part '../widgets/contact_us_page/mobile_icon_field.dart';
part '../widgets/contact_us_page/mobile_icon_dropdown.dart';
part '../widgets/contact_us_page/demo_style_mobile_phone_field.dart';
part '../widgets/contact_us_page/social_media_section.dart';
part '../widgets/contact_us_page/social_icon_widget.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ContactUsCmsCubit>(
          create: (_) {

            return ContactUsCmsCubit()..load();
          },
        ),
        BlocProvider(create: (_) => ContactCubit()),
        BlocProvider(create: (_) => ContactOtpCubit()),

        // ── ADD THIS ──────────────────────────────────────────────────────
        BlocProvider.value(
          value: context.read<OverviewCmsCubit>(),
        ),
        // ─────────────────────────────────────────────────────────────────
      ],
      child: const _ContactPageView(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE VIEW
// ═══════════════════════════════════════════════════════════════════════════════
