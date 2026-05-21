part of '../../pages/contact_us_page.dart';

class _MobileDescriptionText extends StatelessWidget {
  final bool isRtl;
  final ContactUsCmsModel? cmsData;
  final bool isOwner;
  const _MobileDescriptionText({
    required this.isRtl,
    this.cmsData,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final String cmsDesc = _getCmsDescription(
      cmsData: cmsData,
      isOwner: isOwner,
      isRtl: isRtl,
    );
    if (cmsDesc.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        cmsDesc,
        style: StyleText.fontSize13Weight400.copyWith(
          fontSize: 12.sp,
          color: Colors.black87,
          height: 1.7,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE ICON TEXT FIELD
// ═══════════════════════════════════════════════════════════════════════════════
