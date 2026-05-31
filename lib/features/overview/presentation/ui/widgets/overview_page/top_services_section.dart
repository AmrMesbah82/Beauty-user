part of '../../pages/overview_page.dart';

class _TopServicesSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final List<OverviewServiceItemModel> items;
  final bool isAr;

  const _TopServicesSection({
    required this.primaryColor,
    required this.title,
    required this.items,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 24.h),
        // ✅ always a single horizontal scrollable row — no Wrap, no line breaks
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: items
                .map((item) => Padding(
              padding: EdgeInsetsDirectional.only(end: 20.w),
              child: _ServiceCard(
                imageUrl: item.imageUrl,
                name: isAr ? item.name.ar : item.name.en,
                primaryColor: primaryColor,
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
