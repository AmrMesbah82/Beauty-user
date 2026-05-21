/// ******************* FILE INFO *******************
/// File Name: home_page.dart
/// Description: Public-facing Home Page for the Beauty App (Bayanatz).
/// Last Update: 11/05/2026
/// UPDATED: Primary color is now gender-aware — uses malePrimaryColor when
///          GenderCubit reports male, primaryColor when female.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:beauty_user/core/widget/format.dart';
import 'package:beauty_user/core/widget/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/main_widgets/app_page_shell.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/text.dart';
import '../../../../about_us/presentation/ui/pages/about_us_page.dart';
import '../../../../main/data/models/main_model.dart';
import '../../../../main/presentation/controller/main_cubit.dart';
import '../../../../main/presentation/controller/main_state.dart';
import '../../controller/gender_cubit.dart';
import '../../controller/gender_state.dart';
import '../../controller/home_cubit.dart';
import '../../controller/home_state.dart';
import '../../controller/lang_state.dart';

part '../widget/home_page/reveal_coordinator.dart';
part '../widget/home_page/reveal_coordinator_widget.dart';
part '../widget/home_page/reveal.dart';
part '../widget/home_page/svg_pulse_loader.dart';
part '../widget/home_page/home_page_view.dart';
part '../widget/home_page/hero_section.dart';
part '../widget/home_page/hero_text.dart';
part '../widget/home_page/about_us_section.dart';
part '../widget/home_page/download_app_section.dart';
part '../widget/home_page/download_text_content.dart';
part '../widget/home_page/store_badge.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

// ── Counter for unique HtmlElementView IDs ────────────────────────────────────
int _htmlViewCounter = 0;

// ── Registered view IDs to avoid duplicate registration ──────────────────────
final Set<String> _registeredViewIds = {};

// ── Gender-aware primary color helper ────────────────────────────────────────
/// Returns malePrimaryColor when [isMale] is true, otherwise primaryColor.
Color _resolvePrimaryColor({
  required String primaryColorHex,
  required String malePrimaryColorHex,
  required bool isMale,
}) {
  final hex = isMale ? malePrimaryColorHex : primaryColorHex;
  return _parseHex(hex,
      fallback: isMale ? const Color(0xFF1565C0) : AppColors.primary);
}

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ── XHR loader (used only for non-SVG images) ─────────────────────────────────
final Map<String, Future<Uint8List>> _globalUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _globalUrlCache.putIfAbsent(url, () async {
    try {
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
    } catch (e) {
      throw Exception('XHR failed: $e');
    }
  });
}

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header =
  String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

// ── Native SVG renderer via browser <img> tag ─────────────────────────────────
Widget _nativeSvgImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (url.isEmpty) return const SizedBox.shrink();

  final viewId = 'native-svg-${url.hashCode}-${_htmlViewCounter++}';

  if (!_registeredViewIds.contains(viewId)) {
    _registeredViewIds.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = fit == BoxFit.cover ? 'cover' : 'contain'
        ..style.display = 'block';
      return img;
    });
  }

  Widget view = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    view = SizedBox(width: width, height: height, child: view);
  }

  return view;
}

// ── General image loader ───────────────────────────────────────────────────────
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

  if (_isSvgUrl(url)) {
    Widget svgWidget =
    _nativeSvgImg(url: url, width: width, height: height, fit: fit);
    if (borderRadius != null) {
      svgWidget = ClipRRect(borderRadius: borderRadius, child: svgWidget);
    }
    return svgWidget;
  }

  Widget inner = FutureBuilder<Uint8List>(
    future: _xhrLoad(url, isSvg: false),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return placeholder ?? SizedBox(width: width, height: height);
      }
      if (snapshot.hasData) {
        final bytes = snapshot.data!;
        if (_isSvgBytes(bytes)) {
          return _nativeSvgImg(url: url, width: width, height: height, fit: fit);
        }
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          colorBlendMode: colorFilter != null ? BlendMode.srcIn : null,
        );
      }
      return errorWidget ??
          Icon(Icons.broken_image,
              color: Colors.grey[400],
              size: (width ?? height ?? 24).toDouble());
    },
  );

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }
  if (width != null || height != null) {
    inner = SizedBox(width: width, height: height, child: inner);
  }
  return inner;
}

Future<void> _preloadImages(List<String> urls) async {
  final valid = urls
      .where((u) =>
  u.isNotEmpty &&
      (u.startsWith('http://') || u.startsWith('https://')))
      .toSet();

  final nonSvgUrls = valid.where((u) => !_isSvgUrl(u)).toSet();

  await Future.wait(
    nonSvgUrls.map((url) =>
        _xhrLoad(url, isSvg: false).catchError((_) => Uint8List(0))),
  );
}

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const _HomePageView();
}
