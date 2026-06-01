part of '../../pages/contact_us_page.dart';

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

  // ── Personal Info (shown for ALL users) ──
  String? _selectedGender;
  String? _selectedCountry;

  // ── Salon Info (Owner-only extras) ──
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
      final uri = GoRouterState.of(context).uri;
      final type = uri.queryParameters['type'] ?? '';
      if (type == 'owner') {
        setState(() => _userType = ContactFormConstants.userTypeOwner);
      } else if (type == 'client') {
        setState(() => _userType = ContactFormConstants.userTypeClient);
      }
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

    if (!personalFilled ||
        _selectedReason == null ||
        _selectedGender == null ||
        _selectedCountry == null) return;

    if (_isOwner) {
      final salonFilled =
          _salonNameCtrl.text.trim().isNotEmpty &&
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
        targetAudience: _isOwner
            ? (_selectedTargetAudience ?? _selectedGender ?? '')
            : (_selectedGender ?? ''),
        salonCountry: _isOwner
            ? (_selectedSalonCountry ?? _selectedCountry ?? '')
            : (_selectedCountry ?? ''),
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
      _selectedGender = null;
      _selectedCountry = null;
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

                            child: BlocBuilder<GenderCubit, GenderState>(
                              builder: (context, genderState) {
                                final bool isMale = genderState.isMale;
                                final Color primaryColor = _resolvePrimaryColor(
                                  primaryColorHex: primaryColorHex,
                                  malePrimaryColorHex: malePrimaryColorHex,
                                  isMale: isMale,
                                );
                                return _OtpDialog(
                                  phoneNumber: otpState.phoneNumber,
                                  isRtl: isRtl,
                                  primaryColor: primaryColor,
                                  onVerified: () {
                                    Navigator.of(context).pop();
                                    _submitContactForm();
                                  },
                                );
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
                          builder: (_) => BlocBuilder<GenderCubit, GenderState>(
                            builder: (context, genderState) {
                              final bool isMale = genderState.isMale;
                              final Color primaryColor = _resolvePrimaryColor(
                                primaryColorHex: primaryColorHex,
                                malePrimaryColorHex: malePrimaryColorHex,
                                isMale: isMale,
                              );
                              return _SuccessDialog(
                                isRtl: isRtl,
                                primaryColor: primaryColor,
                              );
                            },
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

                    ContactUsCmsModel? cmsData;
                    if (cmsState is ContactUsCmsLoaded) {
                      cmsData = cmsState.data;

                    }
                    if (cmsState is ContactUsCmsError) {
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

                        // ── Gender-aware color rebuild ──────────────────────
                        return BlocBuilder<GenderCubit, GenderState>(
                          builder: (context, genderState) {
                            final bool isMale = genderState.isMale;

                            // ✅ Pick primary color based on current gender
                            final Color primaryColor = _resolvePrimaryColor(
                              primaryColorHex: primaryColorHex,
                              malePrimaryColorHex: malePrimaryColorHex,
                              isMale: isMale,
                            );

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
                                              selectedGender: _selectedGender,
                                              selectedCountry:
                                              _selectedCountry,
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
                                              onGenderChanged: (v) =>
                                                  setState(
                                                        () =>
                                                    _selectedGender = v,
                                                  ),
                                              onCountryChanged: (v) =>
                                                  setState(
                                                        () =>
                                                    _selectedCountry = v,
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
                                              selectedGender: _selectedGender,
                                              selectedCountry:
                                              _selectedCountry,
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
                                              onGenderChanged: (v) =>
                                                  setState(
                                                        () =>
                                                    _selectedGender = v,
                                                  ),
                                              onCountryChanged: (v) =>
                                                  setState(
                                                        () =>
                                                    _selectedCountry = v,
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
