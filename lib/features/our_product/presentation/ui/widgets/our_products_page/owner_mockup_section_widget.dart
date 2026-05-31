part of '../../pages/our_products_page.dart';

class _OwnerMockupSectionWidget extends StatelessWidget {
  final OwnerServicesMockupItemModel item;
  final Color primaryColor;
  final bool isAr;

  const _OwnerMockupSectionWidget({
    required this.item,
    required this.primaryColor,
    required this.isAr,
  });

  _MockupAlign get _align {
    switch (item.alignment) {
      case 'centered':
        return _MockupAlign.centered;
      case 'right':
        return _MockupAlign.right;
      case 'left':
      default:
        return _MockupAlign.left;
    }
  }

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

    final imageWidget = item.imageUrl.isNotEmpty
        ? _netImg(
      url: item.imageUrl,
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
        switch (_align) {
          case _MockupAlign.centered:
            return _CenterLayout(
              title: title,
              body: body,
              imageWidget: imageWidget,
              primaryColor: primaryColor,
            );
          case _MockupAlign.right:
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
          case _MockupAlign.left:
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

enum _MockupAlign { left, centered, right }

// ══════════════════════════════════════════════════════════════════════════════
// DOWNLOAD NOW BAR
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// DOWNLOAD NOW BAR (WITH MAIN WIDGET COLOR BACKGROUND)
// ══════════════════════════════════════════════════════════════════════════════
