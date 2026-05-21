part of '../../pages/our_products_page.dart';

class _MiniStoreBadge extends StatelessWidget {
  final String svgAsset;
  final VoidCallback? onTap;

  const _MiniStoreBadge({required this.svgAsset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = MediaQuery.of(context).size.width < 600 ? 30.h : 36.h;
            return SvgPicture.asset(svgAsset, height: h, fit: BoxFit.contain);
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LAYOUT WIDGETS
// ══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════
// LAYOUT WIDGETS (WITH MAIN WIDGET COLOR BACKGROUND)
// ══════════════════════════════════════════════════════════════════════════════

// Helper function to get mainWidgetColor
Color? _getMainWidgetColor(BuildContext context) {
  final homeState = context.watch<HomeCmsCubit>().state;
  return switch (homeState) {
    HomeCmsLoaded(:final data) => _parseHex(
      data.branding.mainWidgetColor,
      fallback: Colors.transparent,
    ),
    HomeCmsSaved(:final data) => _parseHex(
      data.branding.mainWidgetColor,
      fallback: Colors.transparent,
    ),
    _ => Colors.transparent,
  };
}
