part of '../../pages/overview_page.dart';

class _TestimonialCard extends StatelessWidget {
  final OverviewClientCommentModel comment;
  final Color primaryColor;
  final bool isAr;
  final Color backgroundColor; // ← ADD


  const _TestimonialCard({
    required this.comment,
    required this.primaryColor,
    required this.isAr,
    required this.backgroundColor, // ← ADD

  });

  @override
  Widget build(BuildContext context) {
    final String fullName = isAr
        ? '${comment.firstName.ar} ${comment.lastName.ar}'.trim()
        : '${comment.firstName.en} ${comment.lastName.en}'.trim();

    final String feedbackText =
    isAr ? comment.feedback.ar : comment.feedback.en;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                child: _netImg(
                  url: comment.imageUrl,
                  width: 48.r,
                  height: 48.r,
                  fit: BoxFit.scaleDown,
                  placeholder: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Icon(Icons.person_outline,
                        color: primaryColor, size: 22.sp),
                  ),
                  errorWidget: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Icon(Icons.person_outline,
                        color: primaryColor, size: 22.sp),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  FormatHelper.capitalize(fullName),
                  style: AppTextStyles.font14BlackCairoMedium.copyWith(
                    color: AppColors.secondaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // ✅ plain Text, no Expanded — prevents mobile layout crash
          Text(
            FormatHelper.capitalize(feedbackText),
            style: AppTextStyles.font12BlackCairoRegular.copyWith(
              height: 1.6,
              color: AppColors.secondaryBlack.withOpacity(0.75),
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — DOWNLOAD NOW
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — DOWNLOAD NOW (WITH BACKGROUND COLOR)
// ══════════════════════════════════════════════════════════════════════════════
