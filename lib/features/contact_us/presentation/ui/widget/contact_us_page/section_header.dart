part of '../../pages/contact_us_page.dart';

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final bool isRtl;
  const _SectionHeader({
    required this.title,
    required this.primaryColor,
    this.isRtl = false,
  });
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: StyleText.fontSize16Weight600.copyWith(
      color: primaryColor,
      fontSize: 14.sp,
    ),
    textAlign: isRtl ? TextAlign.right : TextAlign.left,
    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
  );
}
