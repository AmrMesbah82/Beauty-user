part of '../../pages/terms_of_service_page.dart';

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

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
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
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
      fallback: isMale ? const Color(0xFF1565C0) : _kDefaultGreen);
}

({int topTab, int subTab}) _resolveTabParam(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'terms-and-conditions':
    case 'terms':
    case 'terms-of-service':
    case 'termsofservice':
      return (topTab: 0, subTab: 0);
    case 'privacy-policy':
    case 'privacy':
    case 'privacypolicy':
      return (topTab: 1, subTab: 0);
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

  // ✅ Guard against double.infinity — crashes toInt() on web (dart2js)
  String safeSize(double? v) {
    if (v == null) return 'null';
    if (v.isInfinite || v.isNaN) return 'fill';
    return v.toInt().toString();
  }

  final viewId =
      'svg-terms-user-${url.hashCode}-${safeSize(width)}-${safeSize(height)}';

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
    // ✅ Never pass NaN to SizedBox; infinity is valid for SizedBox (fills parent)
    final safeW = (width != null && !width.isNaN) ? width : double.infinity;
    final safeH = (height != null && !height.isNaN) ? height : null;
    inner = SizedBox(width: safeW, height: safeH, child: inner);
  }

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }

  return inner;
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system
// ══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }
