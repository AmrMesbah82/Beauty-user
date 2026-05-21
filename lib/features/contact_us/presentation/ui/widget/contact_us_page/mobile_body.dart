part of '../../pages/contact_us_page.dart';

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
    this.cmsData,
  });

  bool get _isOwner => userType == ContactFormConstants.userTypeOwner;

  @override
  Widget build(BuildContext context) {
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
    // ── Services from OverviewCmsCubit (mobile) ─────────────────────────
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
                // ── Preferred Language ──
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

                // ── Personal fields ──
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
                // ── NEW MOBILE PHONE FIELD (demo page style) ──
                _DemoStyleMobilePhoneField(
                  controller: phoneCtrl,
                  submitted: submitted,
                  selectedCode: phoneCode,
                  onCodeChanged: onCodeChanged,
                  isRtl: isRtl,
                  primaryColor: primaryColor,
                ),

                // ── Gender + Country (all users) ──
                _MobileIconDropdown(
                  hint: _t(context, en: 'Gender *', ar: 'الجنس *'),
                  iconPath: 'assets/contact/Target audience of salon.svg',
                  value: selectedGender,
                  items: genderItems,
                  onChanged: onGenderChanged,
                  submitted: submitted,
                  isRtl: isRtl,
                  primaryColor: primaryColor,
                ),
                _MobileIconDropdown(
                  hint: _t(context, en: 'Country *', ar: 'الدولة *'),
                  iconPath: 'assets/contact/Country of salon.svg',
                  value: selectedCountry,
                  items: countryItems,
                  onChanged: onCountryChanged,
                  submitted: submitted,
                  isRtl: isRtl,
                  primaryColor: primaryColor,
                ),

                // ── OWNER-ONLY: Salon fields ──
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
                    items: salonCountryItems,
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

                // ── Subject / Reason / Message ──
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
