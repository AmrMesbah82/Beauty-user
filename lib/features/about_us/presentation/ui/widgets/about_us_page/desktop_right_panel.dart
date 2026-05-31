part of '../../pages/about_us_page.dart';

class _DesktopRightPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;

  const _DesktopRightPanel({
    required this.model,
    required this.tabIndex,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Get mainWidgetColor from HomeCmsCubit
    final homeState = context.watch<HomeCmsCubit>().state;
    final Color? mainWidgetColor = switch (homeState) {
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

    if (tabIndex == 2) {
      final otherValues = model.values.length > 1
          ? model.values.sublist(1)
          : <AboutValueItem>[];
      return _ValuesGridDesktop(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        backgroundColor: mainWidgetColor,  // ← Pass background color
      );
    }

    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: mainWidgetColor,  // ← Apply mainWidgetColor as background
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: 13.sp,
                height: 1.75,
              ),
            ),
          ),
          if (section.svgUrl.isNotEmpty) ...[
            SizedBox(width: 16.w),
            _netImg(
              url: section.svgUrl,
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Value Detail Panel
// ══════════════════════════════════════════════════════════════════════════════
