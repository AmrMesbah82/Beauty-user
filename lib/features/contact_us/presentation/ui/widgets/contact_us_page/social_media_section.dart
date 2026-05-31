part of '../../pages/contact_us_page.dart';

class _SocialMediaSection extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final Color primaryColor;
  final bool isMobile, isRtl;
  const _SocialMediaSection({
    this.cmsData,
    required this.primaryColor,
    required this.isMobile,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final rawIcons = (cmsData?.socialIcons ?? [])
        .where((i) => i.iconUrl.isNotEmpty || i.link.isNotEmpty)
        .toList();

    if (rawIcons.isEmpty) return const SizedBox.shrink();

    final String title = _t(
      context,
      en: 'Social Media',
      ar: 'وسائل التواصل الاجتماعي',
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.w : 0,
        vertical: 24.h,
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              title,
              style: StyleText.fontSize22Weight700.copyWith(
                color: primaryColor,
                fontSize: isMobile ? 18.sp : 20.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: rawIcons
                  .map(
                    (i) => Padding(
                  padding: EdgeInsetsDirectional.only(end: 10.w),
                  child: _SocialIconWidget(
                    iconUrl: i.iconUrl,
                    link: i.link,
                    primaryColor: primaryColor,
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL ICON WIDGET (WITH GENDER-AWARE PRIMARY COLOR)
// ═══════════════════════════════════════════════════════════════════════════════
