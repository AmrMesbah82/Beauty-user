part of '../../pages/contact_us_page.dart';

class _MobileIconField extends StatefulWidget {
  final TextEditingController controller;
  final String hint, iconPath;
  final bool submitted;
  final Color primaryColor;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final int maxLines, minLength;
  final double height;
  final bool onlyDigits;

  const _MobileIconField({
    required this.controller,
    required this.hint,
    required this.iconPath,
    required this.submitted,
    required this.primaryColor,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLength = 0,
    this.height = 46,
    this.onlyDigits = false,
  });

  @override
  State<_MobileIconField> createState() => _MobileIconFieldState();
}

class _MobileIconFieldState extends State<_MobileIconField> {
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
    final bool isTooShort =
        !isEmpty &&
            widget.minLength > 0 &&
            widget.controller.text.trim().length < widget.minLength;
    final bool showError = widget.submitted && (isEmpty || isTooShort);
    final bool isRtlDir = widget.textDirection == TextDirection.rtl;
    final String errMsg = isEmpty
        ? (isRtlDir ? 'هذا الحقل مطلوب' : 'This field is required')
        : (isRtlDir
        ? 'الحد الأدنى ${widget.minLength} حرف'
        : 'Minimum ${widget.minLength} characters');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8.r),
            border: showError
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: widget.maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: isRtlDir ? 0 : 12.w,
                  right: isRtlDir ? 12.w : 0,
                  top: widget.maxLines > 1 ? 13.h : 0,
                ),
                child: SvgPicture.asset(
                  widget.iconPath,
                  width: 18.w,
                  height: 18.w,
                  colorFilter: ColorFilter.mode(
                    showError ? Colors.red.shade300 : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  textDirection: widget.textDirection,
                  textAlign: widget.textAlign,
                  keyboardType: widget.onlyDigits
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: widget.onlyDigits
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  cursorColor: widget.primaryColor,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color: Colors.black87,
                    fontSize: 13.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 12.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: widget.maxLines > 1 ? 12.h : 0,
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
// MOBILE ICON DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════
