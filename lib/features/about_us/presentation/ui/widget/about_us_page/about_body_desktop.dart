part of '../../pages/about_us_page.dart';

class _AboutBodyDesktop extends StatefulWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  final int? initialTopTab, initialSubTab;
  final VoidCallback? onTabApplied;
  const _AboutBodyDesktop({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.initialTopTab,
    this.initialSubTab,
    this.onTabApplied,
  });
  @override
  State<_AboutBodyDesktop> createState() => _AboutBodyDesktopState();
}

class _AboutBodyDesktopState extends State<_AboutBodyDesktop> {
  late int _selectedTab, _selectedTopTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = widget.initialTopTab ?? 0;
    _selectedTab = widget.initialSubTab ?? 0;
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onTabApplied?.call(),
    );
  }

  String _tabLabel(int i) => switch (i) {
    0 => widget.isRtl ? 'الرؤية' : 'Vision',
    1 => widget.isRtl ? 'الرسالة' : 'Mission',
    _ => widget.isRtl ? 'القيم' : 'Values',
  };
  String _tabIconUrl(int i) => switch (i) {
    0 => widget.model.vision.iconUrl,
    1 => widget.model.mission.iconUrl,
    _ => widget.model.values.isNotEmpty
        ? widget.model.values.first.iconUrl
        : '',
  };

  String _tabDesc(int i) {
    final desc = switch (i) {
      0 => _ab(widget.model.vision.subDescription, widget.isRtl),
      1 => _ab(widget.model.mission.subDescription, widget.isRtl),
      _ => widget.model.values.isNotEmpty
          ? _ab(widget.model.values.first.shortDescription, widget.isRtl)
          : '',
    };
    if (desc.length > 160) return '${desc.substring(0, 157)}…';
    return desc;
  }

  final List<BiText> _topTabs = [
    BiText(ar: 'من نحن', en: 'About Us'),
    BiText(ar: 'استراتيجيتنا', en: 'Our Strategy'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad = ((screenW - contentW) / 2).clamp(36.0, double.infinity),
        gap = 16.w,
        leftW = 280.w;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Tab Bar ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
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
                  0 => widget.model.navigationLabel.iconUrl,
                  _ => switch (context.read<StrategyCubit>().state) {
                    StrategyLoaded(:final data) =>
                    data.navigationLabel.iconUrl,
                    StrategySaved(:final data) =>
                    data.navigationLabel.iconUrl,
                    _ => '',
                  },
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
          SizedBox(height: 10.h),

          // ── Tab 0: About Us ──
          if (_selectedTopTab == 0)
            _Reveal(
              key: const ValueKey('top_0'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: leftW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (i) {
                          final bool isLast = i == 2;
                          return _Reveal(
                            key: ValueKey('top_0_tab_$i'),
                            delay: Duration(milliseconds: 120 + i * 80),
                            direction: _SlideDirection.fromLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: isLast ? 0 : 8.h,
                              ),
                              child: _DesktopTabItem(
                                label: _tabLabel(i),
                                iconUrl: _tabIconUrl(i),
                                selectedDesc: _selectedTab == i
                                    ? _tabDesc(i)
                                    : '',
                                isSelected: _selectedTab == i,
                                primaryColor: widget.primaryColor,
                                secondaryColor: widget.secondaryColor,
                                onTap: () =>
                                    setState(() => _selectedTab = i),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _Reveal(
                        key: const ValueKey('top_0_right'),
                        delay: const Duration(milliseconds: 180),
                        direction: _SlideDirection.fromRight,
                        child: _DesktopRightPanel(
                          model: widget.model,
                          tabIndex: _selectedTab,
                          isRtl: widget.isRtl,
                          primaryColor: widget.primaryColor,
                          secondaryColor: widget.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Tab 1: Our Strategy ──
          if (_selectedTopTab == 1)
            _Reveal(
              key: const ValueKey('top_1'),
              delay: const Duration(milliseconds: 100),
              direction: _SlideDirection.fromBottom,
              child: BlocBuilder<StrategyCubit, StrategyState>(
                builder: (context, strategyState) {
                  final String svgUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.vision.svgUrl,
                    StrategySaved(:final data) => data.vision.svgUrl,
                    _ => '',
                  };
                  final String strategicHouseEnUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.strategicHouseEnUrl,
                    StrategySaved(:final data) => data.strategicHouseEnUrl,
                    _ => '',
                  };
                  final String strategicHouseArUrl = switch (strategyState) {
                    StrategyLoaded(:final data) => data.strategicHouseArUrl,
                    StrategySaved(:final data) => data.strategicHouseArUrl,
                    _ => '',
                  };

                  return BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, langState) {
                      final bool isRtl = langState.isArabic;
                      final String strategicHouseUrl =
                      isRtl ? strategicHouseArUrl : strategicHouseEnUrl;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (svgUrl.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: _netImg(
                                  url: svgUrl,
                                  width: 300.w,
                                  height: 300.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                          SizedBox(height: 24.h),

                          if (strategicHouseUrl.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //color: widget.primaryColor,
                                Text(
                                  isRtl
                                      ? 'البيت الاستراتيجي'
                                      : 'Strategic House',
                                  style: StyleText.fontSize18Weight500.copyWith(
                                    color: widget.primaryColor,
                                  )
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(0.r),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Center(
                                    child: _netImg(
                                      url: strategicHouseUrl,
                                      width: double.infinity,
                                      height: 640.h,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (svgUrl.isEmpty && strategicHouseUrl.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Text(
                                  isRtl
                                      ? 'لا يوجد محتوى بعد'
                                      : 'No content yet',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
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
