part of '../../pages/overview_page.dart';

class _OverviewSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String body;
  final VoidCallback? onReadMore;
  final Color? backgroundColor;  // ← NEW: mainWidgetColor

  const _OverviewSection({
    required this.primaryColor,
    required this.title,
    required this.body,
    this.onReadMore,
    this.backgroundColor,  // ← NEW
  });

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.watch<LanguageCubit>().state.isArabic;
    final readMoreLabel = isAr ? 'اقرأ المزيد' : 'Read More';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,  // ← Apply background color

        borderRadius: BorderRadius.circular(16.r)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FormatHelper.capitalize(title),
              style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                color: primaryColor,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              FormatHelper.capitalize(body),
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: InkWell(
                onTap: () {
                  navigateTo(context, OurProductsPage());
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        FormatHelper.capitalize(readMoreLabel),
                        style: AppTextStyles.font14BlackCairoMedium
                            .copyWith(color: primaryColor),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.15),
                        ),
                        child: Icon(Icons.arrow_forward,
                            size: 14.sp, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — TOP SERVICES
// ══════════════════════════════════════════════════════════════════════════════
