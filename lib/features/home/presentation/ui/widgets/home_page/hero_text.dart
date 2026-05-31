part of '../../pages/home_page.dart';

class _HeroText extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color primaryColor;

  const _HeroText({
    required this.title,
    required this.subtitle,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: AppTextStyles.font23BlackSemiBoldCairo,
        ),
        SizedBox(height: 12.h),
        Text(
          FormatHelper.capitalize(subtitle),
          style: AppTextStyles.font20BlackCairoMedium.copyWith(
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — ABOUT US
// ══════════════════════════════════════════════════════════════════════════════
