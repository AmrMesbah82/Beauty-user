part of '../../pages/about_us_page.dart';

class _DesktopTabItem extends StatefulWidget {
  final String label, iconUrl, selectedDesc;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _DesktopTabItem({
    required this.label,
    required this.iconUrl,
    required this.selectedDesc,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_DesktopTabItem> createState() => _DesktopTabItemState();
}

class _DesktopTabItemState extends State<_DesktopTabItem> {
  bool _hovered = false;

  // Get mainWidgetColor from HomeCmsCubit
  Color? get _mainWidgetColor {
    final homeState = context.watch<HomeCmsCubit>().state;
    return switch (homeState) {
      HomeCmsLoaded(:final data) => _parseHex(
        data.branding.mainWidgetColor,
        fallback: Colors.transparent,
      ),
      HomeCmsSaved(:final data) => _parseHex(
        data.branding.mainWidgetColor,
        fallback: Colors.transparent,
      ),
      _ => Colors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isSelected ? Colors.white : widget.primaryColor;
    final Color hoverBg = _hoverTint(widget.primaryColor);
    final Color? bgColor = _mainWidgetColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? bgColor  // ← Changed from _kSurface to bgColor
                : (_hovered ? hoverBg : bgColor),  // ← Changed from _kSurface to bgColor
            borderRadius: BorderRadius.circular(12.r),
            border: widget.isSelected
                ? Border.all(
              color: widget.primaryColor,
              width: 2.0,
            )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? widget.primaryColor
                          : widget.secondaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: widget.iconUrl.isNotEmpty
                          ? _netImg(
                        url: widget.iconUrl,
                        width: 20.sp,
                        height: 20.sp,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      )
                          : Icon(
                        Icons.image_outlined,
                        size: 20.sp,
                        color: iconColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: StyleText.fontSize18Weight500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isSelected && widget.selectedDesc.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  widget.selectedDesc,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: 11.sp,
                    height: 1.65,
                    color: AppColors.secondaryBlack,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Right Panel
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Right Panel (WITH MAIN WIDGET COLOR BACKGROUND)
// ══════════════════════════════════════════════════════════════════════════════
