part of '../../pages/contact_us_page.dart';

class _DemoStylePhoneField extends StatefulWidget {
  final TextEditingController controller;
  final bool submitted, isMobile, isRtl;
  final String selectedCode, label;
  final ValueChanged<String?> onCodeChanged;
  final Color primaryColor;

  const _DemoStylePhoneField({
    required this.controller,
    required this.submitted,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.isRtl,
    required this.label,
    required this.primaryColor,
    this.isMobile = false,
  });

  @override
  State<_DemoStylePhoneField> createState() => _DemoStylePhoneFieldState();
}

class _DemoStylePhoneFieldState extends State<_DemoStylePhoneField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.controller.text.trim().isEmpty;
    final bool showError = widget.submitted && isEmpty;
    final String errMsg = widget.isRtl
        ? 'هذا الحقل مطلوب'
        : 'This field is required';
    final String hintText = widget.isRtl
        ? 'أدخل رقم هاتفك'
        : 'Enter your number';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label row — matches demo page labelPrefixSvg style ──
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [


            Text(
              widget.label,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        // ── Code picker + number input row ──
        SizedBox(
          // height: 32.h,
          child: Row(
            children: [
              // Code picker box
              Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.selectedCode,
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14.sp,
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
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
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
                    onChanged: widget.onCodeChanged,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Number input
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: TextField(
                    controller: widget.controller,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textDirection: widget.isRtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    textAlign:
                    widget.isRtl ? TextAlign.right : TextAlign.left,
                    cursorColor: widget.primaryColor,
                    style: StyleText.fontSize13Weight400.copyWith(
                      color: Colors.black87,
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryBlack,
                        fontSize: 12.sp,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 15.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(
                          color: showError
                              ? Colors.red.shade300
                              : Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(
                          color: widget.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) {
                      if (widget.submitted) setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError) ...[
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errMsg,
              style: StyleText.fontSize12Weight400.copyWith(
                color: Colors.red,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
        SizedBox(height: 8.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER / FORM LABEL
// ═══════════════════════════════════════════════════════════════════════════════
