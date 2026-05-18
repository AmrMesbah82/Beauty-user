import 'package:beauty_user/core/custom_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../theme/appcolors.dart';
import '../theme/new_theme.dart';

class CustomDropdownFormFieldInvMaster extends StatefulWidget {
  final String? selectedValue;
  final double? widthIcon;
  final Color? primaryColor;
  final Color? dropdownColor;
  final double? heightIcon;
  final List<Map<String, String>> items;
  final Function(String?) onChanged;
  final String Function(String?)? validator;
  final double? width;
  final double? height;
  final double? spaceHeight;
  final double? dropdownWidth;
  final Widget? hint;
  final String? label;
  final String? iconPath;
  final Map<String, Color>? itemColors;
  final bool showColorDots;
  final double borderRadius;

  // ── text direction ────────────────────────────────────────────────────────
  final TextDirection textDirection;

  // ── label-row prefix / trailing SVG icons ────────────────────────────────
  final String? labelPrefixSvg;
  final double? labelPrefixSvgSize;
  final Color?  labelPrefixColor;

  final String? labelTrailingSvg;
  final double? labelTrailingSvgSize;
  final Color?  labelTrailingColor;
  final VoidCallback? onLabelTrailingTap;

  const CustomDropdownFormFieldInvMaster({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    this.validator,
    this.primaryColor,
    this.width,
    this.height,
    this.spaceHeight,
    this.dropdownWidth,
    this.hint,
    this.dropdownColor,
    this.label,
    this.iconPath,
    this.itemColors,
    this.showColorDots = false,
    this.borderRadius  = 8.0,
    this.textDirection = TextDirection.ltr,
    this.labelPrefixSvg,
    this.labelPrefixSvgSize,
    this.labelPrefixColor,
    this.labelTrailingSvg,
    this.labelTrailingSvgSize,
    this.labelTrailingColor,
    this.onLabelTrailingTap,
  }) : super(key: key);

  @override
  State<CustomDropdownFormFieldInvMaster> createState() =>
      _CustomDropdownFormFieldInvMasterState();
}

class _CustomDropdownFormFieldInvMasterState
    extends State<CustomDropdownFormFieldInvMaster> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;

  bool get _isRtl => widget.textDirection == TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    internalSelectedValue = widget.selectedValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _dropdownKey.currentContext;
      if (ctx != null && mounted) {
        final box = ctx.findRenderObject() as RenderBox;
        setState(() => _popupWidth = box.size.width);
      }
    });
  }

  @override
  void didUpdateWidget(CustomDropdownFormFieldInvMaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      internalSelectedValue = widget.selectedValue;
    }
  }

  Color? _getItemColor(Map<String, String> item) {
    if (widget.itemColors == null) return null;
    final key   = item['key']   ?? '';
    final value = item['value'] ?? '';
    return widget.itemColors![key] ?? widget.itemColors![value];
  }

  // ── Dropdown item ─────────────────────────────────────────────────────────
  Widget _buildDropdownItem(Map<String, String> item) {
    final Color? itemColor = _getItemColor(item);
    final String text      = item['value'] ?? '';

    if (widget.showColorDots && itemColor != null) {
      return Directionality(
        textDirection: widget.textDirection,
        child: Row(children: [
          Container(
            width: 8.sp, height: 8.sp,
            decoration:
            BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(text,
                textDirection: widget.textDirection,
                style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.text,
                    overflow: TextOverflow.ellipsis)),
          ),
        ]),
      );
    }

    return Directionality(
      textDirection: widget.textDirection,
      child: Align(
        alignment: _isRtl ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text,
            textDirection: widget.textDirection,
            textAlign:     _isRtl ? TextAlign.right : TextAlign.left,
            style: StyleText.fontSize12Weight400.copyWith(
                color: itemColor ?? AppColors.text,
                overflow: TextOverflow.ellipsis)),
      ),
    );
  }

  Widget _arrowIcon() => CustomSvg(
    assetPath: "assets/arrowdown.svg",
    width: 20.w, height: 20.h,
  );

  Widget? _buildCustomButton(double fieldHeight) {
    if (widget.iconPath == null) return null;
    final bool hasValue = internalSelectedValue != null &&
        widget.items.any((e) => e['key'] == internalSelectedValue);
    final String displayText = hasValue
        ? (widget.items
        .firstWhere((e) => e['key'] == internalSelectedValue)['value'] ??
        '')
        : '';

    return Directionality(
      textDirection: widget.textDirection,
      child: Container(
        height:  fieldHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color:        widget.dropdownColor ?? const Color(0xFFF1F2ED),
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border:       Border.all(color: Colors.transparent),
        ),
        child: Row(children: [
          SvgPicture.asset(widget.iconPath!,
              width:  (widget.widthIcon  ?? 16).w,
              height: (widget.heightIcon ?? 16).w,
              colorFilter: widget.primaryColor != null
                  ? ColorFilter.mode(widget.primaryColor!, BlendMode.srcIn)
                  : null),
          SizedBox(width: 6.w),
          Expanded(
            child: hasValue
                ? Text(displayText,
                textDirection: widget.textDirection,
                textAlign: _isRtl ? TextAlign.right : TextAlign.left,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.text),
                overflow: TextOverflow.ellipsis)
                : DefaultTextStyle.merge(
                child: widget.hint ?? const SizedBox.shrink()),
          ),
          _arrowIcon(),
        ]),
      ),
    );
  }

  // ── Label row ─────────────────────────────────────────────────────────────
  // Uses full-width Row + mainAxisAlignment to pin content to the correct side.
  Widget _buildLabelRow() {
    final double prefixSize   = widget.labelPrefixSvgSize  ?? 14;
    final double trailingSize = widget.labelTrailingSvgSize ?? 14;

    final Widget? prefixIcon = widget.labelPrefixSvg != null
        ? SvgPicture.asset(
      widget.labelPrefixSvg!,
      width:  prefixSize.w,
      height: prefixSize.h,
      colorFilter: widget.labelPrefixColor != null
          ? ColorFilter.mode(widget.labelPrefixColor!, BlendMode.srcIn)
          : null,
    )
        : null;

    final Widget labelText = Text(
      widget.label!,
      textDirection: widget.textDirection,
      style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
    );

    final Widget? trailingIcon = widget.labelTrailingSvg != null
        ? GestureDetector(
      onTap: widget.onLabelTrailingTap,
      child: SvgPicture.asset(
        widget.labelTrailingSvg!,
        width:  trailingSize.w,
        height: trailingSize.h,
        colorFilter: widget.labelTrailingColor != null
            ? ColorFilter.mode(
            widget.labelTrailingColor!, BlendMode.srcIn)
            : null,
      ),
    )
        : null;

    // Build the inner content (icon + gap + text) as a minimal row
    // then wrap it in a full-width row aligned to the correct side
    final List<Widget> innerChildren = [];

    if (_isRtl) {
      // RTL: text first (rightmost), then gap, then icon
      innerChildren.add(labelText);
      if (prefixIcon != null) {
        innerChildren.add(SizedBox(width: 5.w));
        innerChildren.add(prefixIcon);
      }
      if (trailingIcon != null) {
        innerChildren.add(SizedBox(width: 5.w));
        innerChildren.add(trailingIcon);
      }
    } else {
      // LTR: icon first (leftmost), then gap, then text
      if (prefixIcon != null) {
        innerChildren.add(prefixIcon);
        innerChildren.add(SizedBox(width: 5.w));
      }
      innerChildren.add(labelText);
      if (trailingIcon != null) {
        innerChildren.add(SizedBox(width: 5.w));
        innerChildren.add(trailingIcon);
      }
    }

    // Full-width row that aligns content to start (right for RTL, left for LTR)
    return Row(
      mainAxisSize:      MainAxisSize.max,
      mainAxisAlignment: _isRtl ? MainAxisAlignment.start : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: innerChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = widget.height ?? 36;

    final Widget? localizedHint = widget.hint == null
        ? null
        : Directionality(
      textDirection: widget.textDirection,
      child: widget.hint!,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // full width always
      children: [
        if (widget.label != null) ...[
          _buildLabelRow(),
          SizedBox(height: widget.spaceHeight ?? 6.h),
        ],

        Directionality(
          textDirection: widget.textDirection,
          child: Container(
            key:    _dropdownKey,
            width:  widget.width,
            height: fieldHeight.h,
            decoration: BoxDecoration(
              color:        widget.dropdownColor ?? AppColors.background,
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
            ),
            child: FormField<String>(
              initialValue: internalSelectedValue,
              validator:    widget.validator,
              builder: (FormFieldState<String> field) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint:       localizedHint,
                    value: widget.items.any(
                            (e) => e['key'] == internalSelectedValue)
                        ? internalSelectedValue
                        : null,
                    onChanged: (value) {
                      setState(() {
                        internalSelectedValue = value;
                        field.didChange(value);
                      });
                      widget.onChanged(value);
                    },
                    customButton: _buildCustomButton(fieldHeight),
                    buttonStyleData: ButtonStyleData(
                      height:  fieldHeight.h,
                      width:   widget.width?.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: widget.dropdownColor ??
                            const Color(0xFFF1F2ED),
                        borderRadius:
                        BorderRadius.circular(widget.borderRadius.r),
                        border: Border.all(color: Colors.transparent),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: widget.dropdownWidth ??
                          _popupWidth ??
                          widget.width ??
                          100.w,
                      maxHeight: 225.h,
                      offset:    const Offset(0, 0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                        BorderRadius.circular(widget.borderRadius.r),
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color:      Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset:     const Offset(0, 2),
                          ),
                        ],
                      ),
                      scrollbarTheme: ScrollbarThemeData(
                        thumbVisibility:
                        MaterialStateProperty.all(false),
                        trackVisibility:
                        MaterialStateProperty.all(false),
                        thickness: MaterialStateProperty.all(0),
                        radius:    Radius.zero,
                      ),
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height:  fieldHeight.h,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      overlayColor:
                      MaterialStateProperty.resolveWith<Color?>(
                              (states) {
                            if (states.contains(MaterialState.hovered)) {
                              return (widget.primaryColor ?? AppColors.primary)
                                  .withOpacity(0.1);
                            }
                            return null;
                          }),
                    ),
                    iconStyleData: IconStyleData(
                      icon: widget.iconPath != null
                          ? const SizedBox.shrink()
                          : _arrowIcon(),
                    ),
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text),
                    items: widget.items.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit['key'],
                        child: _buildDropdownItem(unit),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}