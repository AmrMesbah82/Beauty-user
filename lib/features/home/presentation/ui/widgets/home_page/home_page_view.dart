part of '../../pages/home_page.dart';

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
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showLoader) {
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

    _lastLogoUrl = logoUrl;
    _lastHeaderImageUrl = headerImageUrl;
    _lastAboutImageUrl = aboutImageUrl;
    _lastDownloadImageUrl = downloadImageUrl;

    final urls = [
      if (logoUrl.isNotEmpty && !_isSvgUrl(logoUrl)) logoUrl,
      if (headerImageUrl.isNotEmpty && !_isSvgUrl(headerImageUrl)) headerImageUrl,
      if (aboutImageUrl.isNotEmpty && !_isSvgUrl(aboutImageUrl)) aboutImageUrl,
      if (downloadImageUrl.isNotEmpty && !_isSvgUrl(downloadImageUrl))
        downloadImageUrl,
    ];


    if (urls.isNotEmpty) {
      await _preloadImages(urls);
    } else {
    }

    await Future.delayed(const Duration(milliseconds: 50));

    if (mounted) {
      setState(() => _showLoader = false);
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
            HomeCmsLoaded(:final data)    => data,
            HomeCmsSaved(:final data)     => data,
            HomeCmsSaving(:final data)    => data,
            HomeCmsError(:final lastData) => lastData,
            _ => null,
          };

          final Color backgroundColor = homeData != null
              ? _parseHex(homeData.branding.backgroundColor,
              fallback: AppColors.background)
              : AppColors.background;

          final String logoUrl = homeData?.branding.logoUrl ?? '';

          if (homeData == null) {
            return _SvgPulseLoader(
              logoUrl: logoUrl.isEmpty ? null : logoUrl,
              backgroundColor: backgroundColor,
            );
          }

          final String appStoreLink   = homeData.appDownloadLinks.iosUrl;
          final String googlePlayLink = homeData.appDownloadLinks.androidUrl;
          final bool showDownload     = homeData.appDownloadLinks.visibility;

          return BlocBuilder<MasterCmsCubit, MasterCmsState>(
            builder: (context, masterState) {

              if (masterState is MasterCmsInitial) {
                final gender = context.read<GenderCubit>().current;
                _lastGender = gender;
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
                return _SvgPulseLoader(
                  logoUrl: logoUrl.isEmpty ? null : logoUrl,
                  backgroundColor: backgroundColor,
                );
              }

              final headerSection   = masterData?.sectionByKey('header');
              final aboutSection    = masterData?.sectionByKey('aboutUs');
              final downloadSection = masterData?.sectionByKey('footer');

              final String headerImageUrl   = headerSection?.imageUrl ?? '';
              final String aboutImageUrl    = aboutSection?.imageUrl ?? '';
              final String downloadImageUrl = downloadSection?.imageUrl ?? '';

              final bool hasDownloadContent = showDownload &&
                  (downloadImageUrl.isNotEmpty ||
                      appStoreLink.isNotEmpty ||
                      googlePlayLink.isNotEmpty);

              if (!_preloadStarted) {
                _preloadAndReveal(
                  logoUrl: logoUrl,
                  headerImageUrl: headerImageUrl,
                  aboutImageUrl: aboutImageUrl,
                  downloadImageUrl: downloadImageUrl,
                );
              }

              if (_showLoader) {
                return _SvgPulseLoader(
                  logoUrl: logoUrl.isEmpty ? null : logoUrl,
                  backgroundColor: backgroundColor,
                );
              }


              // ── Gender-aware color rebuild ──────────────────────────────────
              return BlocBuilder<GenderCubit, GenderState>(
                builder: (context, genderState) {
                  final bool isMale = genderState.isMale;

                  // ✅ Pick primary color based on current gender
                  final Color primaryColor = _resolvePrimaryColor(
                    primaryColorHex: homeData.branding.primaryColor,
                    malePrimaryColorHex: homeData.branding.malePrimaryColor,
                    isMale: isMale,
                  );

                  return BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, langState) {
                      final bool isAr = langState.isArabic;

                      final heroTitle = isAr
                          ? (headerSection?.title.ar.isNotEmpty == true
                          ? headerSection!.title.ar
                          : homeData.title.ar)
                          : (headerSection?.title.en.isNotEmpty == true
                          ? headerSection!.title.en
                          : homeData.title.en);

                      final heroSubtitle = isAr
                          ? (headerSection?.shortDescription.ar.isNotEmpty == true
                          ? headerSection!.shortDescription.ar
                          : homeData.shortDescription.ar)
                          : (headerSection?.shortDescription.en.isNotEmpty == true
                          ? headerSection!.shortDescription.en
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

                      return Directionality(
                        textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
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
                                      delay:
                                      const Duration(milliseconds: 60),
                                      direction: _SlideDirection.fromBottom,
                                      duration:
                                      const Duration(milliseconds: 650),
                                      child: _HeroSection(
                                        primaryColor: primaryColor,
                                        title: heroTitle,
                                        subtitle: heroSubtitle,
                                        imageUrl: headerImageUrl,
                                      ),
                                    ),
                                    SizedBox(height: 40.h),
                                  ],

                                  // Inside the _HomePageViewState build method, where _AboutUsSection is used:

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
                                        readMoreLabel: isAr ? 'اقرأ المزيد' : 'Read More',
                                        imageUrl: aboutImageUrl,
                                        onReadMore: () {
                                          navigateTo(context, AboutPage());
                                        },
                                        backgroundColor: _parseHex(           // ← NEW: Pass mainWidgetColor
                                          homeData.branding.mainWidgetColor,
                                          fallback: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 40.h),
                                  ],

                                  // ═══ SECTION 3 — DOWNLOAD APP ═══
                                  // ═══ SECTION 3 — DOWNLOAD APP ═══
                                  if (hasDownloadContent) ...[
                                    _DownloadAppSection(
                                      primaryColor: primaryColor,
                                      heading: downloadHeading,
                                      body: downloadBody,
                                      imageUrl: downloadImageUrl,
                                      appStoreLink: appStoreLink,
                                      googlePlayLink: googlePlayLink,
                                      backgroundColor: _parseHex(           // ← NEW: Pass mainWidgetColor
                                        homeData.branding.mainWidgetColor,
                                        fallback: Colors.transparent,
                                      ),
                                    ),
                                  ],

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
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — HERO
// ══════════════════════════════════════════════════════════════════════════════
