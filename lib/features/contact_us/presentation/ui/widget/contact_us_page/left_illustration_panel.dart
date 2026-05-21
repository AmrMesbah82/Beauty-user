part of '../../pages/contact_us_page.dart';

class _LeftIllustrationPanel extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  final ContactUsCmsModel? cmsData;
  final bool isOwner;
  const _LeftIllustrationPanel({
    required this.isRtl,
    required this.primaryColor,
    this.cmsData,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final String cmsDesc = _getCmsDescription(
      cmsData: cmsData,
      isOwner: isOwner,
      isRtl: isRtl,
    );
    final String svgUrl = cmsData?.headings.svgUrl ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: svgUrl.isNotEmpty
              ? () {
            final viewId = 'svg-contact-illust-${svgUrl.hashCode}';
            ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
              final img = html.ImageElement()
                ..src = svgUrl
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.objectFit = 'contain';
              return img;
            });
            return SizedBox(
              width: 220.w,
              height: 200.h,
              child: HtmlElementView(viewType: viewId),
            );
          }()
              : SvgPicture.asset(
            'assets/spa_core.svg',
            width: 220.w,
            height: 200.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 24.h),
        if (cmsDesc.isNotEmpty)
          Text(
            cmsDesc,
            style: StyleText.fontSize13Weight400.copyWith(
              fontSize: 12.sp,
              color: Colors.black87,
              height: 1.7,
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY — fully CMS-driven
// ═══════════════════════════════════════════════════════════════════════════════
