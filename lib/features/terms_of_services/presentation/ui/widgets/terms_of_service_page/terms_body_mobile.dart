part of '../../pages/terms_of_service_page.dart';

class _TermsBodyMobile extends StatefulWidget {
  final TermsOfServiceModel termsModel;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final String logoUrl;
  final int? initialTopTab;
  final VoidCallback? onTabApplied;
  const _TermsBodyMobile({
    required this.termsModel,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logoUrl,
    this.initialTopTab,
    this.onTabApplied,
  });
  @override
  State<_TermsBodyMobile> createState() => _TermsBodyMobileState();
}

class _TermsBodyMobileState extends State<_TermsBodyMobile> {
  late int _selectedTopTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onTabApplied?.call(),
    );
  }

  final List<BiText> _topTabs = [
    BiText(ar: 'الشروط والأحكام', en: 'Terms and Conditions'),
    BiText(ar: 'سياسة الخصوصية', en: 'Privacy Policy'),
  ];

  @override
  Widget build(BuildContext context) {
    final TermsSection terms = widget.termsModel.termsAndConditions,
        privacy = widget.termsModel.privacyPolicy;

    final String termsLastUpdate = (terms.lastUpdate?.isNotEmpty == true)
        ? (widget.isRtl
        ? 'آخر تحديث: ${terms.lastUpdate}'
        : 'Last Update: ${terms.lastUpdate}')
        : '';

    final String privacyLastUpdate = (privacy.lastUpdate?.isNotEmpty == true)
        ? (widget.isRtl
        ? 'آخر تحديث: ${privacy.lastUpdate}'
        : 'Last Update: ${privacy.lastUpdate}')
        : '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_topTabs.length, (i) {
                return _MobileTopTabItem(
                  label: widget.isRtl
                      ? (_topTabs[i].ar.isNotEmpty
                      ? _topTabs[i].ar
                      : _topTabs[i].en)
                      : _topTabs[i].en,
                  svgAsset: switch (i) {
                    0 => terms.svgUrl,
                    _ => privacy.svgUrl,
                  },
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
              key: const ValueKey('mob_top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileDocPanel(
                description: _ab(terms.description, widget.isRtl),
                svgUrl: terms.svgUrl,
                attachEnUrl: terms.attachEnUrl,
                attachArUrl: terms.attachArUrl,
                sectionLabelEn: 'Terms and Conditions',
                sectionLabelAr: 'الشروط والأحكام',
                primaryColor: widget.primaryColor,
                logoUrl: widget.logoUrl,
                lastUpdate: termsLastUpdate,
                isRtl: widget.isRtl,
              ),
            ),

          // ── Tab 1: Privacy Policy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('mob_top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: _MobileDocPanel(
                description: _ab(privacy.description, widget.isRtl),
                svgUrl: privacy.svgUrl,
                attachEnUrl: privacy.attachEnUrl,
                attachArUrl: privacy.attachArUrl,
                sectionLabelEn: 'Privacy Policy',
                sectionLabelAr: 'سياسة الخصوصية',
                primaryColor: widget.primaryColor,
                logoUrl: widget.logoUrl,
                lastUpdate: privacyLastUpdate,
                isRtl: widget.isRtl,
              ),
            ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Mobile Top Tab Item
// ══════════════════════════════════════════════════════════════════════════════
