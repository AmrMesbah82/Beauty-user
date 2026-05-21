part of '../../pages/our_products_page.dart';

class _OwnerHeaderHero extends StatelessWidget {
  final OwnerServicesHeaderModel header;
  final Color primaryColor;
  final bool isAr;

  const _OwnerHeaderHero({
    required this.header,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final rawTitle = isAr
        ? (header.title.ar.isNotEmpty ? header.title.ar : header.title.en)
        : (header.title.en.isNotEmpty ? header.title.en : header.title.ar);
    final title = FormatHelper.capitalize(rawTitle);
    final desc = isAr
        ? (header.description.ar.isNotEmpty
        ? header.description.ar
        : header.description.en)
        : (header.description.en.isNotEmpty
        ? header.description.en
        : header.description.ar);
    final hasImage = header.imageUrl.isNotEmpty;

    if (title.isEmpty && desc.isEmpty && !hasImage)
      return const SizedBox.shrink();

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

    final imageWidget = hasImage
        ? _netImg(
      url: header.imageUrl,
      height: 220.h,
      fit: BoxFit.contain,
      placeholder: SizedBox(height: 220.h),
      errorWidget: SizedBox(height: 220.h),
    )
        : null;

    final textWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
              fontSize: 28.sp,
            ),
          ),
        if (desc.isNotEmpty) ...[
          SizedBox(height: 14.h),
          Text(
            desc,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
              height: 1.7,
              color: AppColors.secondaryBlack,
            ),
          ),
        ],
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide && imageWidget != null) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: textWidget),
                  SizedBox(width: 30.w),
                  Expanded(flex: 4, child: imageWidget),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageWidget != null) ...[
                  Center(child: imageWidget),
                  SizedBox(height: 16.h),
                ],
                textWidget,
              ],
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT MOCKUP SECTION WIDGET
// ══════════════════════════════════════════════════════════════════════════════
