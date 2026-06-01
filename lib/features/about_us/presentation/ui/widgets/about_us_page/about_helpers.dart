part of '../../pages/about_us_page.dart';

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

/// Hover tint matching navbar: primary.withOpacity(0.12)
Color _hoverTint(Color primary) => primary.withOpacity(0.12);

double _desktopContentWidth(BuildContext context) {
  final double screen = MediaQuery.of(context).size.width;
  final double natural = (248.w * 4) + (8.w * 3);
  return natural.clamp(0.0, screen - 64.0);
}

String _ab(AboutBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

Color _parseHex(String hex, {required Color fallback}) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    final value = int.tryParse('FF$h', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

// ── Gender-aware primary color helper ────────────────────────────────────────
/// Returns malePrimaryColor when [isMale] is true, otherwise primaryColor.
Color _resolvePrimaryColor({
  required String primaryColorHex,
  required String malePrimaryColorHex,
  required bool isMale,
}) {
  final hex = isMale ? malePrimaryColorHex : primaryColorHex;
  return _parseHex(hex,
      fallback: isMale ? const Color(0xFF1565C0) : const Color(0xFFD16F9A));
}

({int topTab, int subTab}) _resolveTabParam(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'our-strategy':
      return (topTab: 1, subTab: 0);
    case 'vision':
      return (topTab: 0, subTab: 0);
    case 'mission':
      return (topTab: 0, subTab: 1);
    case 'values':
      return (topTab: 0, subTab: 2);
    case 'our-team':
    case 'why-join-our-team':
    case 'about-us':
    default:
      return (topTab: 0, subTab: 0);
  }
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

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header = String.fromCharCodes(
    b.sublist(0, b.length.clamp(0, 100)),
  ).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
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

  final fitStr = fit == BoxFit.contain
      ? 'contain'
      : fit == BoxFit.scaleDown
      ? 'scale-down'
      : fit == BoxFit.fill
      ? 'fill'
      : 'cover';

  // ✅ Guard against double.infinity which crashes toInt() on web (dart2js)
  String _safeSize(double? v) {
    if (v == null) return 'null';
    if (v.isInfinite || v.isNaN) return 'fill';
    return v.toInt().toString();
  }

  final viewId =
      'svg-about-user-${url.hashCode}-${_safeSize(width)}-${_safeSize(height)}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fitStr;
    return img;
  });

  Widget inner = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    // ✅ Never pass infinity to SizedBox — use double.infinity only when it's a valid layout value
    final safeW = (width != null && !width.isNaN && !width.isInfinite) ? width : double.infinity;
    final safeH = (height != null && !height.isNaN && !height.isInfinite) ? height : null;
    inner = SizedBox(width: safeW, height: safeH, child: inner);
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
      .where(
        (u) =>
    u.isNotEmpty &&
        (u.startsWith('http://') || u.startsWith('https://')),
  )
      .toSet();
  await Future.wait(
    valid.map(
          (url) =>
          _xhrLoad(url, isSvg: _isSvgUrl(url)).catchError((_) => Uint8List(0)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system
// ══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }
