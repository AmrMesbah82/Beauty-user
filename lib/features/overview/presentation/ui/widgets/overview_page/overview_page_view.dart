part of '../../pages/overview_page.dart';

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

          // ✅ GenderCubit wraps BEFORE primaryColor is resolved
          return BlocBuilder<GenderCubit, GenderState>(
            builder: (context, genderState) {
              // ✅ Gender-aware primary color
              final Color primaryColor = _resolvePrimary(homeData, genderState.isMale);

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
                        textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                        child: AppPageShell(
                          currentRoute: '/services',
                          body: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: _RevealCoordinatorWidget(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: 40.h),

                                    // ═══ SECTION 1 — OVERVIEW ═══
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
                                        backgroundColor: _parseHex(           // ← NEW: Pass mainWidgetColor
                                          homeData.branding.mainWidgetColor,
                                          fallback: Colors.transparent,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 50.h),

                                    // ═══ SECTION 2 — TOP SERVICES ═══
                                    _Reveal(
                                      delay: const Duration(
                                          milliseconds: 120),
                                      direction: _SlideDirection.fromLeft,
                                      duration: const Duration(
                                          milliseconds: 650),
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
                                      delay: const Duration(
                                          milliseconds: 180),
                                      direction: _SlideDirection.fromRight,
                                      duration: const Duration(
                                          milliseconds: 650),
                                      child: _GallerySection(
                                        backgroundColor: _parseHex(           // ← ADD
                                          homeData.branding.mainWidgetColor,
                                          fallback: Colors.transparent,
                                        ),
                                        primaryColor: primaryColor,
                                        title:
                                        isAr ? 'المعرض' : 'Gallery',
                                        images: model.gallery.images,
                                      ),
                                    ),

                                    SizedBox(height: 50.h),

                                    // ═══ SECTION 4 — CLIENT TESTIMONIALS ═══
                                    _Reveal(
                                      delay: const Duration(
                                          milliseconds: 240),
                                      direction:
                                      _SlideDirection.fromBottom,
                                      duration: const Duration(
                                          milliseconds: 650),
                                      child: _TestimonialsSection(
                                        primaryColor: primaryColor,
                                        backgroundColor: _parseHex(          // ← ADD
                                          homeData.branding.mainWidgetColor,
                                          fallback: Colors.transparent,
                                        ),
                                        sectionTitle: isAr
                                            ? model
                                            .clientComments.title.ar
                                            : model
                                            .clientComments.title.en,
                                        comments:
                                        model.clientComments.comments,
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
                                        backgroundColor: _parseHex(           // ← NEW: Pass mainWidgetColor
                                          homeData.branding.mainWidgetColor,
                                          fallback: Colors.transparent,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 40.h),
                                  ],
                                ),
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
// SECTION 1 — OVERVIEW
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — OVERVIEW (WITH BACKGROUND COLOR)
// ══════════════════════════════════════════════════════════════════════════════
