part of '../../pages/contact_us_page.dart';

class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final _SlideDirection direction;

  const _Reveal({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.direction = _SlideDirection.fromBottom,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _triggered = false;
  _RevealCoordinatorState? _coordinator;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop => const Offset(0, -0.18),
      _SlideDirection.fromLeft => const Offset(-0.18, 0),
      _SlideDirection.fromRight => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: begin, end: Offset.zero));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        Future.delayed(widget.delay, () {
          if (mounted) _checkAndTrigger();
        });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        Future.delayed(widget.delay + const Duration(milliseconds: 120), () {
          if (mounted) _checkAndTrigger();
        });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = _RevealCoordinator.of(context);
    _coordinator?.register(this);
  }

  @override
  void dispose() {
    _coordinator?.unregister(this);
    _ctrl.dispose();
    super.dispose();
  }

  void onScroll() => _checkAndTrigger();

  void _checkAndTrigger() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH - 40) {
      _triggered = true;
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

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
      fallback: isMale ? const Color(0xFF1565C0) : _kDefaultPink);
}

String _t(BuildContext context, {required String en, required String ar}) {
  final isAr = context.read<LanguageCubit>().state.isArabic;
  return (isAr && ar.isNotEmpty) ? ar : en;
}

const List<Map<String, String>> _phoneCodes = [
  {'key': '+20', 'value': '🇪🇬 +20'},
  {'key': '+234', 'value': '🇳🇬 +234'},
  {'key': '+212', 'value': '🇲🇦 +212'},
  {'key': '+213', 'value': '🇩🇿 +213'},
  {'key': '+216', 'value': '🇹🇳 +216'},
  {'key': '+249', 'value': '🇸🇩 +249'},
  {'key': '+251', 'value': '🇪🇹 +251'},
  {'key': '+254', 'value': '🇰🇪 +254'},
  {'key': '+27', 'value': '🇿🇦 +27'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+973', 'value': '🇧🇭 +973'},
  {'key': '+968', 'value': '🇴🇲 +968'},
  {'key': '+962', 'value': '🇯🇴 +962'},
  {'key': '+961', 'value': '🇱🇧 +961'},
  {'key': '+963', 'value': '🇸🇾 +963'},
  {'key': '+964', 'value': '🇮🇶 +964'},
  {'key': '+967', 'value': '🇾🇪 +967'},
  {'key': '+970', 'value': '🇵🇸 +970'},
  {'key': '+90', 'value': '🇹🇷 +90'},
  {'key': '+98', 'value': '🇮🇷 +98'},
  {'key': '+44', 'value': '🇬🇧 +44'},
  {'key': '+33', 'value': '🇫🇷 +33'},
  {'key': '+49', 'value': '🇩🇪 +49'},
  {'key': '+1', 'value': '🇺🇸 +1'},
  {'key': '+91', 'value': '🇮🇳 +91'},
  {'key': '+86', 'value': '🇨🇳 +86'},
  {'key': '+81', 'value': '🇯🇵 +81'},
  {'key': '+61', 'value': '🇦🇺 +61'},
  {'key': '+64', 'value': '🇳🇿 +64'},
];

List<Map<String, String>> _buildReasonItems({
  required ContactUsCmsModel? cmsData,
  required bool isOwner,
  required bool isRtl,
}) {
  final section = isOwner
      ? cmsData?.ownerDescription
      : cmsData?.clientDescription;
  final reasons = section?.reasons ?? [];

  if (reasons.isNotEmpty) {
    final items = reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map(
          (r) => {
        'key': isRtl ? r.label.ar : r.label.en,
        'value': isRtl ? r.label.ar : r.label.en,
      },
    )
        .where((m) => m['key']!.isNotEmpty)
        .toList();
    if (items.isNotEmpty) return items;
  }

  return (isRtl
      ? ContactFormConstants.reasonsAr
      : ContactFormConstants.reasonsEn)
      .map((r) => {'key': r, 'value': r})
      .toList();
}

String _getCmsDescription({
  required ContactUsCmsModel? cmsData,
  required bool isOwner,
  required bool isRtl,
}) {
  final section = isOwner
      ? cmsData?.ownerDescription
      : cmsData?.clientDescription;
  final desc = section?.description;
  if (desc != null) {
    final text = isRtl ? desc.ar : desc.en;
    if (text.isNotEmpty) return text;
  }
  return '';
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PRELOADER
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadSvgImages(List<String> urls) async {
  final validUrls = urls
      .where(
        (url) =>
    url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://')),
  )
      .toSet()
      .toList();

  await Future.wait(
    validUrls.map((url) async {
      final loader = SvgNetworkLoader(url);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PULSE LOADER
// ═══════════════════════════════════════════════════════════════════════════════
