// ******************* FILE INFO *******************
// File Name: overview_page.dart
// Description: Overview Page for the Beauty App (Bayanatz).
//              Sections: Overview, Top Services, Gallery, Client Testimonials, Download.
//              ALL content is CMS-driven via OverviewCmsCubit / OverviewPageModel.
// Created by: Claude for Amr Mesbah
// Updated: 12/04/2026
// UPDATED: Applied identical XHR-cache loader + _SvgPulseLoader + _RevealCoordinator
//          + _Reveal animation system from about_us_page.dart — UI/sections unchanged.
// FIXED:   1) Removed Expanded from _TestimonialCard feedback text (mobile crash)
//          2) Services section: always horizontal scroll row, no Wrap
//          3) Gallery: half-size images on mobile (< 600px)
// ✅ UPDATED: Primary color is now gender-aware — uses malePrimaryColor when
//             GenderCubit reports male, primaryColor when female.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:beauty_user/core/widgets/format.dart';
import 'package:beauty_user/core/widgets/navigator.dart';
import 'package:beauty_user/features/our_product/presentation/ui/pages/our_products_page.dart' hide FormatHelper;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui_web' as ui_web;
import 'dart:convert';

import '../../../../../core/main_widgets/app_page_shell.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';
import '../../../../home/data/models/home_model.dart';
import '../../../../home/presentation/controller/gender_cubit.dart';
import '../../../../home/presentation/controller/gender_state.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../data/models/overview_model.dart';
import '../../controller/overview_cubit.dart';
import '../../controller/overview_state.dart';

part '../widgets/overview_page/reveal_coordinator.dart';
part '../widgets/overview_page/reveal_coordinator_widget.dart';
part '../widgets/overview_page/reveal.dart';
part '../widgets/overview_page/svg_pulse_loader.dart';
part '../widgets/overview_page/overview_page_view.dart';
part '../widgets/overview_page/overview_section.dart';
part '../widgets/overview_page/top_services_section.dart';
part '../widgets/overview_page/service_card.dart';
part '../widgets/overview_page/gallery_section.dart';
part '../widgets/overview_page/testimonials_section.dart';
part '../widgets/overview_page/arrow_btn.dart';
part '../widgets/overview_page/testimonial_card.dart';
part '../widgets/overview_page/download_now_section.dart';
part '../widgets/overview_page/store_badge.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Helper — parse hex color from branding
// ══════════════════════════════════════════════════════════════════════════════

Color _parseHex(String hex, {required Color fallback}) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    final value = int.tryParse('FF$h', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

// ✅ Gender-aware primary color resolver
Color _resolvePrimary(HomePageModel homeData, bool isMale) {
  final hex = isMale
      ? homeData.branding.malePrimaryColor
      : homeData.branding.primaryColor;
  return _parseHex(hex, fallback: AppColors.primary);
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR Image Cache
// ══════════════════════════════════════════════════════════════════════════════

final Map<String, Future<Uint8List>> _globalUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _globalUrlCache.putIfAbsent(url, () async {
    final response = await html.HttpRequest.request(
      url,
      method: 'GET',
      responseType: 'arraybuffer',
      mimeType: isSvg ? 'image/svg+xml' : null,
    );
    if (response.status == 200 && response.response != null) {
      return (response.response as ByteBuffer).asUint8List();
    }
    throw Exception('HTTP ${response.status}');
  });
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  ColorFilter? colorFilter,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();

  final viewId =
      'svg-overview-user-${url.hashCode}-${width?.toInt()}-${height?.toInt()}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.contain
          ? 'contain'
          : fit == BoxFit.scaleDown
          ? 'scale-down'
          : 'cover';
    return img;
  });

  Widget inner = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    inner = SizedBox(width: width, height: height, child: inner);
  }

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }

  return inner;
}

// ══════════════════════════════════════════════════════════════════════════════
// Preload helpers
// ══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadImages(List<String> urls) async {
  final valid = urls
      .where((u) =>
  u.isNotEmpty &&
      (u.startsWith('http://') || u.startsWith('https://')))
      .toSet();
  await Future.wait(
    valid.map((url) =>
        _xhrLoad(url, isSvg: _isSvgUrl(url)).catchError((_) => Uint8List(0))),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system
// ══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) => const _OverviewPageView();
}
