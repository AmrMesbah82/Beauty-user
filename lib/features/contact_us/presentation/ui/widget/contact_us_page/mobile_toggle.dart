part of '../../pages/contact_us_page.dart';

class _MobileToggle extends StatelessWidget {
  final String userType, clientLabel, ownerLabel;
  final Color primaryColor;
  final ValueChanged<String> onChanged;
  const _MobileToggle({
    required this.userType,
    required this.primaryColor,
    required this.clientLabel,
    required this.ownerLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: CustomSegmentedTabs(
        tabs: [clientLabel, ownerLabel],
        tabIcons: const [
          'assets/beauty/contact_us/client.svg',
          'assets/beauty/contact_us/owner.svg',
        ],
        selectedIndex: userType == ContactFormConstants.userTypeClient ? 0 : 1,
        onTabSelected: (i) => onChanged(
          i == 0
              ? ContactFormConstants.userTypeClient
              : ContactFormConstants.userTypeOwner,
        ),
        selectedColor: primaryColor,
        unselectedColor: Colors.transparent,
        selectedTextColor: Colors.white,
        unselectedTextColor: Colors.grey.shade500,
        containerColor: Colors.white,
        containerPadding: EdgeInsets.all(3.r),
        borderRadius: 10,
        equalWidth: true,
        spacing: 0,
        iconSize: 18,
        iconSpacing: 6.w,
        tabHorizontalPadding: 0,
        tabVerticalPadding: 0,
        textStyle: StyleText.fontSize13Weight400.copyWith(fontSize: 13.sp),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE DESCRIPTION TEXT — fully CMS-driven, no static fallback shown
// ═══════════════════════════════════════════════════════════════════════════════
