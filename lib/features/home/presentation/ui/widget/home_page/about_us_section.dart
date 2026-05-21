part of '../../pages/home_page.dart';

class _AboutUsSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String readMoreLabel;
  final String imageUrl;
  final VoidCallback? onReadMore;
  final Color? backgroundColor;  // ← NEW: mainWidgetColor will be passed here

  const _AboutUsSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    required this.readMoreLabel,
    this.imageUrl = '',
    this.onReadMore,
    this.backgroundColor,  // ← NEW
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

        decoration: BoxDecoration(
          color: backgroundColor,  // ← Apply background color to entire section

          borderRadius: BorderRadius.circular(16.r),
        ),

        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),  // Added vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FormatHelper.capitalize(heading),
              style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            if (imageUrl.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _isSvgUrl(imageUrl)
                      ? _nativeSvgImg(
                    url: imageUrl,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                  )
                      : _netImg(
                    url: imageUrl,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            if (body.isNotEmpty)
              Text(
                FormatHelper.capitalize(body),
                style: AppTextStyles.font14BlackCairoRegular.copyWith(
                  height: 1.7,
                  color: AppColors.secondaryBlack,
                ),
              ),
            SizedBox(height: 16.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: InkWell(
                onTap: onReadMore ?? () => navigateTo(context, AboutPage()),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        FormatHelper.capitalize(readMoreLabel),
                        style: AppTextStyles.font14BlackCairoMedium.copyWith(
                          color: primaryColor,
                        ),
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
// SECTION 3 — DOWNLOAD APP
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — DOWNLOAD APP (WITH BACKGROUND COLOR)
// ══════════════════════════════════════════════════════════════════════════════
