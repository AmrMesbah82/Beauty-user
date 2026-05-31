part of '../../pages/our_products_page.dart';

class _StackedFallback extends StatelessWidget {
  final String title;
  final String body;
  final Widget imageWidget;
  final Color primaryColor;

  const _StackedFallback({
    required this.title,
    required this.body,
    required this.imageWidget,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = _getMainWidgetColor(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: imageWidget),
          SizedBox(height: 16.h),
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
      ),
    );
  }
}
