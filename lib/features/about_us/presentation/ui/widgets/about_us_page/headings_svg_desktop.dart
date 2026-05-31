part of '../../pages/about_us_page.dart';

class _HeadingsSvgDesktop extends StatelessWidget {
  final String svgUrl;
  const _HeadingsSvgDesktop({required this.svgUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260.w,
      height: 220.h,
      child: _netImg(
        url: svgUrl,
        width: 260.w,
        height: 220.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Headings SVG Hero Banner — Mobile
// ══════════════════════════════════════════════════════════════════════════════
