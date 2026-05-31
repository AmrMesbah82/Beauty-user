part of '../../pages/overview_page.dart';

class _ArrowBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final bool filled;
  final Color primaryColor;

  const _ArrowBtn({
    required this.onTap,
    required this.icon,
    required this.filled,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled
              ? (enabled ? primaryColor : Colors.grey.shade300)
              : Colors.transparent,
          border: filled
              ? null
              : Border.all(
            color: enabled ? primaryColor : Colors.grey.shade300,
            width: 1.5.w,
          ),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: filled
              ? Colors.white
              : (enabled ? primaryColor : Colors.grey.shade400),
        ),
      ),
    );
  }
}
