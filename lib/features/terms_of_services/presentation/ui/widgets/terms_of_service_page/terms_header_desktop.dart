part of '../../pages/terms_of_service_page.dart';

class _TermsHeaderDesktop extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  final String svgUrl;

  const _TermsHeaderDesktop({
    required this.isRtl,
    required this.primaryColor,
    required this.svgUrl,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad =
    ((screenW - contentW) / 2).clamp(36.0, double.infinity);
    final String title = isRtl ? 'الشروط والخدمة' : 'Terms of Service';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── SVG before title ───────────────────────────────────────
          if (svgUrl.isNotEmpty) ...[
            _netImg(
              url: svgUrl,
              width: 120.w,
              height: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 24.w),
          ],
          // ── Title ──────────────────────────────────────────────────
          Expanded(
            child: Text(
              title,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: StyleText.fontSize45Weight600.copyWith(
                fontSize: 48.sp,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
