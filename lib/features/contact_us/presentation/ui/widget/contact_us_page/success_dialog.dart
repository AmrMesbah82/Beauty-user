part of '../../pages/contact_us_page.dart';

class _SuccessDialog extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  const _SuccessDialog({required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 14 : 16.r),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 36.w,
          vertical: isMobile ? 56 : 36.h,
        ),
        child: SizedBox(
          width: isMobile ? double.infinity : 500.w,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 36.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isMobile ? 100 : 120.w,
                  height: isMobile ? 100 : 120.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: isMobile ? 50 : 60.w,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24.h),
                Text(
                  isRtl ? 'تم الإرسال بنجاح !' : 'Send Successfully !',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize22Weight700.copyWith(
                    fontSize: isMobile ? 18.0 : 22.sp,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 14.h),
                Text(
                  isRtl
                      ? 'تم إرسال طلبك بنجاح. شكراً لتواصلك معنا.'
                      : 'Your request was sent successfully. Thank you for contact with us.',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: isMobile ? 12.0 : 14.sp,
                    height: 1.7,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════
