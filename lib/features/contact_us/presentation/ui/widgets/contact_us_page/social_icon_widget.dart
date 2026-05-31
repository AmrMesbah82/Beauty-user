part of '../../pages/contact_us_page.dart';

class _SocialIconWidget extends StatelessWidget {
  final String? svgPath, iconUrl, link;
  final Color primaryColor;

  const _SocialIconWidget({
    this.svgPath,
    this.iconUrl,
    this.link,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // For debugging: print the color being used

    return GestureDetector(
      onTap: (link?.isNotEmpty ?? false)
          ? () async {
        String raw = link!.trim();
        if (!raw.startsWith('http://') && !raw.startsWith('https://'))
          raw = 'https://$raw';
        final uri = Uri.tryParse(raw);
        if (uri == null || !uri.hasAuthority) return;
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank',
          );
        }
      }
          : null,
      child: MouseRegion(
        cursor: (link?.isNotEmpty ?? false)
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryColor.withOpacity(0.3),  // ← Gender-aware border
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: iconUrl != null && iconUrl!.isNotEmpty
                ? () {
              final viewId = 'svg-social-${iconUrl.hashCode}';
              ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
                final img = html.ImageElement()
                  ..src = iconUrl!
                  ..style.width = '100%'
                  ..style.height = '100%'
                  ..style.objectFit = 'contain';
                return img;
              });
              return SizedBox(
                width: 22.w,
                height: 22.w,
                child: HtmlElementView(viewType: viewId),
              );
            }()
                : SvgPicture.asset(
              svgPath ?? 'assets/images/instegrm.svg',
              width: 22.w,
              height: 22.w,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                primaryColor,  // ← Gender-aware icon color
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
