part of '../../pages/our_products_page.dart';

class _ClientMockupSectionWidget extends StatelessWidget {
  final ClientServicesMockupItemModel item;
  final Color primaryColor;
  final bool isAr;

  const _ClientMockupSectionWidget({
    required this.item,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final rawTitle = isAr
        ? (item.title.ar.isNotEmpty ? item.title.ar : item.title.en)
        : (item.title.en.isNotEmpty ? item.title.en : item.title.ar);
    final title = FormatHelper.capitalize(rawTitle);
    final body = isAr
        ? (item.description.ar.isNotEmpty
        ? item.description.ar
        : item.description.en)
        : (item.description.en.isNotEmpty
        ? item.description.en
        : item.description.ar);

    final imageWidget = item.svgUrl.isNotEmpty
        ? _netImg(
      url: item.svgUrl,
      height: 280.h,
      fit: BoxFit.contain,
      placeholder: SizedBox(height: 280.h),
      errorWidget: SizedBox(
        height: 280.h,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 60.r,
            color: AppColors.secondaryBlack.withOpacity(0.3),
          ),
        ),
      ),
    )
        : SizedBox(
      height: 280.h,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 60.r,
          color: AppColors.secondaryBlack.withOpacity(0.3),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        switch (item.layout) {
          case MockupLayout.centered:
            return _CenterLayout(
              title: title,
              body: body,
              imageWidget: imageWidget,
              primaryColor: primaryColor,
            );
          case MockupLayout.right:
            return isWide
                ? _SideBySideLayout(
              title: title,
              body: body,
              imageWidget: imageWidget,
              primaryColor: primaryColor,
              imageOnLeft: false,
            )
                : _StackedFallback(
              title: title,
              body: body,
              imageWidget: imageWidget,
              primaryColor: primaryColor,
            );
          case MockupLayout.left:
            return isWide
                ? _SideBySideLayout(
              title: title,
              body: body,
              imageWidget: imageWidget,
              primaryColor: primaryColor,
              imageOnLeft: true,
            )
                : _StackedFallback(
              title: title,
              body: body,
              imageWidget: imageWidget,
              primaryColor: primaryColor,
            );
        }
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OWNER MOCKUP SECTION WIDGET
// ══════════════════════════════════════════════════════════════════════════════
