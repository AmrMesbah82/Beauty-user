part of '../../pages/terms_of_service_page.dart';

class _TermsBodyDesktop extends StatefulWidget {
  final TermsOfServiceModel termsModel;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final String logoUrl;
  final int? initialTopTab;
  final VoidCallback? onTabApplied;
  const _TermsBodyDesktop({
    required this.termsModel,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoUrl,
    this.initialTopTab,
    this.onTabApplied,
  });
  @override
  State<_TermsBodyDesktop> createState() => _TermsBodyDesktopState();
}

class _TermsBodyDesktopState extends State<_TermsBodyDesktop> {
  late int _selectedTopTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onTabApplied?.call(),
    );
  }

  Widget _downloadButton({
    required bool isRtl,
    required String attachEnUrl,
    required String attachArUrl,
    required String sectionLabelEn,
    required String sectionLabelAr,
  }) {
    final String url = isRtl ? attachArUrl : attachEnUrl;
    if (url.isEmpty) return const SizedBox.shrink();

    final String label = isRtl
        ? 'تحميل PDF — $sectionLabelAr'
        : 'Download PDF — $sectionLabelEn';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => html.window.open(url, '_blank'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvg(
              assetPath: 'assets/download.svg',
              width: 12.h,
              height: 16.h,
              fit: BoxFit.scaleDown,
              color: widget.primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: StyleText.fontSize12Weight400.copyWith(
                color: widget.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docPanel({
    required String description,
    required String svgUrl,
    required String attachEnUrl,
    required String attachArUrl,
    required String sectionLabelEn,
    required String sectionLabelAr,
    required String lastUpdate,
  }) {
    // Get mainWidgetColor from HomeCmsCubit
    final homeState = context.watch<HomeCmsCubit>().state;
    final Color? mainWidgetColor = switch (homeState) {
      HomeCmsLoaded(:final data) => _parseHex(
        data.branding.mainWidgetColor,
        fallback: Colors.transparent,
      ),
      HomeCmsSaved(:final data) => _parseHex(
        data.branding.mainWidgetColor,
        fallback: Colors.transparent,
      ),
      _ => Colors.transparent,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: mainWidgetColor,  // ← Changed from _kSurface to mainWidgetColor
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.logoUrl.isNotEmpty)
                          _netImg(
                            url: widget.logoUrl,
                            width: 80.w,
                            height: 40.h,
                            fit: BoxFit.contain,
                          )
                        else
                          const SizedBox.shrink(),
                        if (lastUpdate.isNotEmpty)
                          Text(
                            lastUpdate,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryBlack.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      description,
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 13.sp,
                        height: 1.75,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              _downloadButton(
                isRtl: widget.isRtl,
                attachEnUrl: attachEnUrl,
                attachArUrl: attachArUrl,
                sectionLabelEn: sectionLabelEn,
                sectionLabelAr: sectionLabelAr,
              ),
            ],
          ),
        ),
      ],
    );
  }

  final List<BiText> _topTabs = [
    BiText(ar: 'الشروط والأحكام', en: 'Terms and Conditions'),
    BiText(ar: 'سياسة الخصوصية', en: 'Privacy Policy'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad =
    ((screenW - contentW) / 2).clamp(36.0, double.infinity);
    final TermsSection terms = widget.termsModel.termsAndConditions,
        privacy = widget.termsModel.privacyPolicy;

    final String termsLastUpdate = widget.isRtl
        ? 'آخر تحديث: ${terms.lastUpdate ?? ''}'
        : 'Last Update: ${terms.lastUpdate ?? ''}';
    final String privacyLastUpdate = widget.isRtl
        ? 'آخر تحديث: ${privacy.lastUpdate ?? ''}'
        : 'Last Update: ${privacy.lastUpdate ?? ''}';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Tab Bar ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_topTabs.length, (i) {
                final bool isRtl =
                    context.read<LanguageCubit>().state.isArabic;
                final String label = isRtl
                    ? (_topTabs[i].ar.isNotEmpty
                    ? _topTabs[i].ar
                    : _topTabs[i].en)
                    : _topTabs[i].en;
                final String svgAsset = switch (i) {
                  0 => terms.svgUrl,
                  _ => privacy.svgUrl,
                };
                return _DesktopTopTabItem(
                  index: i,
                  label: label,
                  svgAsset: svgAsset,
                  isSelected: i == _selectedTopTab,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  onTap: () => setState(() => _selectedTopTab = i),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Tab 0: Terms and Conditions ──
          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _docPanel(
                description: _ab(terms.description, widget.isRtl),
                svgUrl: terms.svgUrl,
                attachEnUrl: terms.attachEnUrl,
                attachArUrl: terms.attachArUrl,
                sectionLabelEn: 'Terms and Conditions',
                sectionLabelAr: 'الشروط والأحكام',
                lastUpdate: termsLastUpdate,
              ),
            ),

          // ── Tab 1: Privacy Policy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _docPanel(
                description: _ab(privacy.description, widget.isRtl),
                svgUrl: privacy.svgUrl,
                attachEnUrl: privacy.attachEnUrl,
                attachArUrl: privacy.attachArUrl,
                sectionLabelEn: 'Privacy Policy',
                sectionLabelAr: 'سياسة الخصوصية',
                lastUpdate: privacyLastUpdate,
              ),
            ),

          SizedBox(height: 36.h),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Top Tab Item
// ══════════════════════════════════════════════════════════════════════════════
