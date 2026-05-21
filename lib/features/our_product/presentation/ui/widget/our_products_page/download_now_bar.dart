part of '../../pages/our_products_page.dart';

class _DownloadNowBar extends StatelessWidget {
  final Color primaryColor;
  final String label;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadNowBar({
    required this.primaryColor,
    required this.label,
    required this.appStoreLink,
    required this.googlePlayLink,
  });

  void _launchUrl(String url) {
    if (url.isEmpty) return;
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Get mainWidgetColor from HomeCmsCubit
    final Color? backgroundColor = switch (context.watch<HomeCmsCubit>().state) {
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: backgroundColor,  // ← Changed from AppColors.field
        borderRadius: BorderRadius.circular(14.r),  // ← Changed from 8.r to 16.r
      ),
      child: isMobile
          ? Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10.w,
        runSpacing: 8.h,
        children: [
          Text(
            label,
            style: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: primaryColor,
            ),
          ),
          _MiniStoreBadge(
            svgAsset: 'assets/beauty/home/google_play.svg',
            onTap: googlePlayLink.isNotEmpty ? () => _launchUrl(googlePlayLink) : null,
          ),
          _MiniStoreBadge(
            svgAsset: 'assets/beauty/home/app_store.svg',
            onTap: appStoreLink.isNotEmpty ? () => _launchUrl(appStoreLink) : null,
          ),
        ],
      )
          : Row(
        children: [
          Text(
            label,
            style: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: primaryColor,
            ),
          ),
          const Spacer(),
          _MiniStoreBadge(
            svgAsset: 'assets/beauty/home/google_play.svg',
            onTap: googlePlayLink.isNotEmpty ? () => _launchUrl(googlePlayLink) : null,
          ),
          SizedBox(width: 10.w),
          _MiniStoreBadge(
            svgAsset: 'assets/beauty/home/app_store.svg',
            onTap: appStoreLink.isNotEmpty ? () => _launchUrl(appStoreLink) : null,
          ),
        ],
      ),
    );
  }
}
