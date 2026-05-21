part of '../../pages/contact_us_page.dart';

class _FormLabel extends StatelessWidget {
  final String label;
  final bool isRtl;
  const _FormLabel({required this.label, this.isRtl = false});

  @override
  Widget build(BuildContext context) => Align(
    alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
    child: Text(
      label,
      style: StyleText.fontSize14Weight400.copyWith(
        color: AppColors.text,
        fontSize: 14.sp,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEFT ILLUSTRATION PANEL — fully CMS-driven, no static text
// ═══════════════════════════════════════════════════════════════════════════════
