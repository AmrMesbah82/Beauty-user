// ******************* FILE INFO *******************
// File Name: contact_page.dart  (public-facing website page)
// Created by: Amr Mesbah
// UPDATED: Full redesign to match Figma — Client/Owner toggle,
//          illustration left panel, Personal Info + Salon Info sections,
//          pink selectable option cards, simplified success dialog.
//          PRIMARY COLOR: Fully dynamic from HomeCmsCubit branding.
//          OTP verification via Twilio before form submission.
//          SendGrid sends emails on submit.
//          Full AR / EN bilingual support with RTL/LTR.
//          All sizes normalized to match main.dart ScreenUtil design sizes:
//          Desktop (≥1366) → 1366×768, Tablet (768–1365) → 1024×768,
//          Mobile (<768)   → 375×812
//          UPDATED: Prefix SVG icons on all dropdowns (mobile + desktop)
//          UPDATED: Reason dropdown now populated from CMS data
//                   (clientDescription.reasons / ownerDescription.reasons)
//                   Description text from CMS clientDescription / ownerDescription
//          FIXED: cmsData was never assigned from cmsState — all CMS fields now render
//          FIXED: title, subtitle, SVG now read from Firebase, no static fallback shown
//                 unless Firebase field is empty

import 'dart:async';
import 'dart:html' as html;

import 'package:beauty_user/controller/home/lang_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui_web' as ui_web;
import 'package:beauty_user/controller/contact_us/contacu_us_location_cubit.dart';
import 'package:beauty_user/controller/contact_us/contacu_us_location_state.dart';
import 'package:beauty_user/controller/contact_us/contatc_us_cubit.dart';
import 'package:beauty_user/controller/contact_us/contatc_us_state.dart';

import 'package:beauty_user/core/widget/button.dart';
import 'package:beauty_user/core/widget/circle_progress.dart';
import 'package:beauty_user/core/widget/custom_dropdwon.dart';
import 'package:beauty_user/core/widget/textfield.dart';

import 'package:beauty_user/theme/appcolors.dart';
import 'package:beauty_user/theme/new_theme.dart';
import 'package:beauty_user/theme/text.dart';
import 'package:beauty_user/widgets/app_footer.dart';
import 'package:beauty_user/widgets/app_navbar.dart';

import 'package:beauty_user/controller/contact_us/contact_otp_cubit.dart';
import 'package:beauty_user/controller/contact_us/contact_otp_state.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../core/constant/constant.dart';
import '../core/custom_tab.dart';
import '../model/contact_us/contact_model_location.dart';
import '../model/contact_us/contact_us_model.dart';

const Color _kDefaultPink = Color(0xFFBE6A7A);
const Color _kLoaderNeutral = Color(0xFFF5F5F5);

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════

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
  final Duration delay;
  final Duration duration;
  final _SlideDirection direction;

  const _Reveal({
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
  _RevealCoordinatorState? _coordinator;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    final Offset begin = switch (widget.direction) {
      _SlideDirection.fromBottom => const Offset(0, 0.18),
      _SlideDirection.fromTop => const Offset(0, -0.18),
      _SlideDirection.fromLeft => const Offset(-0.18, 0),
      _SlideDirection.fromRight => const Offset(0.18, 0),
    };
    _slide = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: begin, end: Offset.zero));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        Future.delayed(widget.delay, () {
          if (mounted) _checkAndTrigger();
        });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        Future.delayed(widget.delay + const Duration(milliseconds: 120), () {
          if (mounted) _checkAndTrigger();
        });
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = _RevealCoordinator.of(context);
    _coordinator?.register(this);
  }

  @override
  void dispose() {
    _coordinator?.unregister(this);
    _ctrl.dispose();
    super.dispose();
  }

  void onScroll() => _checkAndTrigger();

  void _checkAndTrigger() {
    if (_triggered || !mounted) return;
    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) return;
      final pos = box.localToGlobal(Offset.zero);
      final screenH = MediaQuery.of(context).size.height;
      if (pos.dy < screenH - 40) {
        _triggered = true;
        _ctrl.forward();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

String _t(BuildContext context, {required String en, required String ar}) {
  final isAr = context.read<LanguageCubit>().state.isArabic;
  return (isAr && ar.isNotEmpty) ? ar : en;
}

const List<Map<String, String>> _phoneCodes = [
  {'key': '+20', 'value': '🇪🇬 +20'},
  {'key': '+234', 'value': '🇳🇬 +234'},
  {'key': '+212', 'value': '🇲🇦 +212'},
  {'key': '+213', 'value': '🇩🇿 +213'},
  {'key': '+216', 'value': '🇹🇳 +216'},
  {'key': '+249', 'value': '🇸🇩 +249'},
  {'key': '+251', 'value': '🇪🇹 +251'},
  {'key': '+254', 'value': '🇰🇪 +254'},
  {'key': '+27', 'value': '🇿🇦 +27'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+973', 'value': '🇧🇭 +973'},
  {'key': '+968', 'value': '🇴🇲 +968'},
  {'key': '+962', 'value': '🇯🇴 +962'},
  {'key': '+961', 'value': '🇱🇧 +961'},
  {'key': '+963', 'value': '🇸🇾 +963'},
  {'key': '+964', 'value': '🇮🇶 +964'},
  {'key': '+967', 'value': '🇾🇪 +967'},
  {'key': '+970', 'value': '🇵🇸 +970'},
  {'key': '+90', 'value': '🇹🇷 +90'},
  {'key': '+98', 'value': '🇮🇷 +98'},
  {'key': '+44', 'value': '🇬🇧 +44'},
  {'key': '+33', 'value': '🇫🇷 +33'},
  {'key': '+49', 'value': '🇩🇪 +49'},
  {'key': '+1', 'value': '🇺🇸 +1'},
  {'key': '+91', 'value': '🇮🇳 +91'},
  {'key': '+86', 'value': '🇨🇳 +86'},
  {'key': '+81', 'value': '🇯🇵 +81'},
  {'key': '+61', 'value': '🇦🇺 +61'},
  {'key': '+64', 'value': '🇳🇿 +64'},
];

List<Map<String, String>> _buildReasonItems({
  required ContactUsCmsModel? cmsData,
  required bool isOwner,
  required bool isRtl,
}) {
  final section = isOwner
      ? cmsData?.ownerDescription
      : cmsData?.clientDescription;
  final reasons = section?.reasons ?? [];

  if (reasons.isNotEmpty) {
    final items = reasons
        .where((r) => r.label.en.isNotEmpty || r.label.ar.isNotEmpty)
        .map(
          (r) => {
            'key': isRtl ? r.label.ar : r.label.en,
            'value': isRtl ? r.label.ar : r.label.en,
          },
        )
        .where((m) => m['key']!.isNotEmpty)
        .toList();
    if (items.isNotEmpty) return items;
  }

  return (isRtl
          ? ContactFormConstants.reasonsAr
          : ContactFormConstants.reasonsEn)
      .map((r) => {'key': r, 'value': r})
      .toList();
}

String _getCmsDescription({
  required ContactUsCmsModel? cmsData,
  required bool isOwner,
  required bool isRtl,
}) {
  final section = isOwner
      ? cmsData?.ownerDescription
      : cmsData?.clientDescription;
  final desc = section?.description;
  if (desc != null) {
    final text = isRtl ? desc.ar : desc.en;
    if (text.isNotEmpty) return text;
  }
  return '';
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PRELOADER
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadSvgImages(List<String> urls) async {
  final validUrls = urls
      .where(
        (url) =>
            url.isNotEmpty &&
            (url.startsWith('http://') || url.startsWith('https://')),
      )
      .toSet()
      .toList();

  await Future.wait(
    validUrls.map((url) async {
      try {
        final loader = SvgNetworkLoader(url);
        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        );
      } catch (_) {}
    }),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PULSE LOADER
// ═══════════════════════════════════════════════════════════════════════════════

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
    _opacity = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_SvgPulseLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != null &&
        widget.logoUrl!.isNotEmpty &&
        _resolvedUrl == null) {
      setState(() => _resolvedUrl = widget.logoUrl);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl == null) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const SizedBox.shrink(),
      );
    }

    final viewId = 'svg-contact-pulse-${_resolvedUrl.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final img = html.ImageElement()
        ..src = _resolvedUrl!
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';
      return img;
    });

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SizedBox(
            width: 88.w,
            height: 88.w,
            child: HtmlElementView(viewType: viewId),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE ENTRY
// ═══════════════════════════════════════════════════════════════════════════════

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🟣 [ContactPage] build() called');
    return MultiBlocProvider(
      providers: [
        BlocProvider<ContactUsCmsCubit>(
          create: (_) {
            print(
              '🟣 [ContactPage] Creating ContactUsCmsCubit and calling load()',
            );
            return ContactUsCmsCubit()..load();
          },
        ),
        BlocProvider(create: (_) => ContactCubit()),
        BlocProvider(create: (_) => ContactOtpCubit()),
      ],
      child: const _ContactPageView(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _ContactPageView extends StatefulWidget {
  const _ContactPageView();
  @override
  State<_ContactPageView> createState() => _ContactPageViewState();
}

class _ContactPageViewState extends State<_ContactPageView> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _salonNameCtrl = TextEditingController();
  final _salonNameArCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _userType = ContactFormConstants.userTypeClient;
  String _phoneCode = '+20';
  String _preferredLanguage = 'ar';
  String? _selectedTargetAudience;
  String? _selectedSalonCountry;
  String? _selectedSalonCity;
  String? _selectedNoBranches;
  String? _selectedServices;
  String? _selectedAtLocation;
  String? _selectedReason;

  bool _submitted = false;
  bool _showLoader = true;
  bool _preloadStarted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _showLoader) setState(() => _showLoader = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCmsCubit>().load();
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _salonNameCtrl.dispose();
    _salonNameArCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _preloadAndReveal({
    required String logoUrl,
    required ContactUsCmsModel? cmsData,
  }) async {
    if (_preloadStarted) return;
    _preloadStarted = true;
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _showLoader = false);
  }

  bool get _isOwner => _userType == ContactFormConstants.userTypeOwner;

  void _onSend() {
    setState(() => _submitted = true);

    final personalFilled = [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _subjectCtrl,
      _messageCtrl,
    ].every((c) => c.text.trim().isNotEmpty);

    if (!personalFilled || _selectedReason == null) return;

    if (_isOwner) {
      final salonFilled =
          _salonNameCtrl.text.trim().isNotEmpty &&
          _selectedTargetAudience != null &&
          _selectedSalonCountry != null &&
          _selectedNoBranches != null &&
          _selectedServices != null;
      if (!salonFilled) return;
    }

    String phoneNumber = _phoneCtrl.text.trim();
    if (phoneNumber.startsWith('0')) phoneNumber = phoneNumber.substring(1);

    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: '$_phoneCode$phoneNumber',
      locale: _preferredLanguage == 'ar' ? 'ar' : 'en',
    );
  }

  void _submitContactForm() {
    context.read<ContactCubit>().submitContact(
      ContactSubmission(
        id: '',
        userType: _userType,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        countryCode: _phoneCode,
        phoneNumber: _phoneCtrl.text.trim(),
        preferredLanguage: _preferredLanguage,
        salonNameEn: _salonNameCtrl.text.trim(),
        salonNameAr: _salonNameArCtrl.text.trim(),
        targetAudience: _selectedTargetAudience ?? '',
        salonCountry: _selectedSalonCountry ?? '',
        salonCity: _selectedSalonCity ?? '',
        noBranches: _selectedNoBranches ?? '',
        services: _selectedServices ?? '',
        atLocation: _selectedAtLocation ?? '',
        subject: _subjectCtrl.text.trim(),
        reason: _selectedReason ?? '',
        message: _messageCtrl.text.trim(),
        submissionDate: DateTime.now(),
      ),
    );
  }

  void _resetForm() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _salonNameCtrl.clear();
    _salonNameArCtrl.clear();
    _subjectCtrl.clear();
    _messageCtrl.clear();
    setState(() {
      _submitted = false;
      _userType = ContactFormConstants.userTypeClient;
      _preferredLanguage = 'ar';
      _selectedTargetAudience = null;
      _selectedSalonCountry = null;
      _selectedSalonCity = null;
      _selectedNoBranches = null;
      _selectedServices = null;
      _selectedAtLocation = null;
      _selectedReason = null;
    });
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
        final Color primaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.primaryColor,
            fallback: _kDefaultPink,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.primaryColor,
            fallback: _kDefaultPink,
          ),
          _ => _kDefaultPink,
        };
        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          _ => AppColors.background,
        };
        final Color loaderBg = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          HomeCmsSaved(:final data) => _parseColor(
            data.branding.backgroundColor,
            fallback: AppColors.background,
          ),
          _ => _kLoaderNeutral,
        };

        final bool homeReady =
            homeState is HomeCmsLoaded || homeState is HomeCmsSaved;

        if (homeState is HomeCmsError &&
            homeState.lastData == null &&
            _showLoader &&
            !_preloadStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showLoader = false);
          });
        }

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final isRtl = langState.isArabic;

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: MultiBlocListener(
                listeners: [
                  BlocListener<ContactOtpCubit, ContactOtpState>(
                    listener: (context, otpState) {
                      if (otpState is OtpSent) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ContactOtpCubit>(),
                            child: _OtpDialog(
                              phoneNumber: otpState.phoneNumber,
                              isRtl: isRtl,
                              primaryColor: primaryColor,
                              onVerified: () {
                                Navigator.of(context).pop();
                                _submitContactForm();
                              },
                            ),
                          ),
                        );
                      }
                      if (otpState is OtpError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('OTP Error: ${otpState.message}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                  BlocListener<ContactCubit, ContactState>(
                    listener: (context, state) {
                      if (state is ContactSubmitted) {
                        _resetForm();
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => _SuccessDialog(
                            isRtl: isRtl,
                            primaryColor: primaryColor,
                          ),
                        );
                      }
                      if (state is ContactError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.message}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
                  builder: (context, cmsState) {
                    final bool cmsReady =
                        cmsState is ContactUsCmsLoaded ||
                        cmsState is ContactUsCmsError;

                    // ── CRITICAL FIX: assign cmsData from state ──
                    ContactUsCmsModel? cmsData;
                    if (cmsState is ContactUsCmsLoaded) {
                      cmsData = cmsState.data;
                      print(
                        '🟢 [ContactPage] cmsData assigned → title.en=${cmsData.headings.title.en}',
                      );
                    }
                    if (cmsState is ContactUsCmsError) {
                      print('🔴 [ContactPage] CMS error → ${cmsState.message}');
                    }

                    if (homeReady && cmsReady && !_preloadStarted) {
                      _preloadAndReveal(logoUrl: logoUrl, cmsData: cmsData);
                    }

                    if (_showLoader || !cmsReady || !homeReady) {
                      return _SvgPulseLoader(
                        logoUrl: logoUrl.isEmpty ? null : logoUrl,
                        backgroundColor: loaderBg,
                      );
                    }

                    return BlocBuilder<ContactCubit, ContactState>(
                      builder: (context, contactState) {
                        final isSending = contactState is ContactSubmitting;
                        final isMobile =
                            MediaQuery.of(context).size.width < _BP.mobile;

                        return Scaffold(
                          backgroundColor: backgroundColor,
                          body: Stack(
                            children: [
                              _RevealCoordinatorWidget(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 80.h),
                                      _Reveal(
                                        delay: const Duration(milliseconds: 80),
                                        direction: _SlideDirection.fromLeft,
                                        duration: const Duration(
                                          milliseconds: 650,
                                        ),
                                        child: isMobile
                                            ? _MobileBody(
                                                firstNameCtrl: _firstNameCtrl,
                                                lastNameCtrl: _lastNameCtrl,
                                                emailCtrl: _emailCtrl,
                                                phoneCtrl: _phoneCtrl,
                                                salonNameCtrl: _salonNameCtrl,
                                                salonNameArCtrl:
                                                    _salonNameArCtrl,
                                                subjectCtrl: _subjectCtrl,
                                                messageCtrl: _messageCtrl,
                                                submitted: _submitted,
                                                userType: _userType,
                                                phoneCode: _phoneCode,
                                                preferredLanguage:
                                                    _preferredLanguage,
                                                selectedTargetAudience:
                                                    _selectedTargetAudience,
                                                selectedSalonCountry:
                                                    _selectedSalonCountry,
                                                selectedSalonCity:
                                                    _selectedSalonCity,
                                                selectedNoBranches:
                                                    _selectedNoBranches,
                                                selectedServices:
                                                    _selectedServices,
                                                selectedAtLocation:
                                                    _selectedAtLocation,
                                                selectedReason: _selectedReason,
                                                isRtl: isRtl,
                                                primaryColor: primaryColor,
                                                onUserTypeChanged: (v) =>
                                                    setState(() {
                                                      _userType = v;
                                                      _selectedReason = null;
                                                    }),
                                                onCodeChanged: (v) => setState(
                                                  () => _phoneCode =
                                                      v ?? _phoneCode,
                                                ),
                                                onLanguageChanged: (v) =>
                                                    setState(
                                                      () => _preferredLanguage =
                                                          v,
                                                    ),
                                                onTargetAudienceChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedTargetAudience =
                                                              v,
                                                    ),
                                                onSalonCountryChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedSalonCountry =
                                                              v,
                                                    ),
                                                onSalonCityChanged: (v) =>
                                                    setState(
                                                      () => _selectedSalonCity =
                                                          v,
                                                    ),
                                                onNoBranchesChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedNoBranches =
                                                              v,
                                                    ),
                                                onServicesChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedServices = v,
                                                    ),
                                                onAtLocationChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedAtLocation =
                                                              v,
                                                    ),
                                                onReasonChanged: (v) =>
                                                    setState(
                                                      () => _selectedReason = v,
                                                    ),
                                                onSend: _onSend,
                                                cmsData: cmsData,
                                              )
                                            : _DesktopBody(
                                                firstNameCtrl: _firstNameCtrl,
                                                lastNameCtrl: _lastNameCtrl,
                                                emailCtrl: _emailCtrl,
                                                phoneCtrl: _phoneCtrl,
                                                salonNameCtrl: _salonNameCtrl,
                                                salonNameArCtrl:
                                                    _salonNameArCtrl,
                                                subjectCtrl: _subjectCtrl,
                                                messageCtrl: _messageCtrl,
                                                submitted: _submitted,
                                                userType: _userType,
                                                phoneCode: _phoneCode,
                                                preferredLanguage:
                                                    _preferredLanguage,
                                                selectedTargetAudience:
                                                    _selectedTargetAudience,
                                                selectedSalonCountry:
                                                    _selectedSalonCountry,
                                                selectedSalonCity:
                                                    _selectedSalonCity,
                                                selectedNoBranches:
                                                    _selectedNoBranches,
                                                selectedServices:
                                                    _selectedServices,
                                                selectedAtLocation:
                                                    _selectedAtLocation,
                                                selectedReason: _selectedReason,
                                                isRtl: isRtl,
                                                primaryColor: primaryColor,
                                                onUserTypeChanged: (v) =>
                                                    setState(() {
                                                      _userType = v;
                                                      _selectedReason = null;
                                                    }),
                                                onCodeChanged: (v) => setState(
                                                  () => _phoneCode =
                                                      v ?? _phoneCode,
                                                ),
                                                onLanguageChanged: (v) =>
                                                    setState(
                                                      () => _preferredLanguage =
                                                          v,
                                                    ),
                                                onTargetAudienceChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedTargetAudience =
                                                              v,
                                                    ),
                                                onSalonCountryChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedSalonCountry =
                                                              v,
                                                    ),
                                                onSalonCityChanged: (v) =>
                                                    setState(
                                                      () => _selectedSalonCity =
                                                          v,
                                                    ),
                                                onNoBranchesChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedNoBranches =
                                                              v,
                                                    ),
                                                onServicesChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedServices = v,
                                                    ),
                                                onAtLocationChanged: (v) =>
                                                    setState(
                                                      () =>
                                                          _selectedAtLocation =
                                                              v,
                                                    ),
                                                onReasonChanged: (v) =>
                                                    setState(
                                                      () => _selectedReason = v,
                                                    ),
                                                onSend: _onSend,
                                                cmsData: cmsData,
                                              ),
                                      ),
                                      _Reveal(
                                        delay: const Duration(
                                          milliseconds: 120,
                                        ),
                                        direction: _SlideDirection.fromBottom,
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        child: _SocialMediaSection(
                                          cmsData: cmsData,
                                          primaryColor: primaryColor,
                                          isMobile: isMobile,
                                          isRtl: isRtl,
                                        ),
                                      ),
                                      _Reveal(
                                        delay: const Duration(
                                          milliseconds: 140,
                                        ),
                                        direction: _SlideDirection.fromBottom,
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        child: const AppFooter(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Material(
                                  color: backgroundColor,
                                  elevation: 0,
                                  child: AppNavbar(currentRoute: '/contactus'),
                                ),
                              ),
                              if (isSending)
                                Container(
                                  color: Colors.black45,
                                  child: Center(
                                    child: Container(
                                      width: isMobile ? double.infinity : 600.w,
                                      padding: EdgeInsets.all(24.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleProgressMaster(),
                                          SizedBox(height: 8.h),
                                          Text(
                                            isRtl
                                                ? 'جاري ارسال البيانات...'
                                                : 'Sending your information…',
                                            style:
                                                StyleText.fontSize13Weight400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OTP DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

class _OtpDialog extends StatefulWidget {
  final String phoneNumber;
  final bool isRtl;
  final Color primaryColor;
  final VoidCallback onVerified;
  const _OtpDialog({
    required this.phoneNumber,
    required this.isRtl,
    required this.primaryColor,
    required this.onVerified,
  });
  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final List<TextEditingController> _digitCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _hasError = false;
  int _countdown = 30;
  bool _canResend = false;
  StreamSubscription? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = 30;
      _canResend = false;
    });
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .take(30)
        .listen((_) {
          if (!mounted) return;
          setState(() {
            _countdown--;
            if (_countdown <= 0) _canResend = true;
          });
        });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digitCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _digitCtrls.map((c) => c.text).join();

  void _verifyOtp() {
    setState(() => _hasError = false);
    final code = _otpCode.trim();
    if (code.length < 6) return;
    context.read<ContactOtpCubit>().verifyOtp(
      phoneNumber: widget.phoneNumber,
      code: code,
    );
  }

  void _resendOtp() {
    for (final c in _digitCtrls) c.clear();
    setState(() => _hasError = false);
    _startTimer();
    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: widget.phoneNumber,
      locale: widget.isRtl ? 'ar' : 'en',
    );
  }

  void _onDigitChanged(String value, int index) {
    setState(() => _hasError = false);
    if (value.length == 1 && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.length == 1 && index == 5 && _otpCode.length == 6) _verifyOtp();
  }

  void _onDigitKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitCtrls[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')} Sec';

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;
    return Directionality(
      textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: BlocListener<ContactOtpCubit, ContactOtpState>(
        listener: (context, state) {
          if (state is OtpVerified) widget.onVerified();
          if (state is OtpError) setState(() => _hasError = true);
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 36.w,
            vertical: isMobile ? 40 : 36.h,
          ),
          child: SizedBox(
            width: isMobile ? double.infinity : 480.w,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32.w,
                vertical: isMobile ? 28 : 32.h,
              ),
              child: BlocBuilder<ContactOtpCubit, ContactOtpState>(
                builder: (context, state) {
                  final isVerifying = state is OtpVerifying;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/mobile_code_dialog.svg',
                        width: isMobile ? 120 : 140.w,
                        height: isMobile ? 100 : 120.h,
                      ),
                      SizedBox(height: isMobile ? 20 : 24.h),
                      Text(
                        widget.isRtl ? 'رمز التحقق' : 'VERIFICATION CODE',
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize22Weight700.copyWith(
                          fontSize: isMobile ? 18.0 : 20.sp,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 10.h),
                      Text(
                        widget.isRtl
                            ? 'لقد أرسلنا رمز التحقق إلى هاتفك لإتمام عملية التحقق'
                            : 'We have sent the OTP code to your Phone For the verification process',
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize13Weight400.copyWith(
                          fontSize: isMobile ? 12.0 : 13.sp,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24 : 28.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            final bool filled = _digitCtrls[i].text.isNotEmpty;
                            return Container(
                              width: isMobile ? 44 : 48.w,
                              height: isMobile ? 50 : 54.h,
                              margin: EdgeInsets.symmetric(
                                horizontal: isMobile ? 3 : 4.w,
                              ),
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (e) => _onDigitKey(i, e),
                                child: TextField(
                                  controller: _digitCtrls[i],
                                  focusNode: _focusNodes[i],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: StyleText.fontSize22Weight700.copyWith(
                                    fontSize: isMobile ? 18.0 : 20.sp,
                                    color: _hasError
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: _hasError
                                        ? Colors.red.withOpacity(0.05)
                                        : filled
                                        ? widget.primaryColor.withOpacity(0.05)
                                        : Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 12 : 14.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : filled
                                            ? widget.primaryColor
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : widget.primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) => _onDigitChanged(v, i),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: isMobile ? 14 : 16.h),
                      if (_hasError)
                        Padding(
                          padding: EdgeInsets.only(bottom: isMobile ? 8 : 10.h),
                          child: Text(
                            widget.isRtl
                                ? 'رمز غير صحيح، يرجى التحقق والمحاولة مرة أخرى'
                                : 'Incorrect code, please check and try again',
                            textAlign: TextAlign.center,
                            style: StyleText.fontSize12Weight400.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (!_canResend)
                        Text(
                          _formatTime(_countdown),
                          style: StyleText.fontSize13Weight400.copyWith(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      SizedBox(height: isMobile ? 18 : 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: isMobile ? 46 : 44.h,
                        child: ElevatedButton(
                          onPressed: _canResend
                              ? _resendOtp
                              : (isVerifying ? null : _verifyOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            disabledBackgroundColor: widget.primaryColor
                                .withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: _canResend
                              ? Text(
                                  widget.isRtl
                                      ? 'إعادة إرسال الرمز'
                                      : 'Resend Code',
                                  style: StyleText.fontSize16Weight600.copyWith(
                                    color: Colors.white,
                                  ),
                                )
                              : isVerifying
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.isRtl ? 'تحقق الآن' : 'Verify Now',
                                  style: StyleText.fontSize16Weight600.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUCCESS DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

class _SuccessDialog extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  const _SuccessDialog({required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 14 : 16.r),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 36.w,
          vertical: isMobile ? 56 : 36.h,
        ),
        child: SizedBox(
          width: isMobile ? double.infinity : 500.w,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 36.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isMobile ? 100 : 120.w,
                  height: isMobile ? 100 : 120.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: isMobile ? 50 : 60.w,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24.h),
                Text(
                  isRtl ? 'تم الإرسال بنجاح !' : 'Send Successfully !',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize22Weight700.copyWith(
                    fontSize: isMobile ? 18.0 : 22.sp,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 14.h),
                Text(
                  isRtl
                      ? 'تم إرسال طلبك بنجاح. شكراً لتواصلك معنا.'
                      : 'Your request was sent successfully. Thank you for contact with us.',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: isMobile ? 12.0 : 14.sp,
                    height: 1.7,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopBody extends StatelessWidget {
  final TextEditingController firstNameCtrl,
      lastNameCtrl,
      emailCtrl,
      phoneCtrl,
      salonNameCtrl,
      salonNameArCtrl,
      subjectCtrl,
      messageCtrl;
  final bool submitted, isRtl;
  final String userType, phoneCode, preferredLanguage;
  final String? selectedTargetAudience,
      selectedSalonCountry,
      selectedSalonCity,
      selectedNoBranches,
      selectedServices,
      selectedAtLocation,
      selectedReason;
  final Color primaryColor;
  final ValueChanged<String> onUserTypeChanged, onLanguageChanged;
  final ValueChanged<String?> onCodeChanged,
      onTargetAudienceChanged,
      onSalonCountryChanged,
      onSalonCityChanged,
      onNoBranchesChanged,
      onServicesChanged,
      onAtLocationChanged,
      onReasonChanged;
  final VoidCallback onSend;
  final ContactUsCmsModel? cmsData;

  const _DesktopBody({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.salonNameCtrl,
    required this.salonNameArCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.submitted,
    required this.userType,
    required this.phoneCode,
    required this.preferredLanguage,
    required this.selectedTargetAudience,
    required this.selectedSalonCountry,
    required this.selectedSalonCity,
    required this.selectedNoBranches,
    required this.selectedServices,
    required this.selectedAtLocation,
    required this.selectedReason,
    required this.isRtl,
    required this.primaryColor,
    required this.onUserTypeChanged,
    required this.onCodeChanged,
    required this.onLanguageChanged,
    required this.onTargetAudienceChanged,
    required this.onSalonCountryChanged,
    required this.onSalonCityChanged,
    required this.onNoBranchesChanged,
    required this.onServicesChanged,
    required this.onAtLocationChanged,
    required this.onReasonChanged,
    required this.onSend,
    this.cmsData,
  });

  bool get _isOwner => userType == ContactFormConstants.userTypeOwner;

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double contentW = 1000.w;
    final double hPad = ((screenW - contentW) / 2).clamp(16.0, double.infinity);

    // ── CMS-driven title & subtitle with fallback ──
    final String pageTitle = (cmsData?.headings.title.en.isNotEmpty == true)
        ? _t(
            context,
            en: cmsData!.headings.title.en,
            ar: cmsData!.headings.title.ar,
          )
        : _t(context, en: 'Contact Us', ar: 'تواصل معنا');

    final String pageSubtitle =
        (cmsData?.headings.shortDescription.en.isNotEmpty == true)
        ? _t(
            context,
            en: cmsData!.headings.shortDescription.en,
            ar: cmsData!.headings.shortDescription.ar,
          )
        : _t(
            context,
            en: 'Your Feedback Shapes Our Success: Join Us in Building a Better Experience!',
            ar: 'ملاحظاتك تشكل نجاحنا: انضم إلينا في بناء تجربة أفضل!',
          );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30.h),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _LeftIllustrationPanel(
                    isRtl: isRtl,
                    primaryColor: primaryColor,
                    cmsData: cmsData,
                    isOwner: _isOwner,
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pageTitle,
                                style: StyleText.fontSize45Weight600.copyWith(
                                  fontSize: 32.sp,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                pageSubtitle,
                                style: StyleText.fontSize16Weight600.copyWith(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      _FormCard(
                        firstNameCtrl: firstNameCtrl,
                        lastNameCtrl: lastNameCtrl,
                        emailCtrl: emailCtrl,
                        phoneCtrl: phoneCtrl,
                        salonNameCtrl: salonNameCtrl,
                        salonNameArCtrl: salonNameArCtrl,
                        subjectCtrl: subjectCtrl,
                        messageCtrl: messageCtrl,
                        submitted: submitted,
                        userType: userType,
                        phoneCode: phoneCode,
                        preferredLanguage: preferredLanguage,
                        selectedTargetAudience: selectedTargetAudience,
                        selectedSalonCountry: selectedSalonCountry,
                        selectedSalonCity: selectedSalonCity,
                        selectedNoBranches: selectedNoBranches,
                        selectedServices: selectedServices,
                        selectedAtLocation: selectedAtLocation,
                        selectedReason: selectedReason,
                        isRtl: isRtl,
                        primaryColor: primaryColor,
                        onUserTypeChanged: onUserTypeChanged,
                        onCodeChanged: onCodeChanged,
                        onLanguageChanged: onLanguageChanged,
                        onTargetAudienceChanged: onTargetAudienceChanged,
                        onSalonCountryChanged: onSalonCountryChanged,
                        onSalonCityChanged: onSalonCityChanged,
                        onNoBranchesChanged: onNoBranchesChanged,
                        onServicesChanged: onServicesChanged,
                        onAtLocationChanged: onAtLocationChanged,
                        onReasonChanged: onReasonChanged,
                        onSend: onSend,
                        cmsData: cmsData,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _FormCard extends StatelessWidget {
  final TextEditingController firstNameCtrl,
      lastNameCtrl,
      emailCtrl,
      phoneCtrl,
      salonNameCtrl,
      salonNameArCtrl,
      subjectCtrl,
      messageCtrl;
  final bool submitted, isMobile, isRtl;
  final String userType, phoneCode, preferredLanguage;
  final String? selectedTargetAudience,
      selectedSalonCountry,
      selectedSalonCity,
      selectedNoBranches,
      selectedServices,
      selectedAtLocation,
      selectedReason;
  final Color primaryColor;
  final ValueChanged<String> onUserTypeChanged, onLanguageChanged;
  final ValueChanged<String?> onCodeChanged,
      onTargetAudienceChanged,
      onSalonCountryChanged,
      onSalonCityChanged,
      onNoBranchesChanged,
      onServicesChanged,
      onAtLocationChanged,
      onReasonChanged;
  final VoidCallback onSend;
  final ContactUsCmsModel? cmsData;

  const _FormCard({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.salonNameCtrl,
    required this.salonNameArCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.submitted,
    required this.userType,
    required this.phoneCode,
    required this.preferredLanguage,
    required this.selectedTargetAudience,
    required this.selectedSalonCountry,
    required this.selectedSalonCity,
    required this.selectedNoBranches,
    required this.selectedServices,
    required this.selectedAtLocation,
    required this.selectedReason,
    required this.isRtl,
    required this.primaryColor,
    required this.onUserTypeChanged,
    required this.onCodeChanged,
    required this.onLanguageChanged,
    required this.onTargetAudienceChanged,
    required this.onSalonCountryChanged,
    required this.onSalonCityChanged,
    required this.onNoBranchesChanged,
    required this.onServicesChanged,
    required this.onAtLocationChanged,
    required this.onReasonChanged,
    required this.onSend,
    this.isMobile = false,
    this.cmsData,
  });

  bool get _isOwner => userType == ContactFormConstants.userTypeOwner;

  @override
  Widget build(BuildContext context) {
    final TextDirection dir = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final TextAlign align = isRtl ? TextAlign.right : TextAlign.left;

    final String clientLabel = _t(context, en: 'Client', ar: 'عميل');
    final String ownerLabel = _t(context, en: 'Owner', ar: 'مالك');
    final String personalInfo = _t(
      context,
      en: 'Personal Info',
      ar: 'المعلومات الشخصية',
    );
    final String salonInfo = _t(
      context,
      en: 'Salon Info',
      ar: 'معلومات الصالون',
    );
    final String prefLangLabel = _t(
      context,
      en: 'Preferred Language',
      ar: 'اللغة المفضلة',
    );
    final String firstNameLabel = _t(
      context,
      en: 'First Name',
      ar: 'الاسم الأول',
    );
    final String lastNameLabel = _t(
      context,
      en: 'Last Name',
      ar: 'اسم العائلة',
    );
    final String emailLabel = _t(
      context,
      en: 'Enter Your Email',
      ar: 'أدخل بريدك الإلكتروني',
    );
    final String phoneLabel = _t(context, en: 'Phone Number', ar: 'رقم الهاتف');
    final String salonNameLabel = _t(
      context,
      en: 'Salon Name',
      ar: 'اسم الصالون',
    );
    final String salonNameArLabel = _t(
      context,
      en: 'اسم الصالون',
      ar: 'اسم الصالون',
    );
    final String targetLabel = _t(
      context,
      en: 'Target audience of salon',
      ar: 'الجمهور المستهدف للصالون',
    );
    final String countryLabel = _t(
      context,
      en: 'Country of salon',
      ar: 'دولة الصالون',
    );
    final String cityLabel = _t(
      context,
      en: 'City of salon',
      ar: 'مدينة الصالون',
    );
    final String branchesLabel = _t(
      context,
      en: 'No.Branches',
      ar: 'عدد الفروع',
    );
    final String servicesLabel = _t(context, en: 'Services', ar: 'الخدمات');
    final String subjectLabel = _t(context, en: 'Subject', ar: 'الموضوع');
    final String reasonLabel = _t(context, en: 'Reason', ar: 'السبب');
    final String msgLabel = _t(context, en: 'Message', ar: 'الرسالة');
    final String hint = _t(context, en: 'Text Here', ar: 'اكتب هنا');
    final String sendLabel = _t(context, en: 'SEND', ar: 'إرسال');
    final String selectHint = _t(context, en: 'Select', ar: 'اختر');

    final langLabels = isRtl
        ? ContactFormConstants.preferredLanguageLabelsAr
        : ContactFormConstants.preferredLanguageLabelsEn;

    final targetItems =
        (isRtl
                ? ContactFormConstants.targetAudienceAr
                : ContactFormConstants.targetAudienceEn)
            .map((t) => {'key': t, 'value': t})
            .toList();
    final countryItems =
        (isRtl
                ? ContactFormConstants.countriesAr
                : ContactFormConstants.countriesEn)
            .map((c) => {'key': c, 'value': c})
            .toList();
    final branchItems =
        (isRtl
                ? ContactFormConstants.noBranchesAr
                : ContactFormConstants.noBranchesEn)
            .map((b) => {'key': b, 'value': b})
            .toList();
    final serviceItems =
        (isRtl
                ? ContactFormConstants.servicesAr
                : ContactFormConstants.servicesEn)
            .map((s) => {'key': s, 'value': s})
            .toList();
    final reasonItems = _buildReasonItems(
      cmsData: cmsData,
      isOwner: _isOwner,
      isRtl: isRtl,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── CLIENT / OWNER TOGGLE ──
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isMobile)
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: CustomSegmentedTabs(
                    tabs: [clientLabel, ownerLabel],
                    tabIcons: const [
                      'assets/beauty/contact_us/client.svg',
                      'assets/beauty/contact_us/owner.svg',
                    ],
                    selectedIndex:
                        userType == ContactFormConstants.userTypeClient ? 0 : 1,
                    onTabSelected: (i) => onUserTypeChanged(
                      i == 0
                          ? ContactFormConstants.userTypeClient
                          : ContactFormConstants.userTypeOwner,
                    ),
                    selectedColor: primaryColor,
                    unselectedColor: Colors.transparent,
                    selectedTextColor: Colors.white,
                    unselectedTextColor: Colors.grey.shade500,
                    containerColor: Colors.white,
                    equalWidth: true,
                    spacing: 6.w,
                    iconSize: 14.sp,
                    iconSpacing: 4.w,
                    tabHorizontalPadding: 12.w,
                    tabVerticalPadding: 8.h,
                    borderRadius: 8.r,
                    containerPadding: EdgeInsets.all(3.r),
                  ),
                ),
              )
            else
              SizedBox(
                width: 300.w,
                height: 36.h,
                child: CustomSegmentedTabs(
                  tabs: [clientLabel, ownerLabel],
                  tabIcons: const [
                    'assets/beauty/contact_us/client.svg',
                    'assets/beauty/contact_us/owner.svg',
                  ],
                  selectedIndex: userType == ContactFormConstants.userTypeClient
                      ? 0
                      : 1,
                  onTabSelected: (i) => onUserTypeChanged(
                    i == 0
                        ? ContactFormConstants.userTypeClient
                        : ContactFormConstants.userTypeOwner,
                  ),
                  selectedColor: primaryColor,
                  unselectedColor: Colors.transparent,
                  selectedTextColor: Colors.white,
                  unselectedTextColor: Colors.grey.shade500,
                  containerColor: Colors.white,
                  equalWidth: true,
                  spacing: 8.w,
                  iconSize: 16.sp,
                  iconSpacing: 6.w,
                  tabHorizontalPadding: 16.w,
                  tabVerticalPadding: 8.h,
                  borderRadius: 8.r,
                  containerPadding: EdgeInsets.all(3.r),
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 16.h : 85.h),

        // ── FORM CARD ──
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14.w : 20.w,
            vertical: isMobile ? 14.h : 16.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SectionHeader(title: personalInfo, primaryColor: primaryColor),
              SizedBox(height: 8.h),
              _FormLabel(label: prefLangLabel),
              SizedBox(height: 6.h),
              Row(
                children: ContactFormConstants.preferredLanguages.map((lang) {
                  final bool selected = preferredLanguage == lang;
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: isMobile ? 16.w : 20.w,
                    ),
                    child: GestureDetector(
                      onTap: () => onLanguageChanged(lang),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? primaryColor
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 10.w,
                                        height: 10.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              langLabels[lang] ?? lang,
                              style: StyleText.fontSize13Weight400.copyWith(
                                color: selected
                                    ? Colors.black87
                                    : Colors.black54,
                                fontSize: isMobile ? 12.sp : 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: isMobile ? 10.h : 12.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DesktopIconField(
                      label: firstNameLabel,
                      hint: hint,
                      controller: firstNameCtrl,
                      iconPath: 'assets/contact/name.svg',
                      submitted: submitted,
                      primaryColor: primaryColor,
                      textDirection: dir,
                      textAlign: align,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8.w : 12.w),
                  Expanded(
                    child: _DesktopIconField(
                      label: lastNameLabel,
                      hint: hint,
                      controller: lastNameCtrl,
                      iconPath: 'assets/contact/name.svg',
                      submitted: submitted,
                      primaryColor: primaryColor,
                      textDirection: dir,
                      textAlign: align,
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DesktopIconField(
                      label: emailLabel,
                      hint: _t(
                        context,
                        en: 'Enter your email',
                        ar: 'أدخل بريدك الإلكتروني',
                      ),
                      controller: emailCtrl,
                      iconPath: 'assets/contact/sms.svg',
                      submitted: submitted,
                      primaryColor: primaryColor,
                      textDirection: dir,
                      textAlign: align,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8.w : 12.w),
                  Expanded(
                    child: _PhoneField(
                      label: phoneLabel,
                      controller: phoneCtrl,
                      submitted: submitted,
                      isMobile: isMobile,
                      selectedCode: phoneCode,
                      onCodeChanged: onCodeChanged,
                      isRtl: isRtl,
                      primaryColor: primaryColor,
                    ),
                  ),
                ],
              ),

              if (_isOwner) ...[
                SizedBox(height: isMobile ? 12.h : 16.h),
                _SectionHeader(title: salonInfo, primaryColor: primaryColor),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DesktopIconField(
                        label: salonNameLabel,
                        hint: hint,
                        controller: salonNameCtrl,
                        iconPath: 'assets/contact/salon_name.svg',
                        submitted: submitted,
                        primaryColor: primaryColor,
                        textDirection: dir,
                        textAlign: align,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8.w : 12.w),
                    Expanded(
                      child: _DesktopIconField(
                        label: salonNameArLabel,
                        hint: "آكتب هنا",
                        controller: salonNameArCtrl,
                        iconPath: 'assets/contact/salon_name.svg',
                        submitted: false,
                        primaryColor: primaryColor,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                _DropdownField(
                  label: targetLabel,
                  hint: selectHint,
                  value: selectedTargetAudience,
                  items: targetItems,
                  onChanged: onTargetAudienceChanged,
                  submitted: submitted,
                  isRtl: isRtl,
                  isMobile: isMobile,
                  primaryColor: primaryColor,
                  iconPath: 'assets/contact/Target audience of salon .svg',
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: countryLabel,
                        hint: selectHint,
                        value: selectedSalonCountry,
                        items: countryItems,
                        onChanged: onSalonCountryChanged,
                        submitted: submitted,
                        isRtl: isRtl,
                        isMobile: isMobile,
                        primaryColor: primaryColor,
                        iconPath: 'assets/contact/Country of salon.svg',
                        isSearchable: true,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8.w : 12.w),
                    Expanded(
                      child: _DesktopIconField(
                        label: cityLabel,
                        hint: hint,
                        controller: TextEditingController(
                          text: selectedSalonCity ?? '',
                        ),
                        iconPath: 'assets/contact/City of salon.svg',
                        submitted: false,
                        primaryColor: primaryColor,
                        textDirection: dir,
                        textAlign: align,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: branchesLabel,
                        hint: selectHint,
                        value: selectedNoBranches,
                        items: branchItems,
                        onChanged: onNoBranchesChanged,
                        submitted: submitted,
                        isRtl: isRtl,
                        isMobile: isMobile,
                        primaryColor: primaryColor,
                        iconPath: 'assets/contact/No.Branches.svg',
                      ),
                    ),
                    SizedBox(width: isMobile ? 8.w : 12.w),
                    Expanded(
                      child: _DropdownField(
                        label: servicesLabel,
                        hint: selectHint,
                        value: selectedServices,
                        items: serviceItems,
                        onChanged: onServicesChanged,
                        submitted: submitted,
                        isRtl: isRtl,
                        isMobile: isMobile,
                        primaryColor: primaryColor,
                        iconPath: 'assets/contact/Services.svg',
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: _isOwner ? 8.h : 4.h),
              _DesktopIconField(
                label: subjectLabel,
                hint: hint,
                controller: subjectCtrl,
                iconPath: 'assets/contact/Subject .svg',
                submitted: submitted,
                primaryColor: primaryColor,
                textDirection: dir,
                textAlign: align,
                minLength: 5,
              ),
              _DropdownField(
                label: reasonLabel,
                hint: selectHint,
                value: selectedReason,

                items: reasonItems,
                onChanged: onReasonChanged,
                submitted: submitted,
                isRtl: isRtl,
                isMobile: isMobile,
                primaryColor: primaryColor,
                iconPath: 'assets/contact/Reason.svg',
              ),
              _DesktopIconField(
                label: msgLabel,
                hint: hint,
                controller: messageCtrl,
                iconPath: 'assets/contact/Message.svg',
                submitted: submitted,
                primaryColor: primaryColor,
                textDirection: dir,
                textAlign: align,
                maxLines: 3,
                fieldHeight: 72,
                minLength: 10,
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: isMobile ? 42.h : 38.h,
                child: ElevatedButton(
                  onPressed: onSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    sendLabel,
                    style: StyleText.fontSize16Weight600.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP ICON FIELD
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopIconField extends StatefulWidget {
  final String label, hint, iconPath;
  final TextEditingController controller;
  final bool submitted;
  final Color primaryColor;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final int maxLines, minLength;
  final double fieldHeight;
  final bool onlyDigits;
  final bool forceRtlLabelAndHint; // NEW: forces RTL for label & hint

  const _DesktopIconField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.iconPath,
    required this.submitted,
    required this.primaryColor,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.fieldHeight = 32,
    this.minLength = 0,
    this.onlyDigits = false,
    this.forceRtlLabelAndHint = false, // Set to true for Arabic fields
  });

  @override
  State<_DesktopIconField> createState() => _DesktopIconFieldState();
}

class _DesktopIconFieldState extends State<_DesktopIconField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.controller.text.trim().isEmpty;
    final bool isTooShort =
        !isEmpty &&
        widget.minLength > 0 &&
        widget.controller.text.trim().length < widget.minLength;
    final bool showError = widget.submitted && (isEmpty || isTooShort);
    final bool isRtl = widget.textDirection == TextDirection.rtl;

    // NEW: Determine if label & hint should be RTL
    final bool useRtlForLabelHint = widget.forceRtlLabelAndHint || isRtl;

    final String errMsg = isEmpty
        ? (useRtlForLabelHint ? 'هذا الحقل مطلوب' : 'This field is required')
        : (useRtlForLabelHint
              ? 'الحد الأدنى ${widget.minLength} حرف'
              : 'Minimum ${widget.minLength} characters');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with RTL support
        Container(
          width: double.infinity,
          child: Text(
            widget.label,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
              fontSize: 14.sp,
            ),
            textAlign: useRtlForLabelHint ? TextAlign.right : TextAlign.left,
            textDirection: useRtlForLabelHint
                ? TextDirection.rtl
                : TextDirection.ltr,
          ),
        ),
        // Height 4 between title and textfield
        SizedBox(height: 4.h),

        // TextField container
        Container(
          height: widget.fieldHeight.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4.r),
            border: showError
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: widget.maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: useRtlForLabelHint ? 10.w : 10,
                  right: useRtlForLabelHint ? 10 : 10.w,
                  top: widget.maxLines > 1 ? 10.h : 0,
                ),
                child: SvgPicture.asset(
                  widget.iconPath,
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    showError ? Colors.red.shade300 : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  textDirection: useRtlForLabelHint
                      ? TextDirection.rtl
                      : widget.textDirection,
                  textAlign: useRtlForLabelHint
                      ? TextAlign.right
                      : widget.textAlign,
                  keyboardType: widget.onlyDigits
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: widget.onlyDigits
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  cursorColor: widget.primaryColor,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color: Colors.black87,
                    fontSize: 13.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryBlack,
                      fontSize: 12.sp,
                    ),
                    hintTextDirection: useRtlForLabelHint
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: widget.maxLines > 1 ? 10.h : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (showError) ...[
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.only(
              left: useRtlForLabelHint ? 0 : 4.w,
              right: useRtlForLabelHint ? 4.w : 0,
            ),
            child: Text(
              errMsg,
              style: StyleText.fontSize12Weight400.copyWith(
                color: Colors.red,
                fontSize: 11.sp,
              ),
              textAlign: useRtlForLabelHint ? TextAlign.right : TextAlign.left,
              textDirection: useRtlForLabelHint
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ],

        // Height 8 between textfield section and next field
        SizedBox(height: 8.h),
      ],
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════════
// DROPDOWN FIELD
// ═══════════════════════════════════════════════════════════════════════════════

class _DropdownField extends StatelessWidget {
  final String label, hint;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool submitted, isRtl, isMobile, isSearchable;
  final Color primaryColor;
  final String? iconPath;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.submitted,
    required this.isRtl,
    required this.isMobile,
    required this.primaryColor,
    this.isSearchable = false,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && (value == null || value!.isEmpty);
    final String requiredMsg = _t(
      context,
      en: 'This field is required',
      ar: 'هذا الحقل مطلوب',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label: label),
        SizedBox(height: 3.h),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items: items,
          onChanged: onChanged,
          width: double.infinity,
          height: 32,
          dropdownColor: Color(0xFFF5F5F5),
          borderRadius: 4,
          widthIcon: 16,
          heightIcon: 16,
          iconPath: iconPath,
          primaryColor: primaryColor,
          hint: Text(
            hint,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryBlack,
            ),
          ),
        ),
        if (showError) ...[
          SizedBox(height: 2.h),
          Text(
            requiredMsg,
            style: StyleText.fontSize12Weight400.copyWith(
              color: Colors.red,
              fontSize: 11.sp,
            ),
          ),
        ],
        SizedBox(height: 2.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PHONE FIELD
// ═══════════════════════════════════════════════════════════════════════════════

class _PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final bool submitted, isMobile, isRtl;
  final String selectedCode, label;
  final ValueChanged<String?> onCodeChanged;
  final Color primaryColor;

  const _PhoneField({
    required this.controller,
    required this.submitted,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.isRtl,
    required this.label,
    required this.primaryColor,
    this.isMobile = false,
  });

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.controller.text.trim().isEmpty;
    final bool showError = widget.submitted && isEmpty;
    final String errMsg = widget.isRtl
        ? 'هذا الحقل مطلوب'
        : 'This field is required';
    final String hintText = widget.isRtl
        ? 'أدخل رقم هاتفك'
        : 'Enter your number';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 3.h),
        Container(
          height: 32.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4.r),
            border: showError
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                height: 32.h,
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    end: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: CustomDropdownFormFieldInvMaster(
                  selectedValue: widget.selectedCode,
                  items: _phoneCodes,
                  onChanged: widget.onCodeChanged,
                  widthIcon: 16,
                  heightIcon: 16,
                  dropdownColor: Color(0xFFF5F5F5),
                  width: widget.isMobile ? 100.w : 110.w,
                  height: 32,
                  borderRadius: 0,
                  primaryColor: widget.primaryColor,
                  hint: Text(
                    hintText,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryBlack,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textDirection: widget.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
                  cursorColor: widget.primaryColor,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color: Colors.black87,
                    fontSize: 13.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryBlack,
                      fontSize: 12.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError) ...[
          SizedBox(height: 2.h),
          Text(
            errMsg,
            style: StyleText.fontSize12Weight400.copyWith(
              color: Colors.red,
              fontSize: 11.sp,
            ),
          ),
        ],
        SizedBox(height: 2.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER / FORM LABEL
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primaryColor;
  const _SectionHeader({required this.title, required this.primaryColor});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: StyleText.fontSize16Weight600.copyWith(
      color: primaryColor,
      fontSize: 14.sp,
    ),
  );
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: StyleText.fontSize14Weight400.copyWith(
      color: AppColors.text,
      fontSize: 14.sp,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEFT ILLUSTRATION PANEL — fully CMS-driven, no static text
// ═══════════════════════════════════════════════════════════════════════════════

class _LeftIllustrationPanel extends StatelessWidget {
  final bool isRtl;
  final Color primaryColor;
  final ContactUsCmsModel? cmsData;
  final bool isOwner;
  const _LeftIllustrationPanel({
    required this.isRtl,
    required this.primaryColor,
    this.cmsData,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final String cmsDesc = _getCmsDescription(
      cmsData: cmsData,
      isOwner: isOwner,
      isRtl: isRtl,
    );
    final String svgUrl = cmsData?.headings.svgUrl ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── CMS SVG illustration ──
        Center(
          child: svgUrl.isNotEmpty
              ? () {
            final viewId = 'svg-contact-illust-${svgUrl.hashCode}';
            ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
              final img = html.ImageElement()
                ..src = svgUrl
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.objectFit = 'contain';
              return img;
            });
            return SizedBox(
              width: 220.w,
              height: 200.h,
              child: HtmlElementView(viewType: viewId),
            );
          }()
              : SvgPicture.asset(
            'assets/spa_core.svg',
            width: 220.w,
            height: 200.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 24.h),
        // ── CMS description ──
        if (cmsDesc.isNotEmpty)
          Text(
            cmsDesc,
            style: StyleText.fontSize13Weight400.copyWith(
              fontSize: 12.sp,
              color: Colors.black87,
              height: 1.7,
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY — fully CMS-driven
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileBody extends StatelessWidget {
  final TextEditingController firstNameCtrl,
      lastNameCtrl,
      emailCtrl,
      phoneCtrl,
      salonNameCtrl,
      salonNameArCtrl,
      subjectCtrl,
      messageCtrl;
  final bool submitted, isRtl;
  final String userType, phoneCode, preferredLanguage;
  final String? selectedTargetAudience,
      selectedSalonCountry,
      selectedSalonCity,
      selectedNoBranches,
      selectedServices,
      selectedAtLocation,
      selectedReason;
  final Color primaryColor;
  final ValueChanged<String> onUserTypeChanged, onLanguageChanged;
  final ValueChanged<String?> onCodeChanged,
      onTargetAudienceChanged,
      onSalonCountryChanged,
      onSalonCityChanged,
      onNoBranchesChanged,
      onServicesChanged,
      onAtLocationChanged,
      onReasonChanged;
  final VoidCallback onSend;
  final ContactUsCmsModel? cmsData;

  const _MobileBody({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.salonNameCtrl,
    required this.salonNameArCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.submitted,
    required this.userType,
    required this.phoneCode,
    required this.preferredLanguage,
    required this.selectedTargetAudience,
    required this.selectedSalonCountry,
    required this.selectedSalonCity,
    required this.selectedNoBranches,
    required this.selectedServices,
    required this.selectedAtLocation,
    required this.selectedReason,
    required this.isRtl,
    required this.primaryColor,
    required this.onUserTypeChanged,
    required this.onCodeChanged,
    required this.onLanguageChanged,
    required this.onTargetAudienceChanged,
    required this.onSalonCountryChanged,
    required this.onSalonCityChanged,
    required this.onNoBranchesChanged,
    required this.onServicesChanged,
    required this.onAtLocationChanged,
    required this.onReasonChanged,
    required this.onSend,
    this.cmsData,
  });

  bool get _isOwner => userType == ContactFormConstants.userTypeOwner;

  @override
  Widget build(BuildContext context) {
    // ── CMS-driven title & subtitle ──
    final String pageTitle = (cmsData?.headings.title.en.isNotEmpty == true)
        ? _t(
            context,
            en: cmsData!.headings.title.en,
            ar: cmsData!.headings.title.ar,
          )
        : _t(context, en: 'Contact Us', ar: 'تواصل معنا');

    final String pageSubtitle =
        (cmsData?.headings.shortDescription.en.isNotEmpty == true)
        ? _t(
            context,
            en: cmsData!.headings.shortDescription.en,
            ar: cmsData!.headings.shortDescription.ar,
          )
        : _t(
            context,
            en: 'Your Feedback Shapes Our Success: Join Us in Building a Better Experience!',
            ar: 'ملاحظاتك تشكل نجاحنا: انضم إلينا في بناء تجربة أفضل!',
          );

    final String svgUrl = cmsData?.headings.svgUrl ?? '';
    final String clientLabel = _t(context, en: 'Client', ar: 'عميل');
    final String ownerLabel = _t(context, en: 'Owner', ar: 'مالك');
    final String sendLabel = _t(context, en: 'SEND', ar: 'إرسال');
    final String prefLangLabel = _t(
      context,
      en: 'Preferred Language',
      ar: 'اللغة المفضلة',
    );
    final String selectHint = _t(context, en: 'Select', ar: 'اختر');
    final TextDirection dir = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final TextAlign align = isRtl ? TextAlign.right : TextAlign.left;

    final langLabels = isRtl
        ? ContactFormConstants.preferredLanguageLabelsAr
        : ContactFormConstants.preferredLanguageLabelsEn;
    final targetItems =
        (isRtl
                ? ContactFormConstants.targetAudienceAr
                : ContactFormConstants.targetAudienceEn)
            .map((t) => {'key': t, 'value': t})
            .toList();
    final countryItems =
        (isRtl
                ? ContactFormConstants.countriesAr
                : ContactFormConstants.countriesEn)
            .map((c) => {'key': c, 'value': c})
            .toList();
    final branchItems =
        (isRtl
                ? ContactFormConstants.noBranchesAr
                : ContactFormConstants.noBranchesEn)
            .map((b) => {'key': b, 'value': b})
            .toList();
    final serviceItems =
        (isRtl
                ? ContactFormConstants.servicesAr
                : ContactFormConstants.servicesEn)
            .map((s) => {'key': s, 'value': s})
            .toList();
    final reasonItems = _buildReasonItems(
      cmsData: cmsData,
      isOwner: _isOwner,
      isRtl: isRtl,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            pageTitle,
            style: StyleText.fontSize45Weight600.copyWith(
              fontSize: 24.sp,
              color: primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            pageSubtitle,
            style: StyleText.fontSize13Weight400.copyWith(
              fontSize: 12.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),

          // ── CMS SVG illustration ──
          Center(
            child: svgUrl.isNotEmpty
                ? () {
              final viewId = 'svg-contact-mobile-illust-${svgUrl.hashCode}';
              ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
                final img = html.ImageElement()
                  ..src = svgUrl
                  ..style.width = '100%'
                  ..style.height = '100%'
                  ..style.objectFit = 'contain';
                return img;
              });
              return SizedBox(
                width: double.infinity,
                height: 220.h,
                child: HtmlElementView(viewType: viewId),
              );
            }()
                : SvgPicture.asset(
              'assets/spa_core.svg',
              width: double.infinity,
              height: 220.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 20.h),

          _MobileToggle(
            userType: userType,
            primaryColor: primaryColor,
            clientLabel: clientLabel,
            ownerLabel: ownerLabel,
            onChanged: onUserTypeChanged,
          ),
          SizedBox(height: 20.h),

          _MobileDescriptionText(
            isRtl: isRtl,
            cmsData: cmsData,
            isOwner: _isOwner,
          ),
          SizedBox(height: 16.h),

          // ── White Form Card ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prefLangLabel,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: 13.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: ContactFormConstants.preferredLanguages.map((lang) {
                    final bool selected = preferredLanguage == lang;
                    return Padding(
                      padding: EdgeInsetsDirectional.only(end: 20.w),
                      child: GestureDetector(
                        onTap: () => onLanguageChanged(lang),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16.w,
                              height: 16.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? primaryColor
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 9.w,
                                        height: 9.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              langLabels[lang] ?? lang,
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: selected
                                    ? Colors.black87
                                    : Colors.black54,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10.h),

                _MobileIconField(
                  controller: firstNameCtrl,
                  hint: _t(context, en: 'First Name *', ar: 'الاسم الأول *'),
                  iconPath: 'assets/contact/name.svg',
                  submitted: submitted,
                  primaryColor: primaryColor,
                  textDirection: dir,
                  textAlign: align,
                ),
                _MobileIconField(
                  controller: lastNameCtrl,
                  hint: _t(context, en: 'Last Name *', ar: 'اسم العائلة *'),
                  iconPath: 'assets/contact/name.svg',
                  submitted: submitted,
                  primaryColor: primaryColor,
                  textDirection: dir,
                  textAlign: align,
                ),
                _MobileIconField(
                  controller: emailCtrl,
                  hint: _t(
                    context,
                    en: 'Enter Your Email *',
                    ar: 'أدخل بريدك الإلكتروني *',
                  ),
                  iconPath: 'assets/contact/sms.svg',
                  submitted: submitted,
                  primaryColor: primaryColor,
                  textDirection: dir,
                  textAlign: align,
                ),
                _MobilePhoneField(
                  controller: phoneCtrl,
                  submitted: submitted,
                  selectedCode: phoneCode,
                  onCodeChanged: onCodeChanged,
                  isRtl: isRtl,
                  primaryColor: primaryColor,
                ),

                if (_isOwner) ...[
                  _MobileIconField(
                    controller: salonNameCtrl,
                    hint: _t(context, en: 'Salon Name *', ar: 'اسم الصالون *'),
                    iconPath: 'assets/contact/salon_name.svg',
                    submitted: submitted,
                    primaryColor: primaryColor,
                    textDirection: dir,
                    textAlign: align,
                  ),
                  _MobileIconField(
                    controller: salonNameArCtrl,
                    hint: 'اسم الصالون بالعربي',
                    iconPath: 'assets/contact/salon_name.svg',
                    submitted: false,
                    primaryColor: primaryColor,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                  _MobileIconDropdown(
                    hint: _t(
                      context,
                      en: 'Target audience of salon *',
                      ar: 'الجمهور المستهدف *',
                    ),
                    iconPath: 'assets/contact/Target audience of salon.svg',
                    value: selectedTargetAudience,
                    items: targetItems,
                    onChanged: onTargetAudienceChanged,
                    submitted: submitted,
                    isRtl: isRtl,
                    primaryColor: primaryColor,
                  ),
                  _MobileIconDropdown(
                    hint: _t(
                      context,
                      en: 'Country of salon *',
                      ar: 'دولة الصالون *',
                    ),
                    iconPath: 'assets/contact/Country of salon.svg',
                    value: selectedSalonCountry,
                    items: countryItems,
                    onChanged: onSalonCountryChanged,
                    submitted: submitted,
                    isRtl: isRtl,
                    primaryColor: primaryColor,
                  ),
                  _MobileIconField(
                    controller: TextEditingController(
                      text: selectedSalonCity ?? '',
                    ),
                    hint: _t(context, en: 'City of salon', ar: 'مدينة الصالون'),
                    iconPath: 'assets/contact/City of salon.svg',
                    submitted: false,
                    primaryColor: primaryColor,
                    textDirection: dir,
                    textAlign: align,
                  ),
                  _MobileIconDropdown(
                    hint: _t(context, en: 'No. Branches *', ar: 'عدد الفروع *'),
                    iconPath: 'assets/contact/No.Branches.svg',
                    value: selectedNoBranches,
                    items: branchItems,
                    onChanged: onNoBranchesChanged,
                    submitted: submitted,
                    isRtl: isRtl,
                    primaryColor: primaryColor,
                  ),
                  _MobileIconDropdown(
                    hint: _t(context, en: 'Services *', ar: 'الخدمات *'),
                    iconPath: 'assets/contact/Services.svg',
                    value: selectedServices,
                    items: serviceItems,
                    onChanged: onServicesChanged,
                    submitted: submitted,
                    isRtl: isRtl,
                    primaryColor: primaryColor,
                  ),
                ],

                _MobileIconField(
                  controller: subjectCtrl,
                  hint: _t(context, en: 'Subject *', ar: 'الموضوع *'),
                  iconPath: 'assets/contact/Subject .svg',
                  submitted: submitted,
                  primaryColor: primaryColor,
                  textDirection: dir,
                  textAlign: align,
                  minLength: 5,
                ),
                _MobileIconDropdown(
                  hint: _t(context, en: 'Reason *', ar: 'السبب *'),
                  iconPath: 'assets/contact/Reason.svg',
                  value: selectedReason,
                  items: reasonItems,
                  onChanged: onReasonChanged,
                  submitted: submitted,
                  isRtl: isRtl,
                  primaryColor: primaryColor,
                ),
                _MobileIconField(
                  controller: messageCtrl,
                  hint: _t(context, en: 'Message *', ar: 'الرسالة *'),
                  iconPath: 'assets/contact/Message.svg',
                  submitted: submitted,
                  primaryColor: primaryColor,
                  textDirection: dir,
                  textAlign: align,
                  maxLines: 4,
                  height: 90,
                  minLength: 10,
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: onSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      sendLabel,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: Colors.white,
                        fontSize: 15.sp,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE TOGGLE
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileToggle extends StatelessWidget {
  final String userType, clientLabel, ownerLabel;
  final Color primaryColor;
  final ValueChanged<String> onChanged;
  const _MobileToggle({
    required this.userType,
    required this.primaryColor,
    required this.clientLabel,
    required this.ownerLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: CustomSegmentedTabs(
        tabs: [clientLabel, ownerLabel],
        tabIcons: const [
          'assets/beauty/contact_us/client.svg',
          'assets/beauty/contact_us/owner.svg',
        ],
        selectedIndex: userType == ContactFormConstants.userTypeClient ? 0 : 1,
        onTabSelected: (i) => onChanged(
          i == 0
              ? ContactFormConstants.userTypeClient
              : ContactFormConstants.userTypeOwner,
        ),
        selectedColor: primaryColor,
        unselectedColor: Colors.transparent,
        selectedTextColor: Colors.white,
        unselectedTextColor: Colors.grey.shade500,
        containerColor: Colors.white,
        containerPadding: EdgeInsets.all(3.r),
        borderRadius: 10,
        equalWidth: true,
        spacing: 0,
        iconSize: 18,
        iconSpacing: 6.w,
        tabHorizontalPadding: 0,
        tabVerticalPadding: 0,
        textStyle: StyleText.fontSize13Weight400.copyWith(fontSize: 13.sp),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE DESCRIPTION TEXT — fully CMS-driven, no static fallback shown
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileDescriptionText extends StatelessWidget {
  final bool isRtl;
  final ContactUsCmsModel? cmsData;
  final bool isOwner;
  const _MobileDescriptionText({
    required this.isRtl,
    this.cmsData,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final String cmsDesc = _getCmsDescription(
      cmsData: cmsData,
      isOwner: isOwner,
      isRtl: isRtl,
    );
    if (cmsDesc.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        cmsDesc,
        style: StyleText.fontSize13Weight400.copyWith(
          fontSize: 12.sp,
          color: Colors.black87,
          height: 1.7,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE ICON TEXT FIELD
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileIconField extends StatefulWidget {
  final TextEditingController controller;
  final String hint, iconPath;
  final bool submitted;
  final Color primaryColor;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final int maxLines, minLength;
  final double height;
  final bool onlyDigits;

  const _MobileIconField({
    required this.controller,
    required this.hint,
    required this.iconPath,
    required this.submitted,
    required this.primaryColor,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLength = 0,
    this.height = 46,
    this.onlyDigits = false,
  });

  @override
  State<_MobileIconField> createState() => _MobileIconFieldState();
}

class _MobileIconFieldState extends State<_MobileIconField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.controller.text.trim().isEmpty;
    final bool isTooShort =
        !isEmpty &&
        widget.minLength > 0 &&
        widget.controller.text.trim().length < widget.minLength;
    final bool showError = widget.submitted && (isEmpty || isTooShort);
    final bool isRtlDir = widget.textDirection == TextDirection.rtl;
    final String errMsg = isEmpty
        ? (isRtlDir ? 'هذا الحقل مطلوب' : 'This field is required')
        : (isRtlDir
              ? 'الحد الأدنى ${widget.minLength} حرف'
              : 'Minimum ${widget.minLength} characters');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8.r),
            border: showError
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: widget.maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: isRtlDir ? 0 : 12.w,
                  right: isRtlDir ? 12.w : 0,
                  top: widget.maxLines > 1 ? 13.h : 0,
                ),
                child: SvgPicture.asset(
                  widget.iconPath,
                  width: 18.w,
                  height: 18.w,
                  colorFilter: ColorFilter.mode(
                    showError ? Colors.red.shade300 : Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  textDirection: widget.textDirection,
                  textAlign: widget.textAlign,
                  keyboardType: widget.onlyDigits
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: widget.onlyDigits
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  cursorColor: widget.primaryColor,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color: Colors.black87,
                    fontSize: 13.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 12.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: widget.maxLines > 1 ? 12.h : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError) ...[
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errMsg,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE ICON DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileIconDropdown extends StatelessWidget {
  final String hint, iconPath;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool submitted, isRtl;
  final Color primaryColor;

  const _MobileIconDropdown({
    required this.hint,
    required this.iconPath,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.submitted,
    required this.isRtl,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && (value == null || value!.isEmpty);
    final String errMsg = isRtl ? 'هذا الحقل مطلوب' : 'This field is required';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items: items,
          onChanged: onChanged,
          widthIcon: 18,
          heightIcon: 18,
          iconPath: iconPath,
          primaryColor: primaryColor,
          dropdownColor: const Color(0xFFF5F5F5),
          width: double.infinity,
          height: 46,
          borderRadius: 8,
          hint: Text(
            hint,
            style: StyleText.fontSize12Weight400.copyWith(
              color: Colors.grey.shade400,
              fontSize: 12.sp,
            ),
          ),
        ),
        if (showError) ...[
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errMsg,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE PHONE FIELD
// ═══════════════════════════════════════════════════════════════════════════════

class _MobilePhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool submitted, isRtl;
  final String selectedCode;
  final ValueChanged<String?> onCodeChanged;
  final Color primaryColor;

  const _MobilePhoneField({
    required this.controller,
    required this.submitted,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.isRtl,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = controller.text.trim().isEmpty;
    final bool showError = submitted && isEmpty;
    final String errMsg = isRtl ? 'هذا الحقل مطلوب' : 'This field is required';
    final String hint = isRtl ? 'رقم الهاتف *' : 'Phone Number *';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 46.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8.r),
            border: showError
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  border: BorderDirectional(
                    end: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCode,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.sp,
                      color: Colors.grey.shade500,
                    ),
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: Colors.black87,
                      fontSize: 12.sp,
                    ),
                    dropdownColor: Color(0xFFF5F5F5),
                    items: _phoneCodes
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c['key'],
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                c['value'] ?? '',
                                style: StyleText.fontSize12Weight400.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onCodeChanged,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  cursorColor: primaryColor,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color: Colors.black87,
                    fontSize: 13.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 12.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError) ...[
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errMsg,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL MEDIA SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialMediaSection extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final Color primaryColor;
  final bool isMobile, isRtl;
  const _SocialMediaSection({
    this.cmsData,
    required this.primaryColor,
    required this.isMobile,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final rawIcons = (cmsData?.socialIcons ?? [])
        .where((i) => i.iconUrl.isNotEmpty || i.link.isNotEmpty)
        .toList();

    // Don't render the section at all if no icons
    if (rawIcons.isEmpty) return const SizedBox.shrink();

    final String title = _t(
      context,
      en: 'Social Media',
      ar: 'وسائل التواصل الاجتماعي',
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.w : 0,
        vertical: 24.h,
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              title,
              style: StyleText.fontSize22Weight700.copyWith(
                color: primaryColor,
                fontSize: isMobile ? 18.sp : 20.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: rawIcons
                  .map(
                    (i) => Padding(
                      padding: EdgeInsetsDirectional.only(end: 10.w),
                      child: _SocialIconWidget(
                        iconUrl: i.iconUrl,
                        link: i.link,
                        primaryColor: primaryColor,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL ICON WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class _SocialIconWidget extends StatelessWidget {
  final String? svgPath, iconUrl, link;
  final Color primaryColor;
  const _SocialIconWidget({
    this.svgPath,
    this.iconUrl,
    this.link,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: (link?.isNotEmpty ?? false)
        ? () async {
            String raw = link!.trim();
            if (!raw.startsWith('http://') && !raw.startsWith('https://'))
              raw = 'https://$raw';
            final uri = Uri.tryParse(raw);
            if (uri == null || !uri.hasAuthority) return;
            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
                webOnlyWindowName: '_blank',
              );
            }
          }
        : null,
    child: MouseRegion(
      cursor: (link?.isNotEmpty ?? false)
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: iconUrl != null && iconUrl!.isNotEmpty
              ? () {
            final viewId = 'svg-social-${iconUrl.hashCode}';
            ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
              final img = html.ImageElement()
                ..src = iconUrl!
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.objectFit = 'contain';
              return img;
            });
            return SizedBox(
              width: 22.w,
              height: 22.w,
              child: HtmlElementView(viewType: viewId),
            );
          }()
              : SvgPicture.asset(
            svgPath ?? 'assets/images/instegrm.svg',
            width: 22.w,
            height: 22.w,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    ),
  );
}
