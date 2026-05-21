part of '../../pages/contact_us_page.dart';

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
  final String? selectedGender;
  final String? selectedCountry;
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
      onGenderChanged,
      onCountryChanged,
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
    required this.selectedGender,
    required this.selectedCountry,
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
    required this.onGenderChanged,
    required this.onCountryChanged,
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

  // Get mainWidgetColor from HomeCmsCubit
  Color? _getMainWidgetColor(BuildContext context) {
    final homeState = context.watch<HomeCmsCubit>().state;
    return switch (homeState) {
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
  }

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = _getMainWidgetColor(context);
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
    final String genderLabel = _t(context, en: 'Gender', ar: 'الجنس');
    final String countryLabel = _t(context, en: 'Country', ar: 'الدولة');
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
    final String salonCountryLabel = _t(
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

    final genderItems =
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

    final targetItems =
    (isRtl
        ? ContactFormConstants.targetAudienceAr
        : ContactFormConstants.targetAudienceEn)
        .map((t) => {'key': t, 'value': t})
        .toList();
    final salonCountryItems =
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
// ── Services from OverviewCmsCubit ──────────────────────────────────
    List<Map<String, String>> serviceItems = [];
    final overviewState = context.watch<OverviewCmsCubit>().state;
    final overviewModel = switch (overviewState) {
      OverviewCmsLoaded(:final data) => data,
      OverviewCmsSaved(:final data) => data,
      _ => null,
    };

    if (overviewModel != null && overviewModel.services.items.isNotEmpty) {
      serviceItems = overviewModel.services.items
          .map((item) => {
        'key': isRtl ? item.name.ar : item.name.en,
        'value': isRtl ? item.name.ar : item.name.en,
      })
          .where((m) => m['key']!.isNotEmpty)
          .toList();
    }

// Fallback to static list if CMS has no services
    if (serviceItems.isEmpty) {
      serviceItems = (isRtl
          ? ContactFormConstants.servicesAr
          : ContactFormConstants.servicesEn)
          .map((s) => {'key': s, 'value': s})
          .toList();
    }
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
                      'assets/client_demo.svg',
                      'assets/owner_demo.svg',
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
                    'assets/client_demo.svg',
                    'assets/owner_demo.svg',
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

        // ── FORM CARD WITH MAIN WIDGET COLOR BACKGROUND ──
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14.w : 20.w,
            vertical: isMobile ? 14.h : 16.h,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,  // ← Changed from Colors.white to backgroundColor
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Preferred Language ──
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
                                      : Colors.grey,
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

              // ── First Name / Last Name ──
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

              // ── Email / Phone ──
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
                    child: _DemoStylePhoneField(
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

              // ── Gender + Country (all users) ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DropdownField(
                      label: genderLabel,
                      hint: selectHint,
                      value: selectedGender,
                      items: genderItems,
                      onChanged: onGenderChanged,
                      submitted: submitted,
                      isRtl: isRtl,
                      isMobile: isMobile,
                      primaryColor: primaryColor,
                      iconPath: 'assets/gender.svg',
                    ),
                  ),
                  SizedBox(width: isMobile ? 8.w : 12.w),
                  Expanded(
                    child: _DropdownField(
                      label: countryLabel,
                      hint: selectHint,
                      value: selectedCountry,
                      items: countryItems,
                      onChanged: onCountryChanged,
                      submitted: submitted,
                      isRtl: isRtl,
                      isMobile: isMobile,
                      primaryColor: primaryColor,
                      iconPath: 'assets/contact/Country of salon.svg',
                      isSearchable: true,
                    ),
                  ),
                ],
              ),

              // ── OWNER-ONLY: Salon Info ──
              if (_isOwner) ...[
                SizedBox(height: isMobile ? 12.h : 16.h),
                _SectionHeader(title: salonInfo, primaryColor: primaryColor, isRtl: isRtl),
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
                        label: salonCountryLabel,
                        hint: selectHint,
                        value: selectedSalonCountry,
                        items: salonCountryItems,
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

              // ── Subject / Reason / Message ──
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
