part of '../../pages/home_page.dart';

class _DownloadAppSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String imageUrl;
  final String appStoreLink;
  final String googlePlayLink;
  final Color? backgroundColor;  // ← NEW: mainWidgetColor

  const _DownloadAppSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    this.imageUrl = '',
    this.appStoreLink = '',
    this.googlePlayLink = '',
    this.backgroundColor,  // ← NEW
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: backgroundColor,  // ← Apply background color
          borderRadius: BorderRadius.circular(16.r)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            if (isWide && hasImage) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 4, child: _buildImage(320.h)),
                  SizedBox(width: 30.w),
                  Expanded(
                    flex: 6,
                    child: _DownloadTextContent(
                      primaryColor: primaryColor,
                      heading: heading,
                      body: body,
                      appStoreLink: appStoreLink,
                      googlePlayLink: googlePlayLink,
                    ),
                  ),
                ],
              );
            }

            if (isWide && !hasImage) {
              return _DownloadTextContent(
                primaryColor: primaryColor,
                heading: heading,
                body: body,
                appStoreLink: appStoreLink,
                googlePlayLink: googlePlayLink,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage) ...[
                  Center(child: _buildImage(200.h)),
                  SizedBox(height: 24.h),
                ],
                _DownloadTextContent(
                  primaryColor: primaryColor,
                  heading: heading,
                  body: body,
                  appStoreLink: appStoreLink,
                  googlePlayLink: googlePlayLink,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(double height) {
    if (imageUrl.isEmpty) return const SizedBox.shrink();
    if (_isSvgUrl(imageUrl)) {
      return _nativeSvgImg(url: imageUrl, height: height, fit: BoxFit.contain);
    }
    return _netImg(
      url: imageUrl,
      height: height,
      fit: BoxFit.contain,
      errorWidget: const SizedBox.shrink(),
    );
  }
}
