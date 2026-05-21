part of '../../pages/about_us_page.dart';

class _HeadingsSvgMobile extends StatelessWidget {
  final String svgUrl;
  const _HeadingsSvgMobile({required this.svgUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160.w,
      height: 160.h,
      child: _netImg(
        url: svgUrl,
        width: 160.w,
        height: 160.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Headers
// ══════════════════════════════════════════════════════════════════════════════
