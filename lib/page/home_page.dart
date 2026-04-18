/// ******************* FILE INFO *******************
/// File Name: home_page.dart
/// Description: Public-facing Home Page for the Beauty App (Bayanatz).
/// Last Update: 16/04/2026
/// DEBUG: Added extensive logging for download section visibility diagnosis

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:beauty_user/core/widget/format.dart';
import 'package:beauty_user/core/widget/navigator.dart';
import 'package:beauty_user/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/gender/gender_cubit.dart';
import '../controller/gender/gender_state.dart';
import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../controller/master/master_cubit.dart';
import '../controller/master/master_state.dart';
import '../model/master/master_model.dart';
import '../theme/appcolors.dart';
import '../widgets/app_page_shell.dart';
import 'about_page.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

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
  final bool hintSvg = _isSvgUrl(url);
  Widget inner = FutureBuilder<Uint8List>(
    future: _xhrLoad(url, isSvg: hintSvg),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return placeholder ?? SizedBox(width: width, height: height);
      }
      if (snapshot.hasData) {
        final bytes = snapshot.data!;
        if (hintSvg || _isSvgBytes(bytes)) {
          return SvgPicture.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            colorFilter: colorFilter,
          );
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      }
      return errorWidget ??
          Icon(Icons.broken_image,
              color: Colors.grey[400],
              size: (width ?? height ?? 24).toDouble());
    },
  );
  if (borderRadius != null)
    inner = ClipRRect(borderRadius: borderRadius, child: inner);
  if (width != null || height != null)
    inner = SizedBox(width: width, height: height, child: inner);
  return inner;
}

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
      Future.delayed(widget.delay, () => _checkAndTrigger());
      Future.delayed(
          widget.delay + const Duration(milliseconds: 120),
              () => _checkAndTrigger());
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
    if (_resolvedUrl == null)
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: _netImg(
            url: _resolvedUrl!,
            width: 88.w,
            height: 88.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOME PAGE ROOT
// ══════════════════════════════════════════════════════════════════════════════

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const _HomePageView();
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();
  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> with RouteAware {
  bool _showLoader = true;
  bool _preloadStarted = false;
  String _lastGender = '';

  String _lastLogoUrl = '';
  String _lastHeaderImageUrl = '';
  String _lastAboutImageUrl = '';
  String _lastDownloadImageUrl = '';

  @override
  void initState() {
    super.initState();
    print('🏠🏠🏠 [HomePage] initState called');
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) {
        print('🏠 [HomePage] 12s timeout — forcing loader off');
        setState(() => _showLoader = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshContent();
  }

  void _onGenderChanged(String newGender) {
    if (newGender == _lastGender) return;
    _lastGender = newGender;
    _preloadStarted = false;
    setState(() => _showLoader = true);
    context.read<MasterCmsCubit>().switchGender(newGender);
  }

  void _refreshContent() {
    if (!_preloadStarted && !_showLoader && _lastLogoUrl.isNotEmpty) {
      print('🔄 Refreshing home page content...');
      setState(() {
        _showLoader = true;
        _preloadStarted = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _preloadAndReveal(
            logoUrl: _lastLogoUrl,
            headerImageUrl: _lastHeaderImageUrl,
            aboutImageUrl: _lastAboutImageUrl,
            downloadImageUrl: _lastDownloadImageUrl,
          );
        }
      });
    }
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required String headerImageUrl,
    required String aboutImageUrl,
    required String downloadImageUrl,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;
    print('🏠 [HomePage] _preloadAndReveal started');

    _lastLogoUrl = logoUrl;
    _lastHeaderImageUrl = headerImageUrl;
    _lastAboutImageUrl = aboutImageUrl;
    _lastDownloadImageUrl = downloadImageUrl;

    final urls = [
      if (logoUrl.isNotEmpty) logoUrl,
      if (headerImageUrl.isNotEmpty) headerImageUrl,
      if (aboutImageUrl.isNotEmpty) aboutImageUrl,
      if (downloadImageUrl.isNotEmpty) downloadImageUrl,
    ];

    print('🏠 [HomePage] preloading ${urls.length} URLs');
    await _preloadImages(urls);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      print('🏠 [HomePage] preload done — hiding loader');
      setState(() => _showLoader = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 [HomePage] BUILD — _showLoader=$_showLoader _preloadStarted=$_preloadStarted');

    return BlocListener<GenderCubit, GenderState>(
      listener: (context, genderState) {
        _onGenderChanged(genderState.gender);
      },
      child: BlocBuilder<HomeCmsCubit, HomeCmsState>(
        builder: (context, homeState) {
          print('🏠 [HomePage] HomeCmsState = ${homeState.runtimeType}');

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
            print('🏠 [HomePage] homeData is NULL — showing pulse loader');
            return _SvgPulseLoader(
              logoUrl: logoUrl.isEmpty ? null : logoUrl,
              backgroundColor: backgroundColor,
            );
          }

          // ✅ Extract download links from homeData
          final String appStoreLink = homeData.appDownloadLinks.iosUrl;
          final String googlePlayLink = homeData.appDownloadLinks.androidUrl;
          final bool showDownload = homeData.appDownloadLinks.visibility;

          print('🏠 [HomePage] homeData loaded:');
          print('   appStoreLink   = "$appStoreLink"');
          print('   googlePlayLink = "$googlePlayLink"');
          print('   showDownload   = $showDownload');

          return BlocBuilder<MasterCmsCubit, MasterCmsState>(
            builder: (context, masterState) {
              print('🏠 [HomePage] MasterCmsState = ${masterState.runtimeType}');

              if (masterState is MasterCmsInitial) {
                final gender = context.read<GenderCubit>().current;
                _lastGender = gender;
                print('🏠 [HomePage] MasterCmsInitial — loading gender=$gender');
                context.read<MasterCmsCubit>().load(gender: gender);
              }

              MasterPageModel? masterData;
              if (masterState is MasterCmsLoaded) {
                masterData = masterState.data;
              } else if (masterState is MasterCmsSaved) {
                masterData = masterState.data;
              }

              final bool masterReady =
                  masterState is MasterCmsLoaded || masterState is MasterCmsError;

              if (!masterReady && masterData == null) {
                print('🏠 [HomePage] master NOT ready — showing pulse loader');
                return _SvgPulseLoader(
                  logoUrl: logoUrl.isEmpty ? null : logoUrl,
                  backgroundColor: backgroundColor,
                );
              }

              final headerSection = masterData?.sectionByKey('header');
              final aboutSection = masterData?.sectionByKey('aboutUs');
              final downloadSection = masterData?.sectionByKey('footer');

              final String headerImageUrl = headerSection?.imageUrl ?? '';
              final String aboutImageUrl = aboutSection?.imageUrl ?? '';
              final String downloadImageUrl = downloadSection?.imageUrl ?? '';

              final bool hasDownloadContent = showDownload &&
                  (downloadImageUrl.isNotEmpty ||
                      appStoreLink.isNotEmpty ||
                      googlePlayLink.isNotEmpty);

              print('🏠🔍 [HomePage] DOWNLOAD SECTION DEBUG:');
              print('   masterData null?        = ${masterData == null}');
              print('   masterState type        = ${masterState.runtimeType}');
              print('   headerSection null?     = ${headerSection == null}');
              print('   aboutSection null?      = ${aboutSection == null}');
              print('   downloadSection null?   = ${downloadSection == null}');
              print('   headerImageUrl          = "$headerImageUrl"');
              print('   aboutImageUrl           = "$aboutImageUrl"');
              print('   downloadImageUrl        = "$downloadImageUrl"');
              print('   headerVisibility        = ${headerSection?.visibility}');
              print('   aboutVisibility         = ${aboutSection?.visibility}');
              print('   downloadVisibility      = ${downloadSection?.visibility}');
              print('   appStoreLink            = "$appStoreLink"');
              print('   googlePlayLink          = "$googlePlayLink"');
              print('   showDownload            = $showDownload');
              print('   >>> hasDownloadContent  = $hasDownloadContent');
              print('   _showLoader             = $_showLoader');
              print('   _preloadStarted         = $_preloadStarted');

              if (!_preloadStarted) {
                print('🏠 [HomePage] starting preload...');
                _preloadAndReveal(
                  logoUrl: logoUrl,
                  headerImageUrl: headerImageUrl,
                  aboutImageUrl: aboutImageUrl,
                  downloadImageUrl: downloadImageUrl,
                );
              }

              if (_showLoader) {
                print('🏠 [HomePage] _showLoader=true — showing pulse loader');
                return _SvgPulseLoader(
                  logoUrl: logoUrl.isEmpty ? null : logoUrl,
                  backgroundColor: backgroundColor,
                );
              }

              print('🏠✅ [HomePage] RENDERING FULL PAGE — hasDownloadContent=$hasDownloadContent');

              return BlocBuilder<LanguageCubit, LanguageState>(
                builder: (context, langState) {
                  final bool isAr = langState.isArabic;

                  final heroTitle = isAr
                      ? (masterData?.title.ar.isNotEmpty == true
                      ? masterData!.title.ar
                      : homeData.title.ar)
                      : (masterData?.title.en.isNotEmpty == true
                      ? masterData!.title.en
                      : homeData.title.en);

                  final heroSubtitle = isAr
                      ? (masterData?.shortDescription.ar.isNotEmpty == true
                      ? masterData!.shortDescription.ar
                      : homeData.shortDescription.ar)
                      : (masterData?.shortDescription.en.isNotEmpty == true
                      ? masterData!.shortDescription.en
                      : homeData.shortDescription.en);

                  final aboutHeading = isAr
                      ? (aboutSection?.title.ar.isNotEmpty == true
                      ? aboutSection!.title.ar
                      : 'من نحن')
                      : (aboutSection?.title.en.isNotEmpty == true
                      ? aboutSection!.title.en
                      : 'About Us');

                  final aboutBody = isAr
                      ? (aboutSection?.description.ar ?? '')
                      : (aboutSection?.description.en ?? '');

                  final downloadHeading = isAr
                      ? (downloadSection?.title.ar.isNotEmpty == true
                      ? downloadSection!.title.ar
                      : 'حمّل التطبيق')
                      : (downloadSection?.title.en.isNotEmpty == true
                      ? downloadSection!.title.en
                      : 'Download App');

                  final downloadBody = isAr
                      ? (downloadSection?.description.ar.isNotEmpty == true
                      ? downloadSection!.description.ar
                      : 'حمّل تطبيقنا الآن واستمتع بتجربة فريدة')
                      : (downloadSection?.description.en.isNotEmpty == true
                      ? downloadSection!.description.en
                      : 'Download our app now and enjoy a unique experience');

                  print('🏠 [HomePage] Building sections:');
                  print('   heroTitle        = "$heroTitle"');
                  print('   aboutHeading     = "$aboutHeading"');
                  print('   downloadHeading  = "$downloadHeading"');
                  print('   show hero?       = ${headerSection?.visibility ?? true}');
                  print('   show about?      = ${aboutSection?.visibility ?? true}');
                  print('   show download?   = $hasDownloadContent');

                  return Directionality(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    child: AppPageShell(
                      currentRoute: '/',
                      body: _RevealCoordinatorWidget(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ═══ SECTION 1 — HERO ═══
                              if (headerSection?.visibility ?? true) ...[
                                _Reveal(
                                  delay: const Duration(milliseconds: 60),
                                  direction: _SlideDirection.fromBottom,
                                  duration: const Duration(milliseconds: 650),
                                  child: _HeroSection(
                                    primaryColor: primaryColor,
                                    title: heroTitle,
                                    subtitle: heroSubtitle,
                                    imageUrl: headerImageUrl,
                                  ),
                                ),
                                SizedBox(height: 40.h),
                              ],

                              // ═══ SECTION 2 — ABOUT US ═══
                              if (aboutSection?.visibility ?? true) ...[
                                _Reveal(
                                  delay: const Duration(milliseconds: 120),
                                  direction: _SlideDirection.fromLeft,
                                  duration: const Duration(milliseconds: 650),
                                  child: _AboutUsSection(
                                    primaryColor: primaryColor,
                                    heading: aboutHeading,
                                    body: aboutBody,
                                    readMoreLabel:
                                    isAr ? 'اقرأ المزيد' : 'Read More',
                                    imageUrl: aboutImageUrl,
                                    onReadMore: () {
                                      navigateTo(context, AboutPage());
                                    },
                                  ),
                                ),
                                SizedBox(height: 40.h),
                              ],

                              // ═══ SECTION 3 — DOWNLOAD APP ═══
                              if (hasDownloadContent) ...[
                                Builder(builder: (context) {
                                  print('🏠🟢 [HomePage] DOWNLOAD SECTION IS RENDERING!');
                                  return _Reveal(
                                    delay: const Duration(milliseconds: 180),
                                    direction: _SlideDirection.fromRight,
                                    duration: const Duration(milliseconds: 650),
                                    child: _DownloadAppSection(
                                      primaryColor: primaryColor,
                                      heading: downloadHeading,
                                      body: downloadBody,
                                      imageUrl: downloadImageUrl,
                                      appStoreLink: appStoreLink,
                                      googlePlayLink: googlePlayLink,
                                    ),
                                  );
                                }),
                              ],
                              if (!hasDownloadContent)
                                Builder(builder: (context) {
                                  print('🏠🔴 [HomePage] DOWNLOAD SECTION HIDDEN — hasDownloadContent=false');
                                  return const SizedBox.shrink();
                                }),
                              SizedBox(height: 80.h),
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
// SECTION 1 — HERO
// ══════════════════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String subtitle;
  final String imageUrl;

  const _HeroSection({
    required this.primaryColor,
    required this.title,
    required this.subtitle,
    this.imageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide && hasImage) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildImage(320.h)),
                SizedBox(width: 30.w),
                Expanded(
                  flex: 5,
                  child: _Reveal(
                    delay: const Duration(milliseconds: 100),
                    direction: _SlideDirection.fromRight,
                    child: _HeroText(
                      title: FormatHelper.capitalize(title),
                      subtitle: subtitle,
                      primaryColor: primaryColor,
                    ),
                  ),
                ),
              ],
            );
          }

          if (isWide && !hasImage) {
            return _HeroText(
              title: FormatHelper.capitalize(title),
              subtitle: subtitle,
              primaryColor: primaryColor,
            );
          }

          return Column(
            children: [
              if (hasImage) ...[
                _buildImage(200.h),
                SizedBox(height: 24.h),
              ],
              _HeroText(
                title: FormatHelper.capitalize(title),
                subtitle: subtitle,
                primaryColor: primaryColor,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(double height) {
    if (imageUrl.isEmpty) return const SizedBox.shrink();
    return _netImg(
      url: imageUrl,
      height: height,
      fit: BoxFit.contain,
      errorWidget: const SizedBox.shrink(),
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

class _AboutUsSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String readMoreLabel;
  final String imageUrl;
  final VoidCallback? onReadMore;

  const _AboutUsSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    required this.readMoreLabel,
    this.imageUrl = '',
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FormatHelper.capitalize(heading),
            style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (imageUrl.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _netImg(
                url: imageUrl,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          if (body.isNotEmpty)
            Text(
              FormatHelper.capitalize(body),
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
              ),
            ),
          SizedBox(height: 16.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InkWell(
              onTap: onReadMore ?? () {
                navigateTo(context, AboutPage());
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FormatHelper.capitalize(readMoreLabel),
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
                      child: Icon(Icons.arrow_forward,
                          size: 14.sp, color: primaryColor),
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

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — DOWNLOAD APP
// ══════════════════════════════════════════════════════════════════════════════

class _DownloadAppSection extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String imageUrl;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadAppSection({
    required this.primaryColor,
    required this.heading,
    required this.body,
    this.imageUrl = '',
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl.isNotEmpty;
    print('🏠 [_DownloadAppSection] build: hasImage=$hasImage heading="$heading" appStore="$appStoreLink" googlePlay="$googlePlayLink"');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide && hasImage) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 4, child: _buildImage(320.h)),
                SizedBox(width: 30.w),
                Expanded(
                  flex: 6,
                  child: _DownloadTextContent(
                    primaryColor: primaryColor,
                    heading: heading,
                    body: body,
                    appStoreLink: appStoreLink,
                    googlePlayLink: googlePlayLink,
                  ),
                ),
              ],
            );
          }

          if (isWide && !hasImage) {
            return _DownloadTextContent(
              primaryColor: primaryColor,
              heading: heading,
              body: body,
              appStoreLink: appStoreLink,
              googlePlayLink: googlePlayLink,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage) ...[
                Center(child: _buildImage(200.h)),
                SizedBox(height: 24.h),
              ],
              _DownloadTextContent(
                primaryColor: primaryColor,
                heading: heading,
                body: body,
                appStoreLink: appStoreLink,
                googlePlayLink: googlePlayLink,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(double height) {
    if (imageUrl.isEmpty) return const SizedBox.shrink();
    return _netImg(
      url: imageUrl,
      height: height,
      fit: BoxFit.contain,
      errorWidget: const SizedBox.shrink(),
    );
  }
}

class _DownloadTextContent extends StatelessWidget {
  final Color primaryColor;
  final String heading;
  final String body;
  final String appStoreLink;
  final String googlePlayLink;

  const _DownloadTextContent({
    required this.primaryColor,
    required this.heading,
    required this.body,
    this.appStoreLink = '',
    this.googlePlayLink = '',
  });

  void _launchUrl(String url) {
    if (url.isEmpty) return;
    print('🟡 [DownloadSection] Would launch: $url');
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 [_DownloadTextContent] build: heading="$heading" googlePlay="$googlePlayLink" appStore="$appStoreLink"');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FormatHelper.capitalize(heading),
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        if (body.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              FormatHelper.capitalize(body),
              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                height: 1.7,
                color: AppColors.secondaryBlack,
              ),
            ),
          ),
        if (googlePlayLink.isNotEmpty || appStoreLink.isNotEmpty)
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              if (googlePlayLink.isNotEmpty)
                _StoreBadge(
                  onTap: () => _launchUrl(googlePlayLink),
                  svgAsset: 'assets/beauty/home/google_play.svg',
                ),
              if (appStoreLink.isNotEmpty)
                _StoreBadge(
                  onTap: () => _launchUrl(appStoreLink),
                  svgAsset: 'assets/beauty/home/app_store.svg',
                ),
            ],
          ),
      ],
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
          width: 135.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}