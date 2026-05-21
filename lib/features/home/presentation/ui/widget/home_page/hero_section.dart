part of '../../pages/home_page.dart';

class _HeroSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String subtitle;
  final String imageUrl;

  const _HeroSection({
    required this.primaryColor,
    required this.title,
    required this.subtitle,
    this.imageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide && hasImage) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildImage(320.h)),
                SizedBox(width: 30.w),
                Expanded(
                  flex: 5,
                  child: _Reveal(
                    delay: const Duration(milliseconds: 100),
                    direction: _SlideDirection.fromRight,
                    child: _HeroText(
                      title: FormatHelper.capitalize(title),
                      subtitle: subtitle,
                      primaryColor: primaryColor,
                    ),
                  ),
                ),
              ],
            );
          }

          if (isWide && !hasImage) {
            return _HeroText(
              title: FormatHelper.capitalize(title),
              subtitle: subtitle,
              primaryColor: primaryColor,
            );
          }

          return Column(
            children: [
              if (hasImage) ...[
                _buildImage(200.h),
                SizedBox(height: 24.h),
              ],
              _HeroText(
                title: FormatHelper.capitalize(title),
                subtitle: subtitle,
                primaryColor: primaryColor,
              ),
            ],
          );
        },
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
