part of '../../pages/contact_us_page.dart';

class _DesktopIconField extends StatefulWidget {
  final String label, hint, iconPath;
  final TextEditingController controller;
  final bool submitted;
  final Color primaryColor;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final int maxLines, minLength;
  final double fieldHeight;
  final bool onlyDigits;
  final bool forceRtlLabelAndHint;

  const _DesktopIconField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.iconPath,
    required this.submitted,
    required this.primaryColor,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.fieldHeight = 44,
    this.minLength = 0,
    this.onlyDigits = false,
    this.forceRtlLabelAndHint = false,
  });

  @override
  State<_DesktopIconField> createState() => _DesktopIconFieldState();
}

class _DesktopIconFieldState extends State<_DesktopIconField> {
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
    final bool isRtl = widget.textDirection == TextDirection.rtl;
    final bool useRtlForLabelHint = widget.forceRtlLabelAndHint || isRtl;

    final String errMsg = isEmpty
        ? (useRtlForLabelHint ? 'هذا الحقل مطلوب' : 'This field is required')
        : (useRtlForLabelHint
        ? 'الحد الأدنى ${widget.minLength} حرف'
        : 'Minimum ${widget.minLength} characters');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: useRtlForLabelHint ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            widget.label,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: widget.fieldHeight.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4.r),
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
                  left: useRtlForLabelHint ? 10.w : 10,
                  right: useRtlForLabelHint ? 10 : 10.w,
                  top: widget.maxLines > 1 ? 10.h : 0,
                ),
                child: SvgPicture.asset(
                  widget.iconPath,
                  width: 16.w,
                  height: 16.w,
                  color: widget.primaryColor,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  textDirection: useRtlForLabelHint
                      ? TextDirection.rtl
                      : widget.textDirection,
                  textAlign: useRtlForLabelHint
                      ? TextAlign.right
                      : widget.textAlign,
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
                      color: AppColors.secondaryBlack,
                      fontSize: 12.sp,
                    ),
                    hintTextDirection: useRtlForLabelHint
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: widget.maxLines > 1 ? 10.h : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError) ...[
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.only(
              left: useRtlForLabelHint ? 0 : 4.w,
              right: useRtlForLabelHint ? 4.w : 0,
            ),
            child: Text(
              errMsg,
              style: StyleText.fontSize12Weight400.copyWith(
                color: Colors.red,
                fontSize: 11.sp,
              ),
              textAlign: useRtlForLabelHint ? TextAlign.right : TextAlign.left,
              textDirection: useRtlForLabelHint
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ],
        SizedBox(height: 8.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DROPDOWN FIELD
// ═══════════════════════════════════════════════════════════════════════════════
