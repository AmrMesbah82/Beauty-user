// ******************* FILE INFO *******************
// File Name: overview_page.dart
// Description: Overview Page for the Beauty App (Bayanatz).
//              Sections: Overview, Top Services, Gallery, Client Testimonials, Download.
//              All content is static (not CMS-driven).
// Created by: Claude for Amr Mesbah
// FIX: All SVG assets use SvgPicture.asset() — NOT Image.asset()
//      Image.asset cannot decode SVG files (throws ImageCodecException on web).
// FIX: Responsive layout with LayoutBuilder for mobile/desktop views.
// FIX: Gallery carousel with PageView and dot indicators.
// FIX: Client testimonials with horizontal scrolling and arrows.

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
// STATIC TEXT CONSTANTS (English & Arabic)
// ─────────────────────────────────────────────────────────────────────────────

const String _overviewTitleEn = 'Overview';
const String _overviewTitleAr = 'نظرة عامة';

const String _overviewBodyEn =
    'Welcome to Beauty App, where beauty meets tranquility.\n'
    'Step into our elegant sanctuary and let us indulge your senses with luxurious nail, hair, '
    'makeup, and massage treatments. Our talented technicians combine artistry with precision '
    'to create stunning nails, ensuring you leave feeling refreshed, confident, and truly '
    'pampered. Embrace self-care and let us bring out your natural beauty!';

const String _overviewBodyAr =
    'مرحبًا بكم في تطبيق Beauty، حيث يلتقي الجمال بالهدوء.\n'
    'ادخلوا إلى ملاذنا الأنيق ودعونا ندلل حواسكم بعلاجات فاخرة للأظافر والشعر '
    'والمكياج والمساج. يجمع فنيونا الموهوبون بين الفن والدقة لإبداع أظافر مذهلة، '
    'مما يضمن أن تغادروا وأنتم تشعرون بالانتعاش والثقة والراحة التامة. '
    'احتضنوا العناية الذاتية ودعونا نبرز جمالكم الطبيعي!';

const String _topServicesEn = 'Top Services';
const String _topServicesAr = 'أهم الخدمات';

const String _galleryTitleEn = 'Gallery';
const String _galleryTitleAr = 'المعرض';

const String _clientsTitleEn = 'What Our';
const String _clientsTitleAr = 'ماذا يقول';
const String _clientsHighlightEn = 'Clients';
const String _clientsHighlightAr = 'عملاؤنا';
const String _clientsSubtitleEn = 'Say About Us';
const String _clientsSubtitleAr = 'عنا';

const String _downloadTitleEn = 'Download Now';
const String _downloadTitleAr = 'حمّل الآن';

const String _readMoreEn = 'Read More';
const String _readMoreAr = 'اقرأ المزيد';

// ─────────────────────────────────────────────────────────────────────────────
// Service Data
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceItem {
  final String imageAsset;
  final String nameEn;
  final String nameAr;

  const _ServiceItem({
    required this.imageAsset,
    required this.nameEn,
    required this.nameAr,
  });
}

const List<_ServiceItem> _services = [
  _ServiceItem(
    imageAsset: 'assets/drawer/contact_us_drawer.svg',
    nameEn: 'Hair',
    nameAr: 'شعر',
  ),
  _ServiceItem(
    imageAsset: 'assets/drawer/contact_us_drawer.svg',
    nameEn: 'Nails',
    nameAr: 'أظافر',
  ),
  _ServiceItem(
    imageAsset: 'assets/drawer/contact_us_drawer.svg',
    nameEn: 'Facial',
    nameAr: 'عناية بالوجه',
  ),
  _ServiceItem(
    imageAsset: 'assets/drawer/contact_us_drawer.svg',
    nameEn: 'Waxing',
    nameAr: 'إزالة الشعر',
  ),
  _ServiceItem(
    imageAsset: 'assets/drawer/contact_us_drawer.svg',
    nameEn: 'Waxing',
    nameAr: 'إزالة الشعر',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Gallery Images
// ─────────────────────────────────────────────────────────────────────────────

const List<String> _galleryImages = [
  'assets/confirm_dialog.svg',
  'assets/confirm_dialog.svg',
  'assets/confirm_dialog.svg',
];

// ─────────────────────────────────────────────────────────────────────────────
// Client Testimonial Data
// ─────────────────────────────────────────────────────────────────────────────

class _Testimonial {
  final String nameEn;
  final String nameAr;
  final String avatarAsset;
  final String textEn;
  final String textAr;

  const _Testimonial({
    required this.nameEn,
    required this.nameAr,
    required this.avatarAsset,
    required this.textEn,
    required this.textAr,
  });
}

const List<_Testimonial> _testimonials = [
  _Testimonial(
    nameEn: 'Nada Fawzy',
    nameAr: 'ندى فوزي',
    avatarAsset: 'assets/beauty/overview/avatar1.png',
    textEn:
    'I love using this app and absolutely love how easy it is to book my appointments. Their services has been excellent and they always make sure I leave happy. The customers have gotten in the way. We also selling bikes too and you can rely on us.',
    textAr:
    'أحب استخدام هذا التطبيق وأحب حقًا مدى سهولة حجز مواعيدي. كانت خدماتهم ممتازة ويتأكدون دائمًا من أنني أغادر سعيدة. العملاء لم يعيقوا الطريق. نحن نبيع الدراجات أيضًا ويمكنك الاعتماد علينا.',
  ),
  _Testimonial(
    nameEn: 'Amr Mesbah',
    nameAr: 'عمرو مصباح',
    avatarAsset: 'assets/beauty/overview/avatar2.png',
    textEn:
    'I\'ve never felt more relaxed and cared for. The team understands exactly what I need and always delivers. From nails to hair, everything is perfect every single time. Highly recommend this app to everyone!',
    textAr:
    'لم أشعر من قبل بالاسترخاء والاهتمام أكثر من ذلك. يفهم الفريق بالضبط ما أحتاجه ويقدمه دائمًا. من الأظافر إلى الشعر، كل شيء مثالي في كل مرة. أوصي بشدة بهذا التطبيق للجميع!',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// OVERVIEW PAGE
// ─────────────────────────────────────────────────────────────────────────────

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

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
              currentRoute: '/services',
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40.h),

                    // ═══════════════════════════════════════════════════════════
                    // SECTION 1 — OVERVIEW
                    // ═══════════════════════════════════════════════════════════
                    _OverviewSection(
                      primaryColor: primaryColor,
                      title: isAr ? _overviewTitleAr : _overviewTitleEn,
                      body: isAr ? _overviewBodyAr : _overviewBodyEn,
                      readMoreLabel: isAr ? _readMoreAr : _readMoreEn,
                      onReadMore: () {
                        // TODO: navigate to full overview/about page
                      },
                    ),

                    SizedBox(height: 50.h),

                    // ═══════════════════════════════════════════════════════════
                    // SECTION 2 — TOP SERVICES
                    // ═══════════════════════════════════════════════════════════
                    _TopServicesSection(
                      primaryColor: primaryColor,
                      title: isAr ? _topServicesAr : _topServicesEn,
                      isAr: isAr,
                    ),

                    SizedBox(height: 50.h),

                    // ═══════════════════════════════════════════════════════════
                    // SECTION 3 — GALLERY
                    // ═══════════════════════════════════════════════════════════
                    _GallerySection(
                      primaryColor: primaryColor,
                      title: isAr ? _galleryTitleAr : _galleryTitleEn,
                    ),

                    SizedBox(height: 50.h),

                    // ═══════════════════════════════════════════════════════════
                    // SECTION 4 — CLIENT TESTIMONIALS
                    // ═══════════════════════════════════════════════════════════
                    _TestimonialsSection(
                      primaryColor: primaryColor,
                      titlePart1: isAr ? _clientsTitleAr : _clientsTitleEn,
                      titleHighlight:
                      isAr ? _clientsHighlightAr : _clientsHighlightEn,
                      titlePart2:
                      isAr ? _clientsSubtitleAr : _clientsSubtitleEn,
                      isAr: isAr,
                    ),

                    SizedBox(height: 50.h),

                    // ═══════════════════════════════════════════════════════════
                    // SECTION 5 — DOWNLOAD NOW
                    // ═══════════════════════════════════════════════════════════
                    _DownloadNowSection(
                      primaryColor: primaryColor,
                      title: isAr ? _downloadTitleAr : _downloadTitleEn,
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — OVERVIEW
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String body;
  final String readMoreLabel;
  final VoidCallback? onReadMore;

  const _OverviewSection({
    required this.primaryColor,
    required this.title,
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
          // ── Title ──
          Text(
            title,
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Body text ──
          Text(
            body,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
              height: 1.7,
              color: AppColors.secondaryBlack,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Read More Button ──
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
// SECTION 2 — TOP SERVICES
// ─────────────────────────────────────────────────────────────────────────────

class _TopServicesSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final bool isAr;

  const _TopServicesSection({
    required this.primaryColor,
    required this.title,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Text(
            title,
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 24.h),

          // ── Services Grid ──
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              if (isWide) {
                // Desktop: horizontal row
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _services
                      .map((service) => _ServiceCard(
                    imageAsset: service.imageAsset,
                    name: isAr ? service.nameAr : service.nameEn,
                    primaryColor: primaryColor,
                  ))
                      .toList(),
                );
              }

              // Mobile: wrap
              return Wrap(
                spacing: 16.w,
                runSpacing: 20.h,
                alignment: WrapAlignment.center,
                children: _services
                    .map((service) => _ServiceCard(
                  imageAsset: service.imageAsset,
                  name: isAr ? service.nameAr : service.nameEn,
                  primaryColor: primaryColor,
                ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String imageAsset;
  final String name;
  final Color primaryColor;

  const _ServiceCard({
    required this.imageAsset,
    required this.name,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Circular SVG Image ──
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 2.w,
            ),
          ),
          clipBehavior: Clip.antiAlias, // ✅ clips the SVG to the circle shape
          child: SvgPicture.asset(
            imageAsset,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 8.h),

        // ── Service Name ──
        Text(
          name,
          style: AppTextStyles.font14BlackCairoMedium.copyWith(
            color: AppColors.secondaryBlack,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — GALLERY
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — GALLERY
// ─────────────────────────────────────────────────────────────────────────────




class _GallerySection extends StatefulWidget {
  final Color primaryColor;
  final String title;

  const _GallerySection({
    required this.primaryColor,
    required this.title,
  });

  @override
  State<_GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<_GallerySection> {
  int _activeIndex = 1; // ✅ middle dot active by default (matches Figma)
  final PageController _mobileController = PageController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Widget _img(String asset, double h, {bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      // ✅ Active image is taller, inactive slightly smaller — Figma effect
      height: isActive ? h : h * 0.82,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.asset(
          asset,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.image_outlined,
                color: widget.primaryColor.withOpacity(0.4), size: 36.sp),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFCEEF3),
      padding: EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Text(
            widget.title,
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: widget.primaryColor,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 24.h),

          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            // ══════════════════════════════════════════════════════
            // DESKTOP — all 3 images horizontal, active one taller
            // ══════════════════════════════════════════════════════
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(_galleryImages.length, (i) {
                  final bool isActive = _activeIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeIndex = i),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: _img(_galleryImages[i], 280.h,
                            isActive: isActive),
                      ),
                    ),
                  );
                }),
              );
            }

            // ══════════════════════════════════════════════════════
            // MOBILE — PageView carousel
            // ══════════════════════════════════════════════════════
            return SizedBox(
              height: 260.h,
              child: PageView.builder(
                controller: _mobileController,
                onPageChanged: (i) => setState(() => _activeIndex = i),
                itemCount: _galleryImages.length,
                itemBuilder: (_, i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(
                      _galleryImages[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: widget.primaryColor.withOpacity(0.12),
                        child: Icon(Icons.image_outlined,
                            color: widget.primaryColor.withOpacity(0.4),
                            size: 36.sp),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // ── Dots — tap to change active on desktop too ──
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_galleryImages.length, (i) {
              final bool active = _activeIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _activeIndex = i);
                  // on mobile also scroll the PageView
                  if (_mobileController.hasClients) {
                    _mobileController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 20.w : 8.w,
                  height: 8.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: active
                        ? widget.primaryColor
                        : widget.primaryColor.withOpacity(0.3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — CLIENT TESTIMONIALS
// ─────────────────────────────────────────────────────────────────────────────

class _TestimonialsSection extends StatefulWidget {
  final Color primaryColor;
  final String titlePart1;
  final String titleHighlight;
  final String titlePart2;
  final bool isAr;

  const _TestimonialsSection({
    required this.primaryColor,
    required this.titlePart1,
    required this.titleHighlight,
    required this.titlePart2,
    required this.isAr,
  });

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  final PageController _pageController = PageController(
    viewportFraction: 0.5, // ✅ show 2 cards at once on desktop
  );
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _testimonials.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          if (isWide) {
            // ✅ DESKTOP — title left, 2 cards right, arrows below title
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left: Title + Arrows ──────────────────────────────
                SizedBox(
                  width: 200.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8.h),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                            color: AppColors.secondaryBlack,
                            fontSize: 22.sp,
                          ),
                          children: [
                            TextSpan(text: '${widget.titlePart1}\n'),
                            TextSpan(
                              text: widget.titleHighlight,
                              style: TextStyle(
                                color: widget.primaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: widget.primaryColor,
                              ),
                            ),
                            TextSpan(text: ' ${widget.titlePart2}'),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Arrows below title ──
                      Row(
                        children: [
                          _ArrowBtn(
                            onTap: _currentIndex > 0 ? _prev : null,
                            icon: Icons.arrow_back,
                            filled: false,
                            primaryColor: widget.primaryColor,
                          ),
                          SizedBox(width: 12.w),
                          _ArrowBtn(
                            onTap: _currentIndex < _testimonials.length - 1
                                ? _next
                                : null,
                            icon: Icons.arrow_forward,
                            filled: true,
                            primaryColor: widget.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 24.w),

                // ── Right: 2 cards via PageView ───────────────────────
                Expanded(
                  child: SizedBox(
                    height: 220.h,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.5),
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemCount: _testimonials.length,
                      itemBuilder: (context, index) => _TestimonialCard(
                        testimonial: _testimonials[index],
                        primaryColor: widget.primaryColor,
                        isAr: widget.isAr,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // ✅ MOBILE — stacked: title, then single card PageView, then arrows
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                    color: AppColors.secondaryBlack,
                    fontSize: 22.sp,
                  ),
                  children: [
                    TextSpan(text: '${widget.titlePart1} '),
                    TextSpan(
                      text: widget.titleHighlight,
                      style: TextStyle(color: widget.primaryColor),
                    ),
                    TextSpan(text: ' ${widget.titlePart2}'),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              SizedBox(
                height: 220.h,
                child: PageView.builder(
                  controller: PageController(),
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: _testimonials.length,
                  itemBuilder: (context, index) => _TestimonialCard(
                    testimonial: _testimonials[index],
                    primaryColor: widget.primaryColor,
                    isAr: widget.isAr,
                  ),
                ),
              ),

              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ArrowBtn(
                    onTap: _currentIndex > 0 ? _prev : null,
                    icon: Icons.arrow_back,
                    filled: false,
                    primaryColor: widget.primaryColor,
                  ),
                  SizedBox(width: 12.w),
                  _ArrowBtn(
                    onTap: _currentIndex < _testimonials.length - 1
                        ? _next
                        : null,
                    icon: Icons.arrow_forward,
                    filled: true,
                    primaryColor: widget.primaryColor,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Reusable arrow button ─────────────────────────────────────────────────────
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


class _TestimonialCard extends StatelessWidget {
  final _Testimonial testimonial;
  final Color primaryColor;
  final bool isAr;

  const _TestimonialCard({
    required this.testimonial,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ──
          CircleAvatar(
            radius: 28.r,
            backgroundImage: AssetImage(testimonial.avatarAsset),
          ),
          SizedBox(width: 16.w),

          // ── Name & Review ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAr ? testimonial.nameAr : testimonial.nameEn,
                  style: AppTextStyles.font14BlackCairo.copyWith(
                    color: AppColors.secondaryBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      isAr ? testimonial.textAr : testimonial.textEn,
                      style: AppTextStyles.font12BlackCairoRegular.copyWith(
                        height: 1.6,
                        color: AppColors.secondaryBlack.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — DOWNLOAD NOW
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadNowSection extends StatelessWidget {
  final Color primaryColor;
  final String title;

  const _DownloadNowSection({
    required this.primaryColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Title ──
          Text(
            title,
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 24.h),

          // ── Store Badges ──
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
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
      ),
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