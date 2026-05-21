part of '../../pages/overview_page.dart';

class _DownloadNowSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String appStoreLink;
  final String googlePlayLink;
  final Color? backgroundColor;  // ← NEW: mainWidgetColor

  const _DownloadNowSection({
    required this.primaryColor,
    required this.title,
    required this.appStoreLink,
    required this.googlePlayLink,
    this.backgroundColor,  // ← NEW
  });

  void _launchUrl(String url) {
    if (url.isEmpty) return;
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: backgroundColor,  // ← Apply background color to entire section
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
        child: Container(
          width: double.infinity,
          // padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 0.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      FormatHelper.capitalize(title),
                      style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                        color: primaryColor,
                        fontSize: 22.sp,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (googlePlayLink.isNotEmpty)
                          _StoreBadge(
                            onTap: () => _launchUrl(googlePlayLink),
                            svgAsset: 'assets/beauty/home/google_play.svg',
                          ),
                        if (googlePlayLink.isNotEmpty && appStoreLink.isNotEmpty)
                          SizedBox(width: 12.w),
                        if (appStoreLink.isNotEmpty)
                          _StoreBadge(
                            onTap: () => _launchUrl(appStoreLink),
                            svgAsset: 'assets/beauty/home/app_store.svg',
                          ),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                      color: primaryColor,
                      fontSize: 22.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    spacing: 12.w,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (googlePlayLink.isNotEmpty)
                        _StoreBadge(
                          onTap: () => _launchUrl(googlePlayLink),
                          svgAsset: 'assets/beauty/home/google_play.svg',
                        ),
                      if (appStoreLink.isNotEmpty)
                        _StoreBadge(
                          onTap: () => _launchUrl(appStoreLink),
                          svgAsset: 'assets/beauty/home/app_store.svg',
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STORE BADGE BUTTON
// ══════════════════════════════════════════════════════════════════════════════
