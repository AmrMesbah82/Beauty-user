part of '../../pages/our_products_page.dart';

class _ProductsTabBar extends StatelessWidget {
  final int selectedIndex;
  final Color primaryColor;
  final bool isAr;
  final ValueChanged<int> onTabSelected;

  const _ProductsTabBar({
    required this.selectedIndex,
    required this.primaryColor,
    required this.isAr,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final labels = isAr
        ? ['خدمة العميل', 'خدمة المالك']
        : ['Client Service', 'Owner Service'];

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 400.w,
        ),
        child: CustomSegmentedTabs(
          tabs: labels,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          selectedColor: primaryColor,
          unselectedColor: Colors.transparent,
          selectedTextColor: Colors.white,
          unselectedTextColor: Colors.black.withOpacity(.6),
          containerColor: Colors.white,
          borderRadius: 8,
          spacing: 0,
          tabHorizontalPadding: 28.w,
          tabVerticalPadding: 10.h,
          textStyle: StyleText.fontSize14Weight400.copyWith(),
          equalWidth: true,
          containerPadding: EdgeInsets.all(4.r),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OUR PRODUCTS PAGE ROOT
// FIXED: accepts initialTab so Navigator.push() from footer works correctly
// UPDATED: "Request Demo" button is inline in the column (above footer gap),
//          shown only on Owner Services tab. FAB removed entirely.
// UPDATED: Gender-aware primary color applied
// ══════════════════════════════════════════════════════════════════════════════
