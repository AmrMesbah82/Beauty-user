part of '../../pages/our_products_page.dart';

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color backgroundColor;
  const _SvgPulseLoader({this.logoUrl, required this.backgroundColor});
  @override
  State<_SvgPulseLoader> createState() => _SvgPulseLoaderState();
}

class _SvgPulseLoaderState extends State<_SvgPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = (widget.logoUrl?.isNotEmpty == true) ? widget.logoUrl : null;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_SvgPulseLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null)
      setState(() => _resolvedUrl = widget.logoUrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    }

    final viewId = 'svg-products-pulse-${_resolvedUrl.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = _resolvedUrl!
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';
      return img;
    });

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SizedBox(
            width: 88.w,
            height: 88.w,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB PARAM HELPERS
// ══════════════════════════════════════════════════════════════════════════════

int _tabIndexForParam(String tab) {
  switch (tab.toLowerCase().trim()) {
    case 'owner-service':
    case 'owner':
      return 1;
    case 'client-service':
    case 'client':
    default:
      return 0;
  }
}

String _tabParamForIndex(int index) =>
    index == 1 ? 'owner-service' : 'client-service';

// ══════════════════════════════════════════════════════════════════════════════
// FIGMA-MATCH TAB BAR
// Selected tab = filled rounded pill with white text
// Unselected tab = plain text in muted color
// Wrapped in a light rounded container (matches the Figma oval outline)
// ══════════════════════════════════════════════════════════════════════════════
