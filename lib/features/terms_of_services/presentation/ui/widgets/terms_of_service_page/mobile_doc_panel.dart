part of '../../pages/terms_of_service_page.dart';

class _MobileDocPanel extends StatelessWidget {
  final String description,
      svgUrl,
      attachEnUrl,
      attachArUrl,
      sectionLabelEn,
      sectionLabelAr;
  final Color primaryColor;
  final String logoUrl;
  final String lastUpdate;
  final bool isRtl;

  const _MobileDocPanel({
    required this.description,
    required this.svgUrl,
    required this.attachEnUrl,
    required this.attachArUrl,
    required this.sectionLabelEn,
    required this.sectionLabelAr,
    required this.primaryColor,
    required this.logoUrl,
    required this.lastUpdate,
    required this.isRtl,
  });

  // Get mainWidgetColor from HomeCmsCubit
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

  Widget _downloadBtn(BuildContext context) {
    final String url = isRtl ? attachArUrl : attachEnUrl;
    if (url.isEmpty) return const SizedBox.shrink();

    final String label = isRtl
        ? 'تحميل PDF — $sectionLabelAr'
        : 'Download PDF — $sectionLabelEn';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => html.window.open(url, '_blank'),
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomSvg(
                assetPath: 'assets/download.svg',
                width: 18.w,
                height: 18.h,
                fit: BoxFit.scaleDown,
                color: primaryColor,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLastUpdate = lastUpdate.isNotEmpty &&
        !lastUpdate.endsWith(': ') &&
        !lastUpdate.endsWith(': null');
    final Color? backgroundColor = _getMainWidgetColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── REMOVED SVG IMAGE SECTION AT TOP ──

        // ── Card with background color ──
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (logoUrl.isNotEmpty || hasLastUpdate) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (logoUrl.isNotEmpty)
                        _netImg(
                          url: logoUrl,
                          width: 70.w,
                          height: 34.h,
                          fit: BoxFit.contain,
                        )
                      else
                        const SizedBox.shrink(),
                      if (hasLastUpdate)
                        Flexible(
                          child: Text(
                            lastUpdate,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryBlack.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                ],
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryBlack,
                    height: 1.75,
                  ),
                ),
              ],
            ),
          ),
        ),

        _downloadBtn(context),
        SizedBox(height: 8.h),
      ],
    );
  }
}
