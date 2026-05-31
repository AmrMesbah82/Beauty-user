part of '../../pages/overview_page.dart';

class _StoreBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final String svgAsset;

  const _StoreBadge({this.onTap, required this.svgAsset});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SvgPicture.asset(
          svgAsset,
          height: 42.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
