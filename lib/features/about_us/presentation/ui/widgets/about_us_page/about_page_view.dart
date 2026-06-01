part of '../../pages/about_us_page.dart';

class _AboutPageView extends StatefulWidget {
  final String initialTab;
  const _AboutPageView({this.initialTab = ''});

  @override
  State<_AboutPageView> createState() => _AboutPageViewState();
}

class _AboutPageViewState extends State<_AboutPageView> {
  bool _showLoader = true, _preloadStarted = false;
  int? _initialTopTab, _initialSubTab;
  bool _tabParamApplied = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialTab.isNotEmpty) {
      final resolved = _resolveTabParam(widget.initialTab);
      _initialTopTab = resolved.topTab;
      _initialSubTab = resolved.subTab;
    }

    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
      _readTabParam();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _readTabParam();
  }

  void _readTabParam() {
    if (!mounted) return;
    if (_initialTopTab != null) return;
    final uri = GoRouterState.of(context).uri;
    final tabParam = uri.queryParameters['tab'];
    if (tabParam != null && tabParam.isNotEmpty) {
      final resolved = _resolveTabParam(tabParam);
      if (_initialTopTab != resolved.topTab ||
          _initialSubTab != resolved.subTab) {
        setState(() {
          _initialTopTab = resolved.topTab;
          _initialSubTab = resolved.subTab;
          _tabParamApplied = false;
        });
      }
    }
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required AboutPageModel model,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _showLoader = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final String logoUrl = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data) => data.branding.logoUrl,
          _ => context.read<HomeCmsCubit>().current.branding.logoUrl,
        };
        final String primaryColorHex = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.primaryColor,
          HomeCmsSaved(:final data) => data.branding.primaryColor,
          _ => '',
        };
        final String malePrimaryColorHex = switch (homeState) {
          HomeCmsLoaded(:final data) => data.branding.malePrimaryColor,
          HomeCmsSaved(:final data) => data.branding.malePrimaryColor,
          _ => '',
        };
        final Color secondaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseHex(
            data.branding.secondaryColor,
            fallback: const Color(0xFFE8F5EE),
          ),
          HomeCmsSaved(:final data) => _parseHex(
            data.branding.secondaryColor,
            fallback: const Color(0xFFE8F5EE),
          ),
          _ => const Color(0xFFE8F5EE),
        };
        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseHex(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          HomeCmsSaved(:final data) => _parseHex(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          _ => AppColors.background,
        };
        final bool homeReady =
            homeState is HomeCmsLoaded || homeState is HomeCmsSaved;

        if (homeState is HomeCmsError &&
            homeState.lastData == null &&
            _showLoader) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showLoader = false);
          });
        }

        return BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            final AboutPageModel? model = switch (state) {
              AboutLoaded() => state.data,
              AboutSaved() => state.data,
              _ => null,
            };
            final bool aboutReady = model != null,
                isError = state is AboutError,
                allReady = homeReady && aboutReady;
            if (allReady && !_preloadStarted)
              _preloadAndReveal(logoUrl: logoUrl, model: model!);
            if (isError && !aboutReady)
              return Scaffold(
                backgroundColor: backgroundColor,
                body: Center(
                  child: Text(
                    'Failed to load: ${(state as AboutError).message}',
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            final Color loaderBg = switch (homeState) {
              HomeCmsLoaded(:final data) => _parseHex(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              HomeCmsSaved(:final data) => _parseHex(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              _ => const Color(0xFFF5F5F5),
            };
            if (_showLoader || !allReady)
              return _SvgPulseLoader(
                logoUrl: logoUrl.isEmpty ? null : logoUrl,
                backgroundColor: loaderBg,
              );

            // ── Gender-aware color rebuild ──────────────────────────────────
            return BlocBuilder<GenderCubit, GenderState>(
              builder: (context, genderState) {
                final bool isMale = genderState.isMale;

                // ✅ Pick primary color based on current gender
                final Color primaryColor = _resolvePrimaryColor(
                  primaryColorHex: primaryColorHex,
                  malePrimaryColorHex: malePrimaryColorHex,
                  isMale: isMale,
                );

                return BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, langState) {
                    final bool isRtl = langState.isArabic;
                    final double w = MediaQuery.of(context).size.width;

                    // ── Hero section children — explicit LTR vs RTL order ──
                    // We do NOT rely on Directionality to flip the Row because
                    // the SVG and title have different sizes; explicit ordering
                    // gives predictable alignment in both languages.
                    final Widget svgHero = model!.svgUrl.isNotEmpty && w >= _BP.mobile
                        ? _Reveal(
                      delay: const Duration(milliseconds: 60),
                      direction: isRtl
                          ? _SlideDirection.fromLeft
                          : _SlideDirection.fromRight,
                      duration: const Duration(milliseconds: 600),
                      child: _HeadingsSvgDesktop(svgUrl: model.svgUrl),
                    )
                        : const SizedBox.shrink();

                    final Widget titleHero = Expanded(
                      child: _Reveal(
                        delay: const Duration(milliseconds: 80),
                        direction: isRtl
                            ? _SlideDirection.fromRight
                            : _SlideDirection.fromLeft,
                        duration: const Duration(milliseconds: 650),
                        child: w < _BP.mobile
                            ? _AboutHeaderMobile(
                          model: model,
                          isRtl: isRtl,
                          primaryColor: primaryColor,
                        )
                            : _AboutHeaderDesktop(
                          model: model,
                          isRtl: isRtl,
                          primaryColor: primaryColor,
                        ),
                      ),
                    );

                    return Directionality(
                      textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                      child: Scaffold(
                        backgroundColor: backgroundColor,
                        body: _RevealCoordinatorWidget(
                          child: Column(
                            children: [
                              // ✅ Navbar
                              Material(
                                color: backgroundColor,
                                elevation: 0,
                                child: AppNavbar(currentRoute: '/contact'),
                              ),

                              // ✅ Scrollable content
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // ── Hero Row: SVG + Title ──
                                      // LTR (EN): [SVG]  [Title →→→→→→]
                                      // RTL (AR): [←←←← Title]  [SVG]
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width*.17,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: isRtl
                                              ? [titleHero, svgHero]
                                              : [svgHero, titleHero],
                                        ),
                                      ),

                                      // ── Body ──
                                      w < _BP.mobile
                                          ? _AboutBodyMobile(
                                        model: model,
                                        isRtl: isRtl,
                                        primaryColor: primaryColor,
                                        secondaryColor: secondaryColor,
                                        initialTopTab: _tabParamApplied
                                            ? null
                                            : _initialTopTab,
                                        initialSubTab: _tabParamApplied
                                            ? null
                                            : _initialSubTab,
                                        onTabApplied: () =>
                                        _tabParamApplied = true,
                                      )
                                          : _AboutBodyDesktop(
                                        model: model,
                                        isRtl: isRtl,
                                        primaryColor: primaryColor,
                                        secondaryColor: secondaryColor,
                                        initialTopTab: _tabParamApplied
                                            ? null
                                            : _initialTopTab,
                                        initialSubTab: _tabParamApplied
                                            ? null
                                            : _initialSubTab,
                                        onTabApplied: () =>
                                        _tabParamApplied = true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ✅ Footer
                              _Reveal(
                                delay: const Duration(milliseconds: 100),
                                direction: _SlideDirection.fromBottom,
                                duration: const Duration(milliseconds: 600),
                                child: const AppFooter(),
                              ),
                            ],
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
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Headings SVG Hero Banner — Desktop
// Fixed: wrapped in SizedBox to prevent overflow / uncontrolled growth
// ══════════════════════════════════════════════════════════════════════════════
