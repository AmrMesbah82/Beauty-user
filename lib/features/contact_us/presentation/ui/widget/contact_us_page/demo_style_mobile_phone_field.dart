part of '../../pages/contact_us_page.dart';

class _DemoStyleMobilePhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool submitted, isRtl;
  final String selectedCode;
  final ValueChanged<String?> onCodeChanged;
  final Color primaryColor;

  const _DemoStyleMobilePhoneField({
    required this.controller,
    required this.submitted,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.isRtl,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = controller.text.trim().isEmpty;
    final bool showError = submitted && isEmpty;
    final String errMsg = isRtl ? 'هذا الحقل مطلوب' : 'This field is required';
    final String labelText = isRtl ? 'رقم الهاتف' : 'Phone Number';
    final String hintText = isRtl ? 'رقم الهاتف *' : 'Phone Number *';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label row with SVG prefix (same style as demo page) ──
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/demos/phone.svg',
              width: 14.w,
              height: 14.h,
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
            ),
            SizedBox(width: 5.w),
            Text(
              labelText,
              style: StyleText.fontSize13Weight400.copyWith(
                fontSize: 13.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        // ── Code picker + number input ──
        SizedBox(
          height: 46.h,
          child: Row(
            children: [
              // Code picker
              Container(
                height: 46.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCode,
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.sp,
                      color: Colors.grey.shade500,
                    ),
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: Colors.black87,
                      fontSize: 12.sp,
                    ),
                    dropdownColor: const Color(0xFFF5F5F5),
                    items: _phoneCodes
                        .map(
                          (c) => DropdownMenuItem<String>(
                        value: c['key'],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            c['value'] ?? '',
                            style: StyleText.fontSize12Weight400.copyWith(
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: onCodeChanged,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Number input
              Expanded(
                child: SizedBox(
                  height: 46.h,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    cursorColor: primaryColor,
                    style: StyleText.fontSize13Weight400.copyWith(
                      color: Colors.black87,
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 12.sp,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: showError
                              ? Colors.red.shade300
                              : Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError) ...[
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errMsg,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL MEDIA SECTION
// ═══════════════════════════════════════════════════════════════════════════════
