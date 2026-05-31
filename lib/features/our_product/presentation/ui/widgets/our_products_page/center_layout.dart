part of '../../pages/our_products_page.dart';

class _CenterLayout extends StatelessWidget {
  final String title;
  final String body;
  final Widget imageWidget;
  final Color primaryColor;

  const _CenterLayout({
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
        children: [
          imageWidget,
          SizedBox(height: 20.h),
          Text(
            title,
            style: StyleText.fontSize18Weight500,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              body,
              style: StyleText.fontSize16Weight400.copyWith(
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
