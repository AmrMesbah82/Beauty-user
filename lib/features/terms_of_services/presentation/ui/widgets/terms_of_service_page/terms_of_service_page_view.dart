part of '../../pages/terms_of_service_page.dart';

class _TermsOfServicePageView extends StatefulWidget {
  final String initialTab;

  const _TermsOfServicePageView({this.initialTab = ''});

  @override
  State<_TermsOfServicePageView> createState() =>
      _TermsOfServicePageViewState();
}

class _TermsOfServicePageViewState extends State<_TermsOfServicePageView> {
  bool _showLoader = true, _preloadStarted = false;
  int? _initialTopTab;
  bool _tabParamApplied = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialTab.isNotEmpty) {
      final resolved = _resolveTabParam(widget.initialTab);
      _initialTopTab = resolved.topTab;
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
      if (_initialTopTab != resolved.topTab) {
        setState(() {
          _initialTopTab = resolved.topTab;
          _tabParamApplied = false;
        });
      }
    }
  }

  Future<void> _preloadAndReveal({required String logoUrl}) async {
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

        return BlocBuilder<TermsCubit, TermsState>(
          builder: (context, termsState) {
            final TermsOfServiceModel? termsModel = switch (termsState) {
              TermsLoaded() => termsState.data,
              TermsSaved() => termsState.data,
              _ => null,
            };
            final bool termsReady = termsModel != null,
                isError = termsState is TermsError,
                allReady = homeReady && termsReady;
            if (allReady && !_preloadStarted)
              _preloadAndReveal(logoUrl: logoUrl);
            if (isError && !termsReady)
              return Scaffold(
                backgroundColor: backgroundColor,
                body: Center(
                  child: Text(
                    'Failed to load: ${(termsState as TermsError).message}',
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

                    // ── SVG to show in the page header ─────────────────────────
                    final String headerSvgUrl =
                        termsModel!.termsAndConditions.svgUrl;

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
                                child: AppNavbar(currentRoute: '/terms'),
                              ),

                              // ✅ Scrollable content
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      // ── Page header with SVG ────────────────
                                      _Reveal(
                                        delay:
                                        const Duration(milliseconds: 80),
                                        direction: isRtl
                                            ? _SlideDirection.fromRight
                                            : _SlideDirection.fromLeft,
                                        duration: const Duration(
                                            milliseconds: 650),
                                        child: w < _BP.mobile
                                            ? _TermsHeaderMobile(
                                          isRtl: isRtl,
                                          primaryColor: primaryColor,
                                          svgUrl: headerSvgUrl,
                                        )
                                            : _TermsHeaderDesktop(
                                          isRtl: isRtl,
                                          primaryColor: primaryColor,
                                          svgUrl: headerSvgUrl,
                                        ),
                                      ),

                                      // ── Body (tabs + doc panels) ───────────
                                      w < _BP.mobile
                                          ? _TermsBodyMobile(
                                        termsModel: termsModel,
                                        isRtl: isRtl,
                                        primaryColor: primaryColor,
                                        secondaryColor: secondaryColor,
                                        logoUrl: logoUrl,
                                        initialTopTab: _tabParamApplied
                                            ? null
                                            : _initialTopTab,
                                        onTabApplied: () =>
                                        _tabParamApplied = true,
                                      )
                                          : _TermsBodyDesktop(
                                        termsModel: termsModel,
                                        isRtl: isRtl,
                                        primaryColor: primaryColor,
                                        secondaryColor: secondaryColor,
                                        logoUrl: logoUrl,
                                        initialTopTab: _tabParamApplied
                                            ? null
                                            : _initialTopTab,
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
// Headers
// ══════════════════════════════════════════════════════════════════════════════
