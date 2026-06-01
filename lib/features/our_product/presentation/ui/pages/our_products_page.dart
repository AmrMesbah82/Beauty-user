/// ******************* FILE INFO *******************
/// File Name: our_products_page.dart
/// Description: "Our Products" page for the Beauty App (Bayanatz).
///              Two tabs: Client Service & Owner Service.
///              Client Service tab → ClientServicesCubit (clientServicesPages collection).
///              Owner Service tab  → OwnerServicesCubit  (ownerServicesPages collection).
///              Each tab renders: Header hero → Download bar → Mockups.
///              ALL data is DYNAMIC from Firebase. No static data in this file.
/// Created by: Amr Mesbah
/// Last Update: 11/05/2026
/// UPDATED: Applied identical XHR-cache loader + _SvgPulseLoader + _RevealCoordinator
///          + _Reveal animation system from about_us_page.dart — UI/sections unchanged.
/// UPDATED: Deep-link support — reads ?tab=client-service or ?tab=owner-service
///          from the URL on init so footer links open the correct tab directly.
///          _onTabSelected also updates the URL so the browser back-button works.
/// FIXED:   OurProductsPage now accepts initialTab (String) constructor param so
///          Navigator.push() from the footer works without GoRouterState.
/// UPDATED: Tab bar redesigned to match Figma — selected tab = filled rounded pill,
///          unselected tab = plain text. Matches the circled design in the screenshot.
/// UPDATED: Each mockup section (image + text) is wrapped in a white container with
///          padding 16 and border radius 8, no border.
/// UPDATED: _DownloadNowBar now uses Spacer for desktop/tablet, Wrap for mobile.
/// UPDATED: "Request Demo" button moved from FAB to inline in the column,
///          placed just above the footer gap on Owner Services tab only.
/// UPDATED: Primary color is now gender-aware — uses malePrimaryColor when
///          GenderCubit reports male, primaryColor when female.

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:beauty_user/core/widgets/button.dart';
import 'package:beauty_user/core/widgets/navigator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/custom_tab.dart';
import '../../../../../core/main_widgets/app_page_shell.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_font_style.dart';
import '../../../../home/presentation/controller/gender_cubit.dart';
import '../../../../home/presentation/controller/gender_state.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../../request/presentation/ui/pages/request_page.dart';
import '../../../data/models/client_services_model.dart';
import '../../../data/models/owner_services_model.dart';
import '../../controller/client_services_cubit.dart';
import '../../controller/client_services_state.dart';
import '../../controller/owner_services_cubit.dart';
import '../../controller/owner_services_state.dart';

part '../widgets/our_products_page/reveal_coordinator.dart';
part '../widgets/our_products_page/reveal_coordinator_widget.dart';
part '../widgets/our_products_page/reveal.dart';
part '../widgets/our_products_page/svg_pulse_loader.dart';
part '../widgets/our_products_page/products_tab_bar.dart';
part '../widgets/our_products_page/client_service_tab.dart';
part '../widgets/our_products_page/owner_service_tab.dart';
part '../widgets/our_products_page/client_header_hero.dart';
part '../widgets/our_products_page/owner_header_hero.dart';
part '../widgets/our_products_page/client_mockup_section_widget.dart';
part '../widgets/our_products_page/owner_mockup_section_widget.dart';
part '../widgets/our_products_page/download_now_bar.dart';
part '../widgets/our_products_page/mini_store_badge.dart';
part '../widgets/our_products_page/center_layout.dart';
part '../widgets/our_products_page/side_by_side_layout.dart';
part '../widgets/our_products_page/stacked_fallback.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TEXT FORMATTING HELPER
// ══════════════════════════════════════════════════════════════════════════════

List<String> abbreviation = [
  "it",
  "hr",
  'utils ux',
  'log',
  'qa',
  'pr',
  'dev',
  'ceo',
  "grc",
  "mena",
  "ksa",
  "uae",
  "coo",
  "cfo",
  "cdo",
  "cso",
  "cbo",
  "cmo",
  "cto",
  "cno",
  "cco",
  "chro",
  "cxo",
];

abstract class FormatHelper {
  static String capitalize(String input) {
    String processedInput = input.toLowerCase();
    processedInput = applyAbbreviation(processedInput);
    if (processedInput.isEmpty) return "";
    List<String> words = processedInput.split(" ");
    words = words.map((word) {
      if (word.isNotEmpty) return word[0].toUpperCase() + word.substring(1);
      return "";
    }).toList();
    return words.join(" ");
  }

  static String applyAbbreviation(String input) {
    String result = input;
    for (String abbr in abbreviation) {
      RegExp regex = RegExp(r'\b' + abbr + r'\b', caseSensitive: false);
      if (regex.hasMatch(result)) {
        result = result.replaceAllMapped(regex, (match) => abbr.toUpperCase());
      }
    }
    return result;
  }
}

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

// ── Gender-aware primary color helper ────────────────────────────────────────
/// Returns malePrimaryColor when [isMale] is true, otherwise primaryColor.
Color _resolvePrimaryColor({
  required String primaryColorHex,
  required String malePrimaryColorHex,
  required bool isMale,
}) {
  final hex = isMale ? malePrimaryColorHex : primaryColorHex;
  return _parseHex(hex,
      fallback: isMale ? const Color(0xFF1565C0) : AppColors.primary);
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
  final header = String.fromCharCodes(
    b.sublist(0, b.length.clamp(0, 100)),
  ).trimLeft();
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

  final fitStr = fit == BoxFit.contain
      ? 'contain'
      : fit == BoxFit.scaleDown
      ? 'scale-down'
      : 'cover';

  final viewId =
      'svg-products-${url.hashCode}-${width?.toInt()}-${height?.toInt()}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fitStr;
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
      .where(
        (u) =>
    u.isNotEmpty &&
        (u.startsWith('http://') || u.startsWith('https://')),
  )
      .toSet();
  await Future.wait(
    valid.map(
          (url) =>
          _xhrLoad(url, isSvg: _isSvgUrl(url)).catchError((_) => Uint8List(0)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Reveal animation system
// ══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

class OurProductsPage extends StatefulWidget {
  final String initialTab;

  const OurProductsPage({super.key, this.initialTab = ''});

  @override
  State<OurProductsPage> createState() => _OurProductsPageState();
}

class _OurProductsPageState extends State<OurProductsPage> {
  int _selectedTabIndex = 0;

  bool _showLoader = true;
  bool _preloadStarted = false;
  int _lastPreloadedTab = -1;
  String _lastGender = '';

  @override
  void initState() {
    super.initState();

    final gender = context.read<GenderCubit>().current;
    _lastGender = gender;

    // ── Priority 1: constructor param (Navigator.push / no GoRouter) ────────
    if (widget.initialTab.isNotEmpty) {
      _selectedTabIndex = _tabIndexForParam(widget.initialTab);
    }

    // ── Load cubit for whichever tab is initially selected ───────────────────
    if (_selectedTabIndex == 0) {
      context.read<ClientServicesCubit>().load(gender: gender);
    } else {
      context.read<OwnerServicesCubit>().load(gender: gender);
    }

    // ── Priority 2: GoRouter query param (only if constructor was empty) ─────
    if (widget.initialTab.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final uri = GoRouterState.of(context).uri;
          final tab = uri.queryParameters['tab'] ?? '';
          final index = _tabIndexForParam(tab);

          if (index != _selectedTabIndex) {
            setState(() {
              _selectedTabIndex = index;
              _showLoader = true;
              _preloadStarted = false;
            });
            if (index == 1) {
              context.read<OwnerServicesCubit>().load(gender: _lastGender);
            } else {
              context.read<ClientServicesCubit>().load(gender: _lastGender);
            }
            Future.delayed(const Duration(seconds: 12), () {
              if (mounted && _showLoader) setState(() => _showLoader = false);
            });
          }
        } catch (_) {}
      });
    }

    // Hard-cap the loader at 12 s
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
  }

  void _onGenderChanged(String newGender) {
    if (newGender == _lastGender) return;
    _lastGender = newGender;
    _preloadStarted = false;
    setState(() => _showLoader = true);

    if (_selectedTabIndex == 0) {
      context.read<ClientServicesCubit>().switchGender(newGender);
    } else {
      context.read<OwnerServicesCubit>().switchGender(newGender);
    }
  }

  // ── Tab switch: updates content AND URL (only when inside GoRouter) ──────
  void _onTabSelected(int index) {
    if (_selectedTabIndex == index) return;

    try {
      context.go('/our-products?tab=${_tabParamForIndex(index)}');
    } catch (_) {}

    setState(() {
      _selectedTabIndex = index;
      _showLoader = true;
      _preloadStarted = false;
    });

    if (index == 0) {
      context.read<ClientServicesCubit>().load(gender: _lastGender);
    } else {
      context.read<OwnerServicesCubit>().load(gender: _lastGender);
    }

    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
  }

  bool _isActiveTabReady(
      ClientServicesState clientState,
      OwnerServicesState ownerState,
      ) {
    if (_selectedTabIndex == 0) {
      return clientState is ClientServicesLoaded ||
          clientState is ClientServicesSaved;
    } else {
      return ownerState is OwnerServicesLoaded ||
          ownerState is OwnerServicesSaved;
    }
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required ClientServicesPageModel? clientData,
    required OwnerServicesPageModel? ownerData,
  }) async {
    if (_preloadStarted && _lastPreloadedTab == _selectedTabIndex) return;
    _preloadStarted = true;
    _lastPreloadedTab = _selectedTabIndex;

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _showLoader = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GenderCubit, GenderState>(
      listener: (context, genderState) {
        _onGenderChanged(genderState.gender);
      },
      child: BlocBuilder<HomeCmsCubit, HomeCmsState>(
        builder: (context, homeState) {
          return BlocBuilder<ClientServicesCubit, ClientServicesState>(
            builder: (context, clientState) {
              return BlocBuilder<OwnerServicesCubit, OwnerServicesState>(
                builder: (context, ownerState) {
                  final homeData = switch (homeState) {
                    HomeCmsLoaded(:final data) => data,
                    HomeCmsSaved(:final data) => data,
                    HomeCmsSaving(:final data) => data,
                    HomeCmsError(:final lastData) => lastData,
                    _ => null,
                  };

                  final Color backgroundColor = homeData != null
                      ? _parseHex(
                    homeData.branding.backgroundColor,
                    fallback: AppColors.background,
                  )
                      : AppColors.background;

                  final String logoUrl = homeData?.branding.logoUrl ?? '';

                  if (homeData == null) {
                    return _SvgPulseLoader(
                      logoUrl: logoUrl.isEmpty ? null : logoUrl,
                      backgroundColor: AppColors.background,
                    );
                  }

                  if (!_isActiveTabReady(clientState, ownerState)) {
                    return _SvgPulseLoader(
                      logoUrl: logoUrl.isEmpty ? null : logoUrl,
                      backgroundColor: backgroundColor,
                    );
                  }

                  final ClientServicesPageModel? clientData =
                  switch (clientState) {
                    ClientServicesLoaded(:final data) => data,
                    ClientServicesSaved(:final data) => data,
                    _ => null,
                  };
                  final OwnerServicesPageModel? ownerData =
                  switch (ownerState) {
                    OwnerServicesLoaded(:final data) => data,
                    OwnerServicesSaved(:final data) => data,
                    _ => null,
                  };

                  if (!_preloadStarted ||
                      _lastPreloadedTab != _selectedTabIndex) {
                    _preloadAndReveal(
                      logoUrl: logoUrl,
                      clientData: clientData,
                      ownerData: ownerData,
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
                          var isMobile = context.isPhone;

                          return Directionality(
                            textDirection: isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Scaffold(
                              backgroundColor: Colors.transparent,

                              floatingActionButton: _selectedTabIndex == 1
                                  ? LayoutBuilder(
                                builder: (context, constraints) {
                                  final screenW = MediaQuery.of(context).size.width;
                                  final screenH = MediaQuery.of(context).size.height;
                                  final isMobile = screenW < 600;
                                  final isTablet = screenW >= 600 && screenW < 1024;

                                  final double btnWidth = isMobile
                                      ? screenW * 0.5
                                      : isTablet
                                      ? 180.w
                                      : 150.w;

                                  final double leftPad = isMobile
                                      ? screenW * 0.34
                                      : isTablet
                                      ? screenW * 0.7
                                      : screenW * 0.86;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: screenH * 0.28,
                                      left: leftPad,
                                    ),
                                    child: _Reveal(
                                      delay: const Duration(milliseconds: 200),
                                      direction: _SlideDirection.fromBottom,
                                      duration: const Duration(milliseconds: 650),
                                      child: customButton(
                                        title: isAr ? 'اطلب للتجربة' : 'Request Demo',
                                        function: () => navigateTo(context, RequestDemoPage()),
                                        textStyle: StyleText.fontSize16Weight500
                                            .copyWith(color: Colors.white),
                                        width: btnWidth,
                                        height: 48.h,
                                        radius: 8.r,
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              )
                                  : null,
                              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                              body: AppPageShell(
                                currentRoute: '/about',
                                body: _RevealCoordinatorWidget(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 24.h),

                                        // ── Tab bar ──────────────────────────────
                                        _Reveal(
                                          delay: const Duration(milliseconds: 60),
                                          direction: _SlideDirection.fromTop,
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          child: _ProductsTabBar(
                                            selectedIndex: _selectedTabIndex,
                                            primaryColor: primaryColor,
                                            isAr: isAr,
                                            onTabSelected: _onTabSelected,
                                          ),
                                        ),

                                        SizedBox(height: 30.h),

                                        // ── Active tab content ───────────────────
                                        if (_selectedTabIndex == 0)
                                          _ClientServiceTab(
                                            key: const ValueKey('client_tab'),
                                            primaryColor: primaryColor,
                                            isAr: isAr,
                                          )
                                        else
                                          _OwnerServiceTab(
                                            key: const ValueKey('owner_tab'),
                                            primaryColor: primaryColor,
                                            isAr: isAr,
                                          ),

                                        // ── bottom padding so button doesn't cover last item ──
                                        if (_selectedTabIndex == 1)
                                          SizedBox(height: 80.h),

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
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT SERVICE TAB
// ══════════════════════════════════════════════════════════════════════════════
