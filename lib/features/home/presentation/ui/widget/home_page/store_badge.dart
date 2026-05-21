part of '../../pages/home_page.dart';

class _StoreBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final String svgAsset;
  final double width;
  final double height;

  const _StoreBadge({
    this.onTap,
    required this.svgAsset,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: SvgPicture.asset(
          svgAsset,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
