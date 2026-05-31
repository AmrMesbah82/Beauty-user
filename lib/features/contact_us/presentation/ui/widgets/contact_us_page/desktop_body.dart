part of '../../pages/contact_us_page.dart';

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
    final double screenW = MediaQuery.of(context).size.width;
    final double contentW = 1000.w;
    final double hPad = ((screenW - contentW) / 2).clamp(16.0, double.infinity);

    // ── FIX: use null-safe empty check, fallback to default strings ──
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
                      // ── FIX: wrap title row in a Row with Flexible to prevent overflow ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pageTitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: StyleText.fontSize45Weight600.copyWith(
                                    fontSize: 32.sp,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  pageSubtitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: StyleText.fontSize16Weight600.copyWith(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
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
                        selectedGender: selectedGender,
                        selectedCountry: selectedCountry,
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
                        onGenderChanged: onGenderChanged,
                        onCountryChanged: onCountryChanged,
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

// ═══════════════════════════════════════════════════════════════════════════════
// FORM CARD (WITH MAIN WIDGET COLOR BACKGROUND)
// ═══════════════════════════════════════════════════════════════════════════════
