part of '../../pages/overview_page.dart';

class _ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final Color primaryColor;

  const _ServiceCard({
    required this.imageUrl,
    required this.name,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
            Border.all(color: primaryColor.withOpacity(0.2), width: 2.w),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: ClipOval(
              child: _netImg(
                url: imageUrl,
                width: 48.w,
                height: 48.w,
                fit: BoxFit.scaleDown,
                placeholder: Icon(
                  Icons.spa_outlined,
                  color: primaryColor.withOpacity(0.4),
                  size: 28.sp,
                ),
                errorWidget: Icon(
                  Icons.spa_outlined,
                  color: primaryColor.withOpacity(0.4),
                  size: 28.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          FormatHelper.capitalize(name),
          style: AppTextStyles.font14BlackCairoMedium
              .copyWith(color: AppColors.secondaryBlack),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — GALLERY
// ══════════════════════════════════════════════════════════════════════════════
