// ******************* FILE INFO *******************
// File Name: app_navbar.dart
// UPDATED: Fixed navigation for all 6 navbar items using direct Navigator.push
//          Index 0: Home (/)
//          Index 1: Overview (/services)
//          Index 2: Our Products (/about)
//          Index 3: About Us (/contact)
//          Index 4: Terms Services (/terms)
//          Index 5: Contact Us (/contactus)
// UPDATED: _getVisibleNavItems now returns iconUrl from NavButtonModel
// ADDED:   _NavIcon widget — shows Firebase iconUrl if set, falls back to local SVG asset
// UPDATED: _FullScreenDrawer and _NavItem both use _NavIcon
// ADDED:   Gender toggle connected to GenderCubit — switches data across all page cubits

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/gender/gender_cubit.dart';
import '../controller/gender/gender_state.dart';
import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../model/home/home_model.dart';
import '../page/contact_page.dart';
import '../page/about_page.dart';
import '../page/our_products_page.dart';
import '../page/overview_page.dart';
import '../page/terms_of_service_page.dart';
import '../theme/app_theme.dart';
import '../theme/app_wight.dart';
import '../theme/appcolors.dart';

class _WebColors {
  static const Color primary        = Colors.transparent;
  static const Color cardLightGreen = Color(0xFFE8F5EE);
  static const Color drawerBg       = Color(0xFFF5F9F5);
}

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

void _navigate(BuildContext context, String route) {
  print('🚀 _navigate called with route: $route');

  final homeCubit   = context.read<HomeCmsCubit>();
  final langCubit   = context.read<LanguageCubit>();
  final genderCubit = context.read<GenderCubit>();

  Widget page;

  switch (route) {
    case '/':
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;

    case '/services':
      print('✅ Navigating to OverviewPage');
      page = const OverviewPage();
      break;

    case '/about':
      print('✅ Navigating to OurProductsPage');
      page = const OurProductsPage();
      break;

    case '/contact':
      print('✅ Navigating to AboutPage');
      page = const AboutPage();
      break;

    case '/terms':
      print('✅ Navigating to TermsOfServicePage');
      page = const TermsOfServicePage();
      break;

    case '/contactus':
      print('✅ Navigating to ContactPage');
      page = const ContactPage();
      break;

    default:
      print('❌ unknown route: $route — returning to home');
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
  }

  print('➡️ pushing route: $route');
  Navigator.of(context).push(
    MaterialPageRoute(
      settings: RouteSettings(name: route),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: homeCubit),
          BlocProvider.value(value: langCubit),
          BlocProvider.value(value: genderCubit),
        ],
        child: page,
      ),
    ),
  );
}

const Map<String, String> _kSvgMap = {
  '/':          'assets/drawer/home_drawer.svg',
  '/services':  'assets/drawer/services_drawer.svg',
  '/about':     'assets/drawer/services_drawer.svg',
  '/contact':   'assets/drawer/services_drawer.svg',
  '/terms':     'assets/drawer/services_drawer.svg',
  '/contactus': 'assets/drawer/about_us_drawer.svg',
};

// Gender icons
const String _kMaleIcon   = 'assets/male.svg';


Color _primaryFromState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data)  => data.branding.primaryColor,
    _                          => '',
  };
  return _hexColor(hex, _WebColors.primary);
}

Color _navbarBgFromState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.headerFooterColor,
    HomeCmsSaved(:final data)  => data.branding.headerFooterColor,
    _                          => '',
  };
  return _hexColor(hex, AppColors.white);
}

Color _hexColor(String hex, Color fallback) {
  try {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {}
  return fallback;
}

Color _lightTint(Color primary) => primary.withOpacity(0.12);

// ─────────────────────────────────────────────────────────────────────────────
// Nav item record — now includes iconUrl from Firebase
// ─────────────────────────────────────────────────────────────────────────────

typedef _NavItemData = ({
String label,
String route,
String svgAsset,
String iconUrl,
});

List<_NavItemData> _getVisibleNavItems(
    String languageCode, HomeCmsState cmsState) {

  final List<NavButtonModel> navButtons = switch (cmsState) {
    HomeCmsLoaded(:final data) => data.navButtons,
    HomeCmsSaved(:final data)  => data.navButtons,
    _                          => HomePageModel.defaultModel.navButtons,
  };

  final bool isAr = languageCode == 'ar';

  return navButtons
      .where((btn) => btn.status)
      .where((btn) => btn.route.isNotEmpty)
      .map((btn) => (
  label: isAr
      ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en)
      : (btn.name.en.isNotEmpty ? btn.name.en : btn.name.ar),
  route:    btn.route,
  svgAsset: _kSvgMap[btn.route] ?? 'assets/drawer/home_drawer.svg',
  iconUrl:  btn.iconUrl,
  ))
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavIcon — shows Firebase iconUrl when available, falls back to local SVG
// ─────────────────────────────────────────────────────────────────────────────

class _NavIcon extends StatelessWidget {
  final String iconUrl;   // Firebase URL — may be empty
  final String svgAsset;  // local asset fallback
  final Color  color;
  final double size;

  const _NavIcon({
    required this.iconUrl,
    required this.svgAsset,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colorFilter = ColorFilter.mode(color, BlendMode.srcIn);

    if (iconUrl.isNotEmpty) {
      return SvgPicture.network(
        iconUrl,
        width:              size.w,
        height:             size.w,
        colorFilter:        colorFilter,
        placeholderBuilder: (_) => _localSvg(colorFilter),
      );
    }
    return _localSvg(colorFilter);
  }

  Widget _localSvg(ColorFilter colorFilter) => SvgPicture.asset(
    svgAsset,
    width:       size.w,
    height:      size.w,
    colorFilter: colorFilter,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppNavbar — entry point
// ─────────────────────────────────────────────────────────────────────────────

class AppNavbar extends StatelessWidget {
  final String currentRoute;

  /// Optional callback invoked when a nav item is tapped.
  /// Receives the route string of the tapped item (e.g. '/careers').
  /// When null the navbar falls back to Navigator.push.
  final void Function(String route)? onItemTap;

  const AppNavbar({
    super.key,
    required this.currentRoute,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, cmsState) {
        final Color primary  = _primaryFromState(cmsState);
        final Color navbarBg = _navbarBgFromState(cmsState);
        final double w       = MediaQuery.of(context).size.width;

        if (w >= _BP.tablet) {
          return _NavbarDesktop(
            currentRoute: currentRoute,
            primary:      primary,
            navbarBg:     navbarBg,
            cmsState:     cmsState,
            onItemTap:    onItemTap,
          );
        }
        if (w >= _BP.mobile) {
          return _NavbarDesktop(
            currentRoute: currentRoute,
            primary:      primary,
            navbarBg:     navbarBg,
            cmsState:     cmsState,
            onItemTap:    onItemTap,
          );
        }
        return _NavbarMobile(
          currentRoute: currentRoute,
          primary:      primary,
          navbarBg:     navbarBg,
          cmsState:     cmsState,
          onItemTap:    onItemTap,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP  (≥ 1024px) — design size 1366×768
// ═══════════════════════════════════════════════════════════════════════════════

class _NavbarDesktop extends StatelessWidget {
  final String                       currentRoute;
  final Color                        primary;
  final Color                        navbarBg;
  final HomeCmsState                 cmsState;
  final void Function(String route)? onItemTap;

  const _NavbarDesktop({
    required this.currentRoute,
    required this.primary,
    required this.navbarBg,
    required this.cmsState,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final navItems = _getVisibleNavItems(langState.locale.languageCode, cmsState);
        final isRtl    = langState.isArabic;
        var isMobile = context.isPhone;
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            width: double.infinity,
            color: navbarBg,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _BayanatzLogo(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: navItems
                          .map((e) => _NavItem(
                        key:          ValueKey('${e.route}_${langState.locale.languageCode}'),
                        label:        e.label,
                        route:        e.route,
                        svgAsset:     e.svgAsset,
                        iconUrl:      e.iconUrl,
                        currentRoute: currentRoute,
                        primary:      primary,
                        onItemTap:    onItemTap,
                      ))
                          .toList(),
                    ),
                  ),
                  Row(
                    children: [
                      _GenderToggle(primary: primary),
                      SizedBox(width: 12.w),
                      _LanguageToggle(primary: primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE  (< 600px) — design size 375×812
// ═══════════════════════════════════════════════════════════════════════════════

class _NavbarMobile extends StatelessWidget {
  final String                       currentRoute;
  final Color                        primary;
  final Color                        navbarBg;
  final HomeCmsState                 cmsState;
  final void Function(String route)? onItemTap;

  const _NavbarMobile({
    required this.currentRoute,
    required this.primary,
    required this.navbarBg,
    required this.cmsState,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final isRtl = langState.isArabic;

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            color: navbarBg,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _BayanatzLogo(rawSize: true),
                  Row(
                    children: [
                      _GenderToggle(primary: primary, isCompact: true),
                      SizedBox(width: 8.w),
                      _LanguageToggle(primary: primary, isCompact: true),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () => _openDrawer(context),
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.menu_rounded,
                              color: AppColors.textButton, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDrawer(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque:            false,
        barrierDismissible: true,
        barrierColor:      Colors.transparent,
        pageBuilder: (ctx, anim, _) => _FullScreenDrawer(
          currentRoute: currentRoute,
          primary:      primary,
          navbarBg:     navbarBg,
          cmsState:     cmsState,
          onItemTap:    onItemTap,
        ),
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ─── Full-Screen Drawer (mobile) ──────────────────────────────────────────────

class _FullScreenDrawer extends StatelessWidget {
  final String                       currentRoute;
  final Color                        primary;
  final Color                        navbarBg;
  final HomeCmsState                 cmsState;
  final void Function(String route)? onItemTap;

  const _FullScreenDrawer({
    required this.currentRoute,
    required this.primary,
    required this.navbarBg,
    required this.cmsState,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final navItems    = _getVisibleNavItems(langState.locale.languageCode, cmsState);
        final isRtl       = langState.isArabic;
        final Color lightTint = _lightTint(primary);

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: _WebColors.drawerBg,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top bar ───────────────────────────────────────────
                  Container(
                    color: navbarBg,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _BayanatzLogo(rawSize: true),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: lightTint,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.close,
                                color: primary, size: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // ── Nav list ──────────────────────────────────────────
                  Expanded(
                    child: ListView(
                      key: ValueKey(langState.locale.languageCode),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      children: [
                        ...navItems.asMap().entries.map((entry) {
                          final index    = entry.key;
                          final e        = entry.value;
                          final bool isActive = currentRoute == e.route;

                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (onItemTap != null) {
                                    onItemTap!(e.route);
                                  } else {
                                    _navigate(context, e.route);
                                  }
                                },
                                child: Container(
                                  key: ValueKey('${e.route}_${langState.locale.languageCode}'),
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16.h, horizontal: 16.w),
                                  decoration: BoxDecoration(
                                    color: isActive ? primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    children: [
                                      // ✅ Firebase icon with local SVG fallback
                                      _NavIcon(
                                        iconUrl:  e.iconUrl,
                                        svgAsset: e.svgAsset,
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.textButton,
                                        size: 24,
                                      ),
                                      SizedBox(width: 14.w),
                                      Text(
                                        e.label,
                                        textDirection: isRtl
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        style: GoogleFonts.cairo(
                                          fontSize: 16.sp,
                                          fontWeight: isActive
                                              ? AppFontWeights.semiBold
                                              : AppFontWeights.regular,
                                          color: isActive
                                              ? Colors.white
                                              : AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (index < navItems.length - 1)
                                Divider(
                                  height: 1.h,
                                  thickness: 1,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _BayanatzLogo extends StatelessWidget {
  final bool rawSize;
  const _BayanatzLogo({this.rawSize = false});

  @override
  Widget build(BuildContext context) {
    final double sz = rawSize ? 40.w : 36.w;

    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        final String logoUrl = switch (state) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _                          => '',
        };

        // ── Still loading (no data yet) → show empty box, no fallback logo
        if (state is HomeCmsLoading || state is HomeCmsInitial) {
          return GestureDetector(
            onTap: () => _navigate(context, '/'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(width: sz, height: sz),
            ),
          );
        }

        // ── Data loaded but no logoUrl → show local asset
        if (logoUrl.isEmpty) {
          return GestureDetector(
            onTap: () => _navigate(context, '/'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image(
                  image: const AssetImage("assets/images/logo.jpg"),
                  width: sz,
                  height: sz,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        }

        // ── Data loaded + logoUrl exists → show network logo, NO local fallback flash
        return GestureDetector(
          onTap: () {
            print('🖱️ Logo tapped - navigating to home');
            _navigate(context, '/');
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SvgPicture.network(
                logoUrl,
                width: sz,
                height: sz,
                fit: BoxFit.fill,
                placeholderBuilder: (_) => SizedBox(width: sz, height: sz),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final String label;
  final String route;
  final String svgAsset;
  final String iconUrl;
  final String currentRoute;
  final Color  primary;
  final bool   compact;
  final void Function(String route)? onItemTap;

  const _NavItem({
    super.key,
    required this.label,
    required this.route,
    required this.svgAsset,
    required this.iconUrl,
    required this.currentRoute,
    required this.primary,
    this.compact  = false,
    this.onItemTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;
  bool get _isActive => widget.currentRoute == widget.route;

  @override
  Widget build(BuildContext context) {
    final Color hoverBg = _lightTint(widget.primary);
    var isMobile = context.isPhone;
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) => setState(() => _hovered = false),
          cursor:  SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              print('🖱️ Nav item tapped: ${widget.label} -> route: ${widget.route}');
              if (widget.onItemTap != null) {
                widget.onItemTap!(widget.route);
              } else {
                _navigate(context, widget.route);
              }
            },
            child: AnimatedContainer(
              duration:  const Duration(milliseconds: 200),
              margin:    EdgeInsets.symmetric(horizontal: 4.w),
              padding:   EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _isActive
                    ? widget.primary
                    : (_hovered ? hoverBg : Colors.transparent),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child:    isMobile ?  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.iconUrl.isNotEmpty || true)
                    ...[
                      _NavIcon(
                        iconUrl:  widget.iconUrl,
                        svgAsset: widget.svgAsset,
                        color: _isActive
                            ? Colors.white
                            : (_hovered ? widget.primary : AppColors.textButton),
                        size: 18,
                      ),
                      SizedBox(width: 6.w),
                    ],
                  Text(
                    widget.label,
                    textDirection: langState.isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: GoogleFonts.cairo(
                      fontSize:   14.sp,
                      fontWeight: _isActive
                          ? AppFontWeights.semiBold
                          : AppFontWeights.regular,
                      color: _isActive
                          ? Colors.white
                          : (_hovered ? widget.primary : AppColors.text),
                    ),
                  ),
                ],
              ) :   Text(
                widget.label,
                textDirection: langState.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: GoogleFonts.cairo(
                  fontSize:   14.sp,
                  fontWeight: _isActive
                      ? AppFontWeights.semiBold
                      : AppFontWeights.regular,
                  color: _isActive
                      ? Colors.white
                      : (_hovered ? widget.primary : AppColors.text),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Gender Toggle — connected to GenderCubit ─────────────────────────────────

// ─── Gender Toggle — connected to GenderCubit ─────────────────────────────────

class _GenderToggle extends StatelessWidget {
  final Color primary;
  final bool isCompact;

  const _GenderToggle({
    required this.primary,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenderCubit, GenderState>(
      builder: (context, genderState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              context.read<GenderCubit>().toggle();
            },
            child: Container(
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(isCompact ? 8.w : 10.w),
              child: SvgPicture.asset(
                _kMaleIcon,
                width: isCompact ? 18.w : 20.w,
                height: isCompact ? 18.w : 20.w,
                colorFilter: ColorFilter.mode(
                  genderState.isMale ? primary : AppColors.secondaryText,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Language Toggle ──────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  final Color primary;
  final bool isCompact;

  const _LanguageToggle({
    required this.primary,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            color: AppColors.secondaryText.withOpacity(.1),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangBtn(
                  label:  'AR',
                  active: state.isArabic,
                  primary: primary,
                  onTap: () => context.read<LanguageCubit>().setLanguage('ar'),
                ),
                SizedBox(width: 4.w),
                _LangBtn(
                  label:  'EN',
                  active: state.isEnglish,
                  primary: primary,
                  onTap: () => context.read<LanguageCubit>().setLanguage('en'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String       label;
  final bool         active;
  final Color        primary;
  final VoidCallback onTap;

  const _LangBtn({
    required this.label,
    required this.active,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: active ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize:   12.sp,
              fontWeight: AppFontWeights.semiBold,
              color: active ? Colors.white : AppColors.secondaryBlack,
            ),
          ),
        ),
      ),
    );
  }
}