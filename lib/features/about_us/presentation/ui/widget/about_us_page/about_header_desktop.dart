part of '../../pages/about_us_page.dart';

class _AboutHeaderDesktop extends StatelessWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutHeaderDesktop({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final String title = _ab(model.title, isRtl).isNotEmpty
        ? _ab(model.title, isRtl)
        : (isRtl ? 'من نحن' : 'About Us');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
      child: Text(
        title,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        style: StyleText.fontSize45Weight600.copyWith(
          fontSize: 48.sp,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
      ),
    );
  }
}
