part of '../../pages/our_products_page.dart';

class _SideBySideLayout extends StatelessWidget {
  final String title;
  final String body;
  final Widget imageWidget;
  final Color primaryColor;
  final bool imageOnLeft;

  const _SideBySideLayout({
    required this.title,
    required this.body,
    required this.imageWidget,
    required this.primaryColor,
    required this.imageOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = _getMainWidgetColor(context);

    final textWidget = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          body,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            height: 1.7,
            color: AppColors.secondaryBlack,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: imageOnLeft
            ? [
          Expanded(flex: 4, child: imageWidget),
          SizedBox(width: 30.w),
          Expanded(flex: 6, child: textWidget),
        ]
            : [
          Expanded(flex: 6, child: textWidget),
          SizedBox(width: 30.w),
          Expanded(flex: 4, child: imageWidget),
        ],
      ),
    );
  }
}
