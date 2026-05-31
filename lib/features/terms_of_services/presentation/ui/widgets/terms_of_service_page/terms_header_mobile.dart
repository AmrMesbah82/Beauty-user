part of '../../pages/terms_of_service_page.dart';

class _TermsHeaderMobile extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  final String svgUrl;

  const _TermsHeaderMobile({
    required this.isRtl,
    required this.primaryColor,
    required this.svgUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String title = isRtl ? 'الشروط والخدمة' : 'Terms of Service';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── SVG before title ───────────────────────────────────────
          if (svgUrl.isNotEmpty) ...[
            _netImg(
              url: svgUrl,
              width: 56.w,
              height: 56.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
          ],
          // ── Title ──────────────────────────────────────────────────
          Expanded(
            child: Text(
              title,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: StyleText.fontSize45Weight600.copyWith(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ══════════════════════════════════════════════════════════════════════════════
