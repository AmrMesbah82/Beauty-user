// ******************* FILE INFO *******************
// File Name: overview_page.dart
// Description: Overview Page for the Beauty App (Bayanatz).
//              Sections: Overview, Top Services, Gallery, Client Testimonials, Download.
//              ALL content is CMS-driven via OverviewCmsCubit / OverviewPageModel.
// Created by: Claude for Amr Mesbah
// Updated: 12/04/2026
// UPDATED: Applied identical XHR-cache loader + _SvgPulseLoader + _RevealCoordinator
//          + _Reveal animation system from about_page.dart — UI/sections unchanged.
// FIXED:   1) Removed Expanded from _TestimonialCard feedback text (mobile crash)
//          2) Services section: always horizontal scroll row, no Wrap
//          3) Gallery: half-size images on mobile (< 600px)

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:beauty_user/core/widget/format.dart';
import 'package:beauty_user/core/widget/navigator.dart';
import 'package:beauty_user/page/our_products_page.dart' hide FormatHelper;
import 'package:beauty_user/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui_web' as ui_web;
import 'dart:convert';
import '../controller/gender/gender_cubit.dart';
import '../controller/gender/gender_state.dart';
import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../controller/overview/overview_cubit.dart';
import '../controller/overview/overview_state.dart';
import '../model/overview/overview_model.dart';
import '../theme/appcolors.dart';
import '../widgets/app_page_shell.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Helper — parse hex color from branding
// ══════════════════════════════════════════════════════════════════════════════

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ══════════════════════════════════════════════════════════════════════════════
// XHR Image Cache
// ══════════════════════════════════════════════════════════════════════════════

final Map<String, Future<Uint8List>> _globalUrlCache = {};

Future<Uint8List> _xhrLoad(String url, {bool isSvg = false}) {
  return _globalUrlCache.putIfAbsent(url, () async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
        mimeType: isSvg ? 'image/svg+xml' : null,
      );
      if (response.status == 200 && response.response != null) {
        return (response.response as ByteBuffer).asUint8List();
      }
      throw Exception('HTTP ${response.status}');
    } catch (e) {
      throw Exception('XHR failed: $e');
    }
  });
}

bool _isSvgBytes(Uint8List b) {
  if (b.length < 5) return false;
  final header =
  String.fromCharCodes(b.sublist(0, b.length.clamp(0, 100))).trimLeft();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

bool _isSvgUrl(String url) {
  final decoded = Uri.decodeFull(url).toLowerCase();
  return decoded.contains('.svg') ||
      decoded.contains('/svg?') ||
      decoded.contains('/svg/') ||
      decoded.endsWith('/svg');
}

Widget _netImg({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  ColorFilter? colorFilter,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (url.isEmpty) return errorWidget ?? const SizedBox.shrink();

  final viewId = 'svg-overview-user-${url.hashCode}-${width?.toInt()}-${height?.toInt()}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.contain
          ? 'contain'
          : fit == BoxFit.scaleDown
          ? 'scale-down'
          : 'cover';
    return img;
  });

  Widget inner = HtmlElementView(viewType: viewId);

  if (width != null || height != null) {
    inner = SizedBox(width: width, height: height, child: inner);
  }

  if (borderRadius != null) {
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  }

  return inner;
}

// ══════════════════════════════════════════════════════════════════════════════
// Preload helpers
// ══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadImages(List<String> urls) async {
  final valid = urls
      .where((u) =>
  u.isNotEmpty &&
      (u.startsWith('http://') || u.startsWith('https://')))
      .toSet();
  await Future.wait(
    valid.map((url) =>
        _xhrLoad(url, isSvg: _isSvgUrl(url)).catchError((_) => Uint8List(0))),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system
// ══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class _RevealCoordinator extends InheritedWidget {
  final _RevealCoordinatorState state;
  const _RevealCoordinator({required this.state, required super.child});
  static _RevealCoordinatorState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RevealCoordinator>()?.state;
  @override
  bool updateShouldNotify(_RevealCoordinator old) => false;
}

class _RevealCoordinatorWidget extends StatefulWidget {
  final Widget child;
  const _RevealCoordinatorWidget({required this.child});
  @override
  State<_RevealCoordinatorWidget> createState() => _RevealCoordinatorState();
}

class _RevealCoordinatorState extends State<_RevealCoordinatorWidget> {
  final List<_RevealState> _items = [];

  void register(_RevealState item) {
    _items.add(item);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) item.onScroll();
      });
    });
  }

  void unregister(_RevealState item) => _items.remove(item);

  void notifyScroll() {
    for (final item in List.of(_items)) item.onScroll();
  }

  @override
  Widget build(BuildContext context) => _RevealCoordinator(
    state: this,
    child: NotificationListener<ScrollNotification>(
      onNotification: (_) {
        notifyScroll();
        return false;
      },
      child: widget.child,
    ),
  );
}

class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay, duration;
  final _SlideDirection direction;
  const _Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.direction = _SlideDirection.fromBottom,
  });
  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop => const Offset(0, -0.18),
      _SlideDirection.fromLeft => const Offset(-0.18, 0),
      _SlideDirection.fromRight => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: begin, end: Offset.zero));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted && !_triggered) {
          _triggered = true;
          _ctrl.forward();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _RevealCoordinator.of(context)?.register(this);
  }

  @override
  void dispose() {
    _RevealCoordinator.of(context)?.unregister(this);
    _ctrl.dispose();
    super.dispose();
  }

  void onScroll() => _checkAndTrigger();

  void _checkAndTrigger() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH - 40) {
      _triggered = true;
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SVG Pulse Loader
// ══════════════════════════════════════════════════════════════════════════════

class _SvgPulseLoader extends StatefulWidget {
  final String? logoUrl;
  final Color backgroundColor;
  const _SvgPulseLoader({this.logoUrl, required this.backgroundColor});
  @override
  State<_SvgPulseLoader> createState() => _SvgPulseLoaderState();
}

class _SvgPulseLoaderState extends State<_SvgPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = (widget.logoUrl?.isNotEmpty == true) ? widget.logoUrl : null;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_SvgPulseLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null)
      setState(() => _resolvedUrl = widget.logoUrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    }

    final viewId = 'svg-pulse-loader-${_resolvedUrl.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = _resolvedUrl!
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';
      return img;
    });

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SizedBox(
            width: 88.w,
            height: 88.w,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OVERVIEW PAGE ROOT
// ══════════════════════════════════════════════════════════════════════════════

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) => const _OverviewPageView();
}

class _OverviewPageView extends StatefulWidget {
  const _OverviewPageView();
  @override
  State<_OverviewPageView> createState() => _OverviewPageViewState();
}

class _OverviewPageViewState extends State<_OverviewPageView> {
  bool _showLoader = true;
  bool _preloadStarted = false;
  final ScrollController _scrollController = ScrollController();
  String _lastGender = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) {
        setState(() => _showLoader = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onGenderChanged(String newGender) {
    if (newGender == _lastGender) return;
    _lastGender = newGender;
    _preloadStarted = false;
    _showLoader = true;
    context.read<OverviewCmsCubit>().switchGender(newGender);
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required OverviewPageModel model,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      setState(() => _showLoader = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GenderCubit, GenderState>(
      listener: (context, genderState) {
        _onGenderChanged(genderState.gender);
      },
      child: BlocBuilder<HomeCmsCubit, HomeCmsState>(
        builder: (context, homeState) {
          final homeData = switch (homeState) {
            HomeCmsLoaded(:final data) => data,
            HomeCmsSaved(:final data) => data,
            HomeCmsSaving(:final data) => data,
            HomeCmsError(:final lastData) => lastData,
            _ => null,
          };

          final Color primaryColor = homeData != null
              ? _parseHex(homeData.branding.primaryColor,
              fallback: AppColors.primary)
              : AppColors.primary;

          final Color backgroundColor = homeData != null
              ? _parseHex(homeData.branding.backgroundColor,
              fallback: AppColors.background)
              : AppColors.background;

          final String logoUrl = homeData?.branding.logoUrl ?? '';

          if (homeData == null) {
            return _SvgPulseLoader(
              logoUrl: logoUrl.isEmpty ? null : logoUrl,
              backgroundColor: AppColors.background,
            );
          }

          return BlocBuilder<OverviewCmsCubit, OverviewCmsState>(
            builder: (context, overviewState) {
              if (overviewState is OverviewCmsInitial) {
                final gender = context.read<GenderCubit>().current;
                _lastGender = gender;
                context.read<OverviewCmsCubit>().load(gender: gender);
              }

              if (overviewState is OverviewCmsError) {
                return Scaffold(
                  backgroundColor: backgroundColor,
                  body: Center(
                    child: Text(
                      overviewState.message,
                      style: AppTextStyles.font14BlackCairoRegular
                          .copyWith(color: Colors.red),
                    ),
                  ),
                );
              }

              final OverviewPageModel? model = switch (overviewState) {
                OverviewCmsLoaded(:final data) => data,
                OverviewCmsSaved(:final data) => data,
                _ => null,
              };

              if (model == null) {
                return _SvgPulseLoader(
                  logoUrl: logoUrl.isEmpty ? null : logoUrl,
                  backgroundColor: backgroundColor,
                );
              }

              if (!_preloadStarted) {
                _preloadAndReveal(logoUrl: logoUrl, model: model);
              }

              if (_showLoader) {
                return _SvgPulseLoader(
                  logoUrl: logoUrl.isEmpty ? null : logoUrl,
                  backgroundColor: backgroundColor,
                );
              }

              return BlocBuilder<LanguageCubit, LanguageState>(
                builder: (context, langState) {
                  final bool isAr = langState.isArabic;

                  return Directionality(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    child: AppPageShell(
                      currentRoute: '/services',
                      body: _RevealCoordinatorWidget(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 40.h),

                              // ═══ SECTION 1 — OVERVIEW ═══
                              _Reveal(
                                delay: const Duration(milliseconds: 60),
                                direction: _SlideDirection.fromBottom,
                                duration: const Duration(milliseconds: 650),
                                child: _OverviewSection(
                                  primaryColor: primaryColor,
                                  title: isAr
                                      ? model.headings.title.ar
                                      : model.headings.title.en,
                                  body: isAr
                                      ? model.headings.description.ar
                                      : model.headings.description.en,
                                  onReadMore: () {},
                                ),
                              ),

                              SizedBox(height: 50.h),

                              // ═══ SECTION 2 — TOP SERVICES ═══
                              _Reveal(
                                delay: const Duration(milliseconds: 120),
                                direction: _SlideDirection.fromLeft,
                                duration: const Duration(milliseconds: 650),
                                child: _TopServicesSection(
                                  primaryColor: primaryColor,
                                  title: isAr
                                      ? model.services.title.ar
                                      : model.services.title.en,
                                  items: model.services.items,
                                  isAr: isAr,
                                ),
                              ),

                              SizedBox(height: 50.h),

                              // ═══ SECTION 3 — GALLERY ═══
                              _Reveal(
                                delay: const Duration(milliseconds: 180),
                                direction: _SlideDirection.fromRight,
                                duration: const Duration(milliseconds: 650),
                                child: _GallerySection(
                                  primaryColor: primaryColor,
                                  title: isAr ? 'المعرض' : 'Gallery',
                                  images: model.gallery.images,
                                ),
                              ),

                              SizedBox(height: 50.h),

                              // ═══ SECTION 4 — CLIENT TESTIMONIALS ═══
                              _Reveal(
                                delay: const Duration(milliseconds: 240),
                                direction: _SlideDirection.fromBottom,
                                duration: const Duration(milliseconds: 650),
                                child: _TestimonialsSection(
                                  primaryColor: primaryColor,
                                  sectionTitle: isAr
                                      ? model.clientComments.title.ar
                                      : model.clientComments.title.en,
                                  comments: model.clientComments.comments,
                                  isAr: isAr,
                                ),
                              ),

                              SizedBox(height: 50.h),

                              // ═══ SECTION 5 — DOWNLOAD NOW ═══
                              _Reveal(
                                delay: const Duration(milliseconds: 100),
                                direction: _SlideDirection.fromBottom,
                                duration: const Duration(milliseconds: 650),
                                child: _DownloadNowSection(
                                  primaryColor: primaryColor,
                                  title: isAr
                                      ? model.download.title.ar
                                      : model.download.title.en,
                                  appStoreLink: model.download.appStoreLink,
                                  googlePlayLink: model.download.googlePlayLink,
                                ),
                              ),

                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — OVERVIEW
// ══════════════════════════════════════════════════════════════════════════════

class _OverviewSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String body;
  final VoidCallback? onReadMore;

  const _OverviewSection({
    required this.primaryColor,
    required this.title,
    required this.body,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.watch<LanguageCubit>().state.isArabic;
    final readMoreLabel = isAr ? 'اقرأ المزيد' : 'Read More';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          FormatHelper.capitalize(body),
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            height: 1.7,
            color: AppColors.secondaryBlack,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: InkWell(
            onTap: () {
              navigateTo(context, OurProductsPage());
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FormatHelper.capitalize(readMoreLabel),
                    style: AppTextStyles.font14BlackCairoMedium
                        .copyWith(color: primaryColor),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.15),
                    ),
                    child: Icon(Icons.arrow_forward,
                        size: 14.sp, color: primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — TOP SERVICES
// ══════════════════════════════════════════════════════════════════════════════

class _TopServicesSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final List<OverviewServiceItemModel> items;
  final bool isAr;

  const _TopServicesSection({
    required this.primaryColor,
    required this.title,
    required this.items,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 24.h),
        // ✅ FIX: always a single horizontal scrollable row — no Wrap, no line breaks
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: items
                .map((item) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _ServiceCard(
                imageUrl: item.imageUrl,
                name: isAr ? item.name.ar : item.name.en,
                primaryColor: primaryColor,
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final Color primaryColor;

  const _ServiceCard({
    required this.imageUrl,
    required this.name,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
            Border.all(color: primaryColor.withOpacity(0.2), width: 2.w),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: ClipOval(
              child: _netImg(
                url: imageUrl,
                width: 48.w,
                height: 48.w,
                fit: BoxFit.scaleDown,
                placeholder: Icon(
                  Icons.spa_outlined,
                  color: primaryColor.withOpacity(0.4),
                  size: 28.sp,
                ),
                errorWidget: Icon(
                  Icons.spa_outlined,
                  color: primaryColor.withOpacity(0.4),
                  size: 28.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          FormatHelper.capitalize(name),
          style: AppTextStyles.font14BlackCairoMedium
              .copyWith(color: AppColors.secondaryBlack),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — GALLERY
// ══════════════════════════════════════════════════════════════════════════════

class _GallerySection extends StatefulWidget {
  final Color primaryColor;
  final String title;
  final List<OverviewGalleryImageModel> images;

  const _GallerySection({
    required this.primaryColor,
    required this.title,
    required this.images,
  });

  @override
  State<_GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<_GallerySection> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.images.length >= 3) _activeIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    // ✅ FIX: half-size on mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final double inactiveSize = isMobile ? 110.w : 200.w;
    final double activeSize = isMobile ? 160.w : 284.w;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(.8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FormatHelper.capitalize(widget.title),
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: widget.primaryColor,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 24.h),

          SizedBox(
            height: activeSize + 16.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  final bool isActive = _activeIndex == i;
                  final double size = isActive ? activeSize : inactiveSize;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeIndex = i),
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        width: size,
                        height: size,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: _netImg(
                            url: widget.images[i].imageUrl,
                            width: size,
                            height: size,
                            fit: BoxFit.scaleDown,
                            placeholder: Container(
                              color: widget.primaryColor.withOpacity(0.12),
                              child: Icon(
                                Icons.image_outlined,
                                color: widget.primaryColor.withOpacity(0.4),
                                size: 36.sp,
                              ),
                            ),
                            errorWidget: Container(
                              color: widget.primaryColor.withOpacity(0.08),
                              child: Icon(Icons.broken_image_outlined,
                                  color: widget.primaryColor.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final bool active = _activeIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _activeIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 24.w : 8.w,
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

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — CLIENT TESTIMONIALS
// ══════════════════════════════════════════════════════════════════════════════

class _TestimonialsSection extends StatefulWidget {
  final Color primaryColor;
  final String sectionTitle;
  final List<OverviewClientCommentModel> comments;
  final bool isAr;

  const _TestimonialsSection({
    required this.primaryColor,
    required this.sectionTitle,
    required this.comments,
    required this.isAr,
  });

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  int _currentPage = 0;

  int _cardsPerPage(bool isWide) => isWide ? 2 : 1;

  int _totalPages(bool isWide) {
    final perPage = _cardsPerPage(isWide);
    return (widget.comments.length / perPage).ceil();
  }

  void _next(bool isWide) {
    if (_currentPage < _totalPages(isWide) - 1) {
      setState(() => _currentPage++);
    }
  }

  void _prev(bool isWide) {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  Widget _buildTitle() {
    final title = widget.sectionTitle;
    final highlightWord = widget.isAr ? 'عملائنا' : 'Clients';

    final idx = title.toLowerCase().indexOf(highlightWord.toLowerCase());
    if (idx == -1) {
      return Text(
        FormatHelper.capitalize(title),
        style: AppTextStyles.font23BlackSemiBoldCairo.copyWith(
          color: AppColors.secondaryBlack,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      );
    }

    final before = title.substring(0, idx);
    final keyword = title.substring(idx, idx + highlightWord.length);
    final after = title.substring(idx + highlightWord.length);

    return Text.rich(
      TextSpan(
        style: AppTextStyles.font23BlackSemiBoldCairo.copyWith(
          color: AppColors.secondaryBlack,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: keyword,
            style: TextStyle(color: widget.primaryColor),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comments.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final perPage = _cardsPerPage(isWide);
        final totalPages = _totalPages(isWide);

        final startIdx = _currentPage * perPage;
        final endIdx = (startIdx + perPage).clamp(0, widget.comments.length);
        final visibleComments = widget.comments.sublist(startIdx, endIdx);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Title & Arrows
              SizedBox(
                width: 220.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16.h),
                    _buildTitle(),
                    SizedBox(height: 28.h),
                    SizedBox(
                      height: 60.h,
                      child: Row(
                        children: [
                          _ArrowBtn(
                            onTap:
                            _currentPage > 0 ? () => _prev(true) : null,
                            icon: Icons.arrow_back,
                            filled: false,
                            primaryColor: widget.primaryColor,
                          ),
                          SizedBox(width: 12.w),
                          _ArrowBtn(
                            onTap: _currentPage < totalPages - 1
                                ? () => _next(true)
                                : null,
                            icon: Icons.arrow_forward,
                            filled: true,
                            primaryColor: widget.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              // Right side - Cards with equal height
              Expanded(
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: visibleComments
                        .map((comment) => Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 8.w),
                        child: _TestimonialCard(
                          comment: comment,
                          primaryColor: widget.primaryColor,
                          isAr: widget.isAr,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
            ],
          );
        }

        // Mobile layout
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            SizedBox(height: 20.h),
            ...visibleComments.map((comment) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _TestimonialCard(
                comment: comment,
                primaryColor: widget.primaryColor,
                isAr: widget.isAr,
              ),
            )),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ArrowBtn(
                  onTap: _currentPage > 0 ? () => _prev(false) : null,
                  icon: Icons.arrow_back,
                  filled: false,
                  primaryColor: widget.primaryColor,
                ),
                SizedBox(width: 12.w),
                _ArrowBtn(
                  onTap: _currentPage < totalPages - 1
                      ? () => _next(false)
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
    );
  }
}

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
  final OverviewClientCommentModel comment;
  final Color primaryColor;
  final bool isAr;

  const _TestimonialCard({
    required this.comment,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final String fullName = isAr
        ? '${comment.firstName.ar} ${comment.lastName.ar}'.trim()
        : '${comment.firstName.en} ${comment.lastName.en}'.trim();

    final String feedbackText =
    isAr ? comment.feedback.ar : comment.feedback.en;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                child: _netImg(
                  url: comment.imageUrl,
                  width: 48.r,
                  height: 48.r,
                  fit: BoxFit.scaleDown,
                  placeholder: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Icon(Icons.person_outline,
                        color: primaryColor, size: 22.sp),
                  ),
                  errorWidget: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    child: Icon(Icons.person_outline,
                        color: primaryColor, size: 22.sp),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  fullName,
                  style: AppTextStyles.font14BlackCairoMedium.copyWith(
                    color: AppColors.secondaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // ✅ FIX: plain Text, no Expanded — prevents mobile layout crash
          Text(
            feedbackText,
            style: AppTextStyles.font12BlackCairoRegular.copyWith(
              height: 1.6,
              color: AppColors.secondaryBlack.withOpacity(0.75),
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — DOWNLOAD NOW
// ══════════════════════════════════════════════════════════════════════════════

class _DownloadNowSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadNowSection({
    required this.primaryColor,
    required this.title,
    required this.appStoreLink,
    required this.googlePlayLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  FormatHelper.capitalize(title),
                  style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                    color: primaryColor,
                    fontSize: 22.sp,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (googlePlayLink.isNotEmpty)
                      _StoreBadge(
                        onTap: () {},
                        svgAsset: 'assets/beauty/home/google_play.svg',
                      ),
                    if (googlePlayLink.isNotEmpty && appStoreLink.isNotEmpty)
                      SizedBox(width: 12.w),
                    if (appStoreLink.isNotEmpty)
                      _StoreBadge(
                        onTap: () {},
                        svgAsset: 'assets/beauty/home/app_store.svg',
                      ),
                  ],
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
                  color: primaryColor,
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: [
                  if (googlePlayLink.isNotEmpty)
                    _StoreBadge(
                      onTap: () {},
                      svgAsset: 'assets/beauty/home/google_play.svg',
                    ),
                  if (appStoreLink.isNotEmpty)
                    _StoreBadge(
                      onTap: () {},
                      svgAsset: 'assets/beauty/home/app_store.svg',
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

// ══════════════════════════════════════════════════════════════════════════════
// STORE BADGE BUTTON
// ══════════════════════════════════════════════════════════════════════════════

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