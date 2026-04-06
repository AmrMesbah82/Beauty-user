// ******************* FILE INFO *******************
// File Name: home_page.dart
// Description: Public-facing Home Page for the Beauty App (Bayanatz).
//              Three sections: Hero, About Us, Download App.
//              Hero title/subtitle → CMS-driven via HomeCmsCubit.
//              About Us & Download App → static text (not from Firebase).
// Created by: Claude for Amr Mesbah
// FIX: All SVG assets use SvgPicture.asset() — NOT Image.asset()
//      Image.asset cannot decode SVG files (throws ImageCodecException on web).
// FIX: Hero phones use LayoutBuilder to prevent Row overflow.
// FIX: Store badges use SvgPicture.asset() for .svg files.
// FIX: Store badges wrapped in Wrap to prevent overflow on narrow screens.
// FIX: About Us & Download App sections — static text, NOT from Firebase.

import 'package:beauty_user/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../theme/appcolors.dart';
import '../widgets/app_page_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — parse hex color from branding
// ─────────────────────────────────────────────────────────────────────────────

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ─────────────────────────────────────────────────────────────────────────────
// STATIC TEXT CONSTANTS (not from Firebase — as per Figma design)
// ─────────────────────────────────────────────────────────────────────────────

const String _aboutUsBodyEn =
    'Welcome to Beauty App, where beauty meets tranquility. '
    'Step into our elegant sanctuary and let us indulge your senses with luxurious nail, hair, '
    'makeup, and massage treatments. Our talented technicians combine artistry with '
    'precision to create stunning nails, ensuring you leave feeling refreshed, confident, and '
    'truly pampered. Embrace self-care and let us bring out your natural beauty!';

const String _aboutUsBodyAr =
    'مرحبًا بكم في تطبيق Beauty، حيث يلتقي الجمال بالهدوء. '
    'ادخلوا إلى ملاذنا الأنيق ودعونا ندلل حواسكم بعلاجات فاخرة للأظافر والشعر '
    'والمكياج والمساج. يجمع فنيونا الموهوبون بين الفن والدقة لإبداع أظافر مذهلة، '
    'مما يضمن أن تغادروا وأنتم تشعرون بالانتعاش والثقة والراحة التامة. '
    'احتضنوا العناية الذاتية ودعونا نبرز جمالكم الطبيعي!';

const String _downloadBodyEn =
    'At Beauty, you will find luxury services. Whether you\'re seeking a fresh new look '
    'or any service, our team of skilled beauty professionals is here to make your '
    'dreams a reality.';

const String _downloadBodyAr =
    'في Beauty، ستجدون خدمات فاخرة. سواء كنتم تبحثون عن إطلالة جديدة '
    'أو أي خدمة، فإن فريقنا من محترفي التجميل المهرة موجود لتحقيق أحلامكم.';

// ─────────────────────────────────────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final data = switch (homeState) {
          HomeCmsLoaded(:final data) => data,
          HomeCmsSaved(:final data) => data,
          HomeCmsSaving(:final data) => data,
          HomeCmsError(:final lastData) => lastData,
          _ => null,
        };

        if (data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final primaryColor = _parseHex(
          data.branding.primaryColor,
          fallback: AppColors.primary,
        );

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isAr = langState.isArabic;

            return AppPageShell(
              currentRoute: '/',
              body: Column(
                children: [
                  // ═══════════════════════════════════════════════════════════
                  // SECTION 1 — HERO (CMS-driven: data.title & data.shortDescription)
                  // ═══════════════════════════════════════════════════════════
                  _HeroSection(
                    primaryColor: primaryColor,
                    title: isAr ? data.title.ar : data.title.en,
                    subtitle: isAr
                        ? data.shortDescription.ar
                        : data.shortDescription.en,
                  ),

                  SizedBox(height: 40.h),

                  // ═══════════════════════════════════════════════════════════
                  // SECTION 2 — ABOUT US (⚠️ static text — NOT from Firebase)
                  // ═══════════════════════════════════════════════════════════
                  _AboutUsSection(
                    primaryColor: primaryColor,
                    heading: isAr ? 'من نحن' : 'About Us',
                    body: isAr ? _aboutUsBodyAr : _aboutUsBodyEn,
                    readMoreLabel: isAr ? 'اقرأ المزيد' : 'Read More',
                    onReadMore: () {
                      // TODO: navigate to about page
                    },
                  ),

                  SizedBox(height: 40.h),

                  // ═══════════════════════════════════════════════════════════
                  // SECTION 3 — DOWNLOAD APP (⚠️ static text — NOT from Firebase)
                  // ═══════════════════════════════════════════════════════════
                  _DownloadAppSection(
                    primaryColor: primaryColor,
                    heading: isAr
                        ? 'حمّل تطبيق Beauty الآن'
                        : 'Download Beauty App Now',
                    body: isAr ? _downloadBodyAr : _downloadBodyEn,
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — HERO
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String subtitle;

  const _HeroSection({
    required this.primaryColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _HeroPhones(),
                ),
                SizedBox(width: 30.w),
                Expanded(
                  flex: 5,
                  child: _HeroText(
                    title: title,
                    subtitle: subtitle,
                    primaryColor: primaryColor,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _HeroPhones(),
              SizedBox(height: 24.h),
              _HeroText(
                title: title,
                subtitle: subtitle,
                primaryColor: primaryColor,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroPhones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Back phone (slightly left & tilted) ──
              Positioned(
                left: w * 0.05,
                top: 20.h,
                child: Transform.rotate(
                  angle: -0.08,
                  child: SvgPicture.asset(
                    'assets/beauty/home/second_phone.svg',
                    height: 280.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // ── Front phone (center, slightly overlapping) ──
              Positioned(
                left: w * 0.2,
                top: 0,
                child: SvgPicture.asset(
                  'assets/beauty/home/phone_home.svg',
                  height: 300.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
          title,
          style: AppTextStyles.font23BlackSemiBoldCairo,
        ),
        SizedBox(height: 12.h),
        Text(
          subtitle,
          style: AppTextStyles.font20BlackCairoMedium.copyWith(
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — ABOUT US (static text)
// ─────────────────────────────────────────────────────────────────────────────

class _AboutUsSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String readMoreLabel;
  final VoidCallback? onReadMore;

  const _AboutUsSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    required this.readMoreLabel,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ──
          Text(
            heading,
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Body text ──
          Text(
            body,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
              height: 1.7,
              color: AppColors.secondaryBlack,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Read More ──
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InkWell(
              onTap: onReadMore,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      readMoreLabel,
                      style: AppTextStyles.font14BlackCairoMedium.copyWith(
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14.sp,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — DOWNLOAD APP (static text)
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadAppSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;

  const _DownloadAppSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: _DownloadPhoneMockup(primaryColor: primaryColor),
                ),
                SizedBox(width: 30.w),
                Expanded(
                  flex: 6,
                  child: _DownloadTextContent(
                    primaryColor: primaryColor,
                    heading: heading,
                    body: body,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _DownloadPhoneMockup(primaryColor: primaryColor),
              SizedBox(height: 24.h),
              _DownloadTextContent(
                primaryColor: primaryColor,
                heading: heading,
                body: body,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DownloadPhoneMockup extends StatelessWidget {
  final Color primaryColor;

  const _DownloadPhoneMockup({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 2.w,
        ),
        color: primaryColor.withOpacity(0.04),
      ),
      child: SvgPicture.asset(
        'assets/beauty/home/phone_home.svg',
        height: 280.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _DownloadTextContent extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;

  const _DownloadTextContent({
    required this.primaryColor,
    required this.heading,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Heading ──
        Text(
          heading,
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
          ),
        ),
        SizedBox(height: 16.h),

        // ── Body text ──
        if (body.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              body,
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
              ),
            ),
          ),

        // ── Store Badges ──
        // ✅ SvgPicture.asset for .svg files — works on web + mobile
        // ✅ Wrap prevents overflow on narrow screens
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            _StoreBadge(
              onTap: () {
                // TODO: launch Google Play URL
              },
              svgAsset: 'assets/beauty/home/google_play.svg',
            ),
            _StoreBadge(
              onTap: () {
                // TODO: launch App Store URL
              },
              svgAsset: 'assets/beauty/home/app_store.svg',
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE BADGE BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _StoreBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final String svgAsset;

  const _StoreBadge({
    this.onTap,
    required this.svgAsset,
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
          height: 42.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}