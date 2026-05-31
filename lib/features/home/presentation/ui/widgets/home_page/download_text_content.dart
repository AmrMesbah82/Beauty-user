part of '../../pages/home_page.dart';

class _DownloadTextContent extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadTextContent({
    required this.primaryColor,
    required this.heading,
    required this.body,
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  void _launchUrl(String url) {
    if (url.isEmpty) return;
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FormatHelper.capitalize(heading),
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        if (body.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              FormatHelper.capitalize(body),
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
              ),
            ),
          ),
        if (googlePlayLink.isNotEmpty || appStoreLink.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              double buttonWidth;
              double buttonHeight;
              double spacing;

              if (constraints.maxWidth >= 1024) {
                buttonWidth  = 160;
                buttonHeight = 48;
                spacing      = 16;
              } else if (constraints.maxWidth >= 600) {
                buttonWidth  = 140;
                buttonHeight = 44;
                spacing      = 12;
              } else {
                buttonWidth  = 135;
                buttonHeight = 42;
                spacing      = 10;
              }

              return Wrap(
                spacing: spacing,
                runSpacing: 8.h,
                children: [
                  if (googlePlayLink.isNotEmpty)
                    _StoreBadge(
                      onTap: () => _launchUrl(googlePlayLink),
                      svgAsset: 'assets/beauty/home/google_play.svg',
                      width: buttonWidth,
                      height: buttonHeight,
                    ),
                  if (appStoreLink.isNotEmpty)
                    _StoreBadge(
                      onTap: () => _launchUrl(appStoreLink),
                      svgAsset: 'assets/beauty/home/app_store.svg',
                      width: buttonWidth,
                      height: buttonHeight,
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STORE BADGE BUTTON
// ══════════════════════════════════════════════════════════════════════════════
