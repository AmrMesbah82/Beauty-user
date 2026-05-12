/// File Name: request_demo_page.dart

import 'dart:ui' as ui;

import 'package:beauty_user/widgets/app_page_shell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:beauty_user/core/widget/circle_progress.dart';
import 'package:beauty_user/core/widget/custom_dropdwon.dart';
import 'package:beauty_user/core/widget/textfield.dart';
import 'package:beauty_user/theme/new_theme.dart';

import '../../controller/home/lang_state.dart';
import '../../controller/request/request_demo_cubit.dart';
import '../../controller/request/request_demo_state.dart';
import '../../model/request/request_demo_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUBMIT — STATE
// ════════════════════════════════════════════════════════════════════════════
abstract class _SubmitState {}
class _SubmitInitial extends _SubmitState {}
class _SubmitLoading extends _SubmitState {}
class _SubmitSuccess extends _SubmitState {}
class _SubmitError extends _SubmitState {
  final String message;
  _SubmitError(this.message);
}

// ════════════════════════════════════════════════════════════════════════════
// SUBMIT — CUBIT
// ════════════════════════════════════════════════════════════════════════════
class _SubmitCubit extends Cubit<_SubmitState> {
  _SubmitCubit() : super(_SubmitInitial());

  Future<void> submit({
    required String salonName,
    required String country,
    required String city,
    required String noBranches,
    required String noEmployees,
    required String firstName,
    required String lastName,
    required String phoneCode,
    required String phoneNumber,
    required String email,
    required Map<String, dynamic> dynamicAnswers,
    required String gender,
  }) async {
    emit(_SubmitLoading());
    try {
      final col = FirebaseFirestore.instance.collection('requestDemo');
      final doc = col.doc();
      await doc.set({
        'salonName':            salonName,
        'country':              country,
        'city':                 city,
        'noBranches':           noBranches,
        'noEmployees':          noEmployees,
        'firstName':            firstName,
        'lastName':             lastName,
        'countryCode':          phoneCode,
        'phone':                phoneNumber,
        'email':                email,
        'entityType':           gender,
        'status':               'New',
        'submissionDate':       FieldValue.serverTimestamp(),
        'primaryReason':        '',
        'howDidYouHearAboutUs': '',
        'note':                 '',
        'questionAnswers':      dynamicAnswers,
      });
      emit(_SubmitSuccess());
    } catch (e) {
      emit(_SubmitError(e.toString()));
    }
  }

  void reset() => emit(_SubmitInitial());
}

// ════════════════════════════════════════════════════════════════════════════
// PALETTE
// ════════════════════════════════════════════════════════════════════════════
class _C {
  static const Color primary = Color(0xFFD16F9A);
  static const Color back    = Color(0xFFF5F5F5);
  static const Color label   = Color(0xFF333333);
  static const Color hint    = Color(0xFFAAAAAA);
  static const Color card    = Color(0xFFFFFFFF);
  static const Color error   = Color(0xFFE53935);
  static const Color section = Color(0xFF555555);
  static const Color iconCol = Color(0xFFD16F9A);
}

const double _kDesktopBreak = 600;

// ════════════════════════════════════════════════════════════════════════════
// BILINGUAL STATIC DATA
// ════════════════════════════════════════════════════════════════════════════
const List<Map<String, String>> _kCountriesRaw = [
  {'key': 'egypt',        'value_en': 'Egypt',        'value_ar': 'مصر'},
  {'key': 'saudi_arabia', 'value_en': 'Saudi Arabia', 'value_ar': 'المملكة العربية السعودية'},
  {'key': 'uae',          'value_en': 'UAE',           'value_ar': 'الإمارات'},
  {'key': 'kuwait',       'value_en': 'Kuwait',        'value_ar': 'الكويت'},
  {'key': 'qatar',        'value_en': 'Qatar',         'value_ar': 'قطر'},
  {'key': 'bahrain',      'value_en': 'Bahrain',       'value_ar': 'البحرين'},
  {'key': 'jordan',       'value_en': 'Jordan',        'value_ar': 'الأردن'},
  {'key': 'lebanon',      'value_en': 'Lebanon',       'value_ar': 'لبنان'},
];

const List<Map<String, String>> _kCitiesRaw = [
  {'key': 'cairo',       'value_en': 'Cairo',       'value_ar': 'القاهرة'},
  {'key': 'alexandria',  'value_en': 'Alexandria',  'value_ar': 'الإسكندرية'},
  {'key': 'riyadh',      'value_en': 'Riyadh',      'value_ar': 'الرياض'},
  {'key': 'jeddah',      'value_en': 'Jeddah',      'value_ar': 'جدة'},
  {'key': 'dubai',       'value_en': 'Dubai',       'value_ar': 'دبي'},
  {'key': 'abu_dhabi',   'value_en': 'Abu Dhabi',   'value_ar': 'أبوظبي'},
  {'key': 'kuwait_city', 'value_en': 'Kuwait City', 'value_ar': 'مدينة الكويت'},
  {'key': 'doha',        'value_en': 'Doha',        'value_ar': 'الدوحة'},
];

const List<Map<String, String>> _kBranchesRaw = [
  {'key': '1',     'value_en': '1',       'value_ar': '١'},
  {'key': '2_5',   'value_en': '2 - 5',   'value_ar': '٢ - ٥'},
  {'key': '6_10',  'value_en': '6 - 10',  'value_ar': '٦ - ١٠'},
  {'key': '11_20', 'value_en': '11 - 20', 'value_ar': '١١ - ٢٠'},
  {'key': '20+',   'value_en': '20+',     'value_ar': '٢٠+'},
];

const List<Map<String, String>> _kEmployeesRaw = [
  {'key': '1_5',   'value_en': '1 - 5',   'value_ar': '١ - ٥'},
  {'key': '6_15',  'value_en': '6 - 15',  'value_ar': '٦ - ١٥'},
  {'key': '16_30', 'value_en': '16 - 30', 'value_ar': '١٦ - ٣٠'},
  {'key': '31_50', 'value_en': '31 - 50', 'value_ar': '٣١ - ٥٠'},
  {'key': '50+',   'value_en': '50+',     'value_ar': '٥٠+'},
];

const List<Map<String, String>> _kPhoneCodes = [
  {'key': '+20',  'value': '🇪🇬 +20'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+973', 'value': '🇧🇭 +973'},
  {'key': '+962', 'value': '🇯🇴 +962'},
  {'key': '+961', 'value': '🇱🇧 +961'},
  {'key': '+1',   'value': '🇺🇸 +1'},
  {'key': '+44',  'value': '🇬🇧 +44'},
];

List<Map<String, String>> _localise(
    List<Map<String, String>> raw, bool isAr) {
  return raw
      .map((e) => {
    'key':   e['key']!,
    'value': isAr ? e['value_ar']! : e['value_en']!,
  })
      .toList();
}

// ════════════════════════════════════════════════════════════════════════════
// LOCALIZED STRINGS
// ════════════════════════════════════════════════════════════════════════════
class _S {
  final bool isAr;
  const _S(this.isAr);

  String get salonInfo     => isAr ? 'معلومات الصالون'               : 'Salon Information';
  String get salonName     => isAr ? 'اسم الصالون'                   : 'Salon Name';
  String get country       => isAr ? 'الدولة'                        : 'Country';
  String get city          => isAr ? 'المدينة'                       : 'City';
  String get branches      => isAr ? 'الفروع'                        : 'Branches';
  String get noBranches    => isAr ? 'عدد الفروع'                    : 'No.Branches';
  String get noEmployees   => isAr ? 'عدد الموظفين'                  : 'No.Employees';
  String get contactInfo   => isAr ? 'معلومات التواصل'               : 'Contact Information';
  String get firstName     => isAr ? 'الاسم الأول'                   : 'First Name';
  String get lastName      => isAr ? 'الاسم الأخير'                  : 'Last Name';
  String get phoneNumber   => isAr ? 'رقم الهاتف'                    : 'Phone Number';
  String get email         => isAr ? 'البريد الإلكتروني'             : 'Email';
  String get demoQuestions => isAr ? 'أسئلة تجريبية'                 : 'Demo Related Questions';
  String get sendRequest   => isAr ? 'إرسال الطلب'                   : 'Send Request';
  String get chooseHere    => isAr ? 'اختر'                          : 'Choose here';
  String get textHere      => isAr ? 'أدخل هنا'                      : 'Text here';
  String get fieldRequired => isAr ? 'هذا الحقل مطلوب'               : 'This field is required.';
  String get submitError   => isAr ? 'حدث خطأ، يرجى المحاولة مجدداً' : 'An error occurred, please try again.';
  String get confirmTitle  => isAr
      ? 'جارٍ الانتظار حتى يتصل بك فريق خدمة العملاء'
      : 'Waiting till Customer Services Call You';
  String get confirmDesc   => isAr
      ? 'تم إرسال طلب العرض التوضيحي بنجاح، شكراً لك! سنتواصل معك قريباً لتأكيد التفاصيل.'
      : "Your demo request has been successfully submitted, thank you! We'll be in touch soon to confirm the details.";
  String get submitAnother => isAr ? 'إرسال طلب آخر' : 'Submit Another Request';

  TextDirection get td => isAr ? TextDirection.rtl : TextDirection.ltr;
}

// ════════════════════════════════════════════════════════════════════════════
// ENTRY POINT
// ════════════════════════════════════════════════════════════════════════════
class RequestDemoPage extends StatelessWidget {
  final String gender;
  const RequestDemoPage({super.key, this.gender = 'female'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _SubmitCubit(),
      child: _Inner(gender: gender),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _INNER
// ════════════════════════════════════════════════════════════════════════════
class _Inner extends StatelessWidget {
  final String gender;
  const _Inner({required this.gender});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final bool isAr = langState.isArabic;

        return BlocBuilder<RequestDemoCmsCubit, RequestDemoCmsState>(
          builder: (ctx, cmsState) {
            if (cmsState is RequestDemoCmsInitial ||
                cmsState is RequestDemoCmsLoading) {
              return const Scaffold(
                backgroundColor: _C.back,
                body: Center(
                    child: CircularProgressIndicator(color: _C.primary)),
              );
            }
            if (cmsState is RequestDemoCmsError) {
              return Scaffold(
                backgroundColor: _C.back,
                body: Center(
                  child: Text(cmsState.message,
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: _C.error)),
                ),
              );
            }

            RequestDemoPageModel? m;
            if (cmsState is RequestDemoCmsLoaded) m = cmsState.data;
            if (cmsState is RequestDemoCmsSaved)  m = cmsState.data;
            m ??= ctx.read<RequestDemoCmsCubit>().current;

            return BlocConsumer<_SubmitCubit, _SubmitState>(
              listener: (ctx, s) {
                if (s is _SubmitError) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(_S(isAr).submitError),
                    backgroundColor: _C.error,
                  ));
                }
              },
              builder: (ctx, submitState) {
                if (submitState is _SubmitSuccess) {
                  return _ConfirmScreen(model: m!, isAr: isAr);
                }
                return _FormScreen(
                  model:     m!,
                  gender:    gender,
                  isLoading: submitState is _SubmitLoading,
                  isAr:      isAr,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FORM SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _FormScreen extends StatefulWidget {
  final RequestDemoPageModel model;
  final String gender;
  final bool isLoading;
  final bool isAr;

  const _FormScreen({
    required this.model,
    required this.gender,
    required this.isLoading,
    required this.isAr,
  });

  @override
  State<_FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<_FormScreen> {
  bool _sub = false;

  final _salonName   = TextEditingController();
  final _firstName   = TextEditingController();
  final _lastName    = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _email       = TextEditingController();

  String? _country;
  String? _city;
  String? _noBranches;
  String? _noEmployees;
  String  _phoneCode = '+20';

  final Map<String, dynamic>               _answers        = {};
  final Map<String, TextEditingController> _dynControllers = {};

  @override
  void initState() {
    super.initState();
    _syncDynControllers();
  }

  @override
  void didUpdateWidget(_FormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDynControllers();
  }

  void _syncDynControllers() {
    for (final q in widget.model.demoQuestions) {
      if (q.type == QuestionType.text &&
          !_dynControllers.containsKey(q.id)) {
        _dynControllers[q.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _salonName.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phoneNumber.dispose();
    _email.dispose();
    for (final c in _dynControllers.values) c.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_salonName.text.trim().isEmpty)   return false;
    if (_country == null)                 return false;
    if (_city == null)                    return false;
    if (_noBranches == null)              return false;
    if (_noEmployees == null)             return false;
    if (_firstName.text.trim().isEmpty)   return false;
    if (_lastName.text.trim().isEmpty)    return false;
    if (_phoneNumber.text.trim().isEmpty) return false;
    if (_email.text.trim().isEmpty)       return false;
    for (final q in widget.model.demoQuestions) {
      if (!q.required) continue;
      final ans = q.type == QuestionType.text
          ? (_dynControllers[q.id]?.text.trim() ?? '')
          : (_answers[q.id]?.toString() ?? '');
      if (ans.isEmpty) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    setState(() => _sub = true);
    if (!_validate()) return;

    final Map<String, dynamic> dynMap = {};
    for (final q in widget.model.demoQuestions) {
      if (q.type == QuestionType.text) {
        dynMap[q.id] = _dynControllers[q.id]?.text.trim() ?? '';
      } else {
        dynMap[q.id] = _answers[q.id] ?? '';
      }
    }

    await context.read<_SubmitCubit>().submit(
      salonName:      _salonName.text.trim(),
      country:        _country ?? '',
      city:           _city ?? '',
      noBranches:     _noBranches ?? '',
      noEmployees:    _noEmployees ?? '',
      firstName:      _firstName.text.trim(),
      lastName:       _lastName.text.trim(),
      phoneCode:      _phoneCode,
      phoneNumber:    _phoneNumber.text.trim(),
      email:          _email.text.trim(),
      dynamicAnswers: dynMap,
      gender:         widget.gender,
    );
  }

  // ── helper: build a hint Text with correct direction ──────────────────────
  Widget _hint(_S str) => Text(
    str.chooseHere,
    textDirection: str.td,
    style: StyleText.fontSize12Weight400.copyWith(color: _C.hint),
  );

  @override
  Widget build(BuildContext context) {
    final isAr     = widget.isAr;
    final str      = _S(isAr);
    final width    = MediaQuery.of(context).size.width;
    final isMobile = width < _kDesktopBreak;
    final m        = widget.model;

    final countries = _localise(_kCountriesRaw, isAr);
    final cities    = _localise(_kCitiesRaw,    isAr);
    final branches  = _localise(_kBranchesRaw,  isAr);
    final employees = _localise(_kEmployeesRaw, isAr);

    return Scaffold(
      backgroundColor: _C.back,
      body: AppPageShell(
        currentRoute: 'our products',
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 680.w),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    if (m.headerSvgUrl.isNotEmpty)
                      Container(
                        width:   double.infinity,
                        height:  260.h,
                        padding: EdgeInsets.all(12.w),
                        child: SvgPicture.network(
                          m.headerSvgUrl,
                          fit:                BoxFit.contain,
                          placeholderBuilder: (_) =>
                          const Center(child: CircleProgressMaster()),
                        ),
                      ),

                    SizedBox(height: 14.h),

                    if ((isAr ? m.headerTitle.ar : m.headerTitle.en).isNotEmpty)
                      Text(
                        isAr ? m.headerTitle.ar : m.headerTitle.en,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize20Weight600.copyWith(
                          color:      _C.label,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                    SizedBox(height: 20.h),

                    Container(
                      width:   double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color:        _C.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _sectionTitle(str.salonInfo),
                          SizedBox(height: 12.h),

                          CustomValidatedTextFieldMaster(
                            label:            str.salonName,
                            hint:             str.textHere,
                            controller:       _salonName,
                            height:           36,
                            submitted:        _sub,
                            fillColor:        const Color(0xFFF6F6F6),
                            primaryColor:     _C.primary,
                            textDirection:    str.td,
                            textAlign:        isAr ? TextAlign.right : TextAlign.left,
                            labelPrefixSvg:   'assets/demos/salone_name.svg',
                            labelPrefixColor: _C.iconCol,
                          ),

                          SizedBox(height: 10.h),

                          _twoOrOne(
                            isMobile: isMobile,
                            left: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdownFormFieldInvMaster(
                                  label:            str.country,

                                  hint:             _hint(str),
                                  selectedValue:    _country,
                                  items:            countries,
                                  widthIcon:        18,
                                  heightIcon:       18,
                                  height:           36,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     _C.primary,
                                  textDirection:    str.td,        // ← RTL/LTR
                                  onChanged: (v) => setState(() => _country = v),
                                  labelPrefixSvg:   'assets/demos/country_city.svg',
                                  labelPrefixColor: _C.iconCol,
                                ),
                                if (_sub && _country == null)
                                  _errText(str)
                                else
                                  SizedBox(height: 18.h),
                              ],
                            ),
                            right: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdownFormFieldInvMaster(
                                  label:            str.city,
                                  hint:             _hint(str),
                                  selectedValue:    _city,
                                  items:            cities,
                                  widthIcon:        18,
                                  heightIcon:       18,
                                  height:           36,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     _C.primary,
                                  textDirection:    str.td,        // ← RTL/LTR
                                  onChanged: (v) => setState(() => _city = v),
                                  labelPrefixSvg:   'assets/demos/country_city.svg',
                                  labelPrefixColor: _C.iconCol,
                                ),
                                if (_sub && _city == null)
                                  _errText(str)
                                else
                                  SizedBox(height: 18.h),
                              ],
                            ),
                          ),

                          SizedBox(height: 14.h),

                          Text(str.branches,
                              style: StyleText.fontSize16Weight600
                                  .copyWith(color: _C.section)),
                          SizedBox(height: 10.h),

                          _twoOrOne(
                            isMobile: isMobile,
                            left: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdownFormFieldInvMaster(
                                  label:            str.noBranches,
                                  hint:             _hint(str),
                                  selectedValue:    _noBranches,
                                  items:            branches,
                                  widthIcon:        18,
                                  heightIcon:       18,
                                  height:           36,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     _C.primary,
                                  textDirection:    str.td,        // ← RTL/LTR
                                  onChanged: (v) => setState(() => _noBranches = v),
                                  labelPrefixSvg:   'assets/demos/no_branch.svg',
                                  labelPrefixColor: _C.iconCol,
                                ),
                                if (_sub && _noBranches == null)
                                  _errText(str)
                                else
                                  SizedBox(height: 18.h),
                              ],
                            ),
                            right: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdownFormFieldInvMaster(
                                  label:            str.noEmployees,
                                  hint:             _hint(str),
                                  selectedValue:    _noEmployees,
                                  items:            employees,
                                  widthIcon:        18,
                                  heightIcon:       18,
                                  height:           36,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     _C.primary,
                                  textDirection:    str.td,        // ← RTL/LTR
                                  onChanged: (v) => setState(() => _noEmployees = v),
                                  labelPrefixSvg:   'assets/demos/no_employee.svg',
                                  labelPrefixColor: _C.iconCol,
                                ),
                                if (_sub && _noEmployees == null)
                                  _errText(str)
                                else
                                  SizedBox(height: 18.h),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          _sectionTitle(str.contactInfo),
                          SizedBox(height: 12.h),

                          _twoOrOne(
                            isMobile: isMobile,
                            left: CustomValidatedTextFieldMaster(
                              label:            str.firstName,
                              hint:             str.textHere,
                              controller:       _firstName,
                              height:           36,
                              submitted:        _sub,
                              fillColor:        const Color(0xFFF6F6F6),
                              primaryColor:     _C.primary,
                              textDirection:    str.td,
                              textAlign:        isAr ? TextAlign.right : TextAlign.left,
                              labelPrefixSvg:   'assets/demos/name.svg',
                              labelPrefixColor: _C.iconCol,
                            ),
                            right: CustomValidatedTextFieldMaster(
                              label:            str.lastName,
                              hint:             str.textHere,
                              controller:       _lastName,
                              height:           36,
                              submitted:        _sub,
                              fillColor:        const Color(0xFFF6F6F6),
                              primaryColor:     _C.primary,
                              textDirection:    str.td,
                              textAlign:        isAr ? TextAlign.right : TextAlign.left,
                              labelPrefixSvg:   'assets/demos/name.svg',
                              labelPrefixColor: _C.iconCol,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          _twoOrOne(
                            isMobile: isMobile,
                            left:  _phoneField(str, isAr),
                            right: CustomValidatedTextFieldMaster(
                              label:            str.email,
                              hint:             str.textHere,
                              controller:       _email,
                              height:           36,
                              submitted:        _sub,
                              fillColor:        const Color(0xFFF6F6F6),
                              primaryColor:     _C.primary,
                              textDirection:    ui.TextDirection.ltr,
                              textAlign:        isAr ? TextAlign.right : TextAlign.left,

                              labelPrefixSvg:   'assets/demos/email.svg',
                              labelPrefixColor: _C.iconCol,
                            ),
                          ),

                          if (m.demoQuestions.isNotEmpty) ...[
                            SizedBox(height: 20.h),
                            _sectionTitle(str.demoQuestions),
                            SizedBox(height: 12.h),
                            _buildDynamicQuestions(
                                m.demoQuestions, str, isAr, isMobile),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    SizedBox(
                      width:  isMobile ? double.infinity : 400.w,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:         _C.primary,
                          disabledBackgroundColor: _C.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          elevation: 0,
                        ),
                        child: widget.isLoading
                            ? SizedBox(
                          width:  22.w,
                          height: 22.h,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : Text(str.sendRequest,
                            style: StyleText.fontSize16Weight600
                                .copyWith(color: Colors.white)),
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: StyleText.fontSize16Weight600.copyWith(color: _C.section),
  );

  Widget _twoOrOne({
    required bool isMobile,
    required Widget left,
    required Widget right,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [left, SizedBox(height: 10.h), right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: 12.w),
        Expanded(child: right),
      ],
    );
  }

  Widget _phoneField(_S str, bool isAr) {
    final isEmpty = _sub && _phoneNumber.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/demos/phone.svg',
              width:       14.w,
              height:      14.h,
              colorFilter: const ColorFilter.mode(_C.iconCol, BlendMode.srcIn),
            ),
            SizedBox(width: 5.w),
            Text(str.phoneNumber,
                style: StyleText.fontSize14Weight400
                    .copyWith(color: const Color(0xFF333333))),
          ],
        ),
        SizedBox(height: 6.h),
        SizedBox(
          height: 36.h,
          child: Row(
            children: [
              Container(
                height:  36.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color:        const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:   _phoneCode,
                    isDense: true,
                    style:   StyleText.fontSize12Weight400
                        .copyWith(color: _C.label),
                    items: _kPhoneCodes
                        .map((e) => DropdownMenuItem(
                      value: e['key'],
                      child: Text(e['value']!),
                    ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _phoneCode = v);
                    },
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: TextField(
                    controller:   _phoneNumber,
                    keyboardType: TextInputType.phone,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: _C.label),
                    decoration: InputDecoration(
                      hintText:  str.phoneNumber,
                      hintStyle: StyleText.fontSize12Weight400
                          .copyWith(color: _C.hint),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 13.h),
                      filled:    true,
                      fillColor: const Color(0xFFF6F6F6),
                      isDense:   true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(
                            color: isEmpty ? _C.error : Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide:
                        const BorderSide(color: _C.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (_) {
                      if (_sub) setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: _errText(str),
          )
        else
          SizedBox(height: 18.h),
      ],
    );
  }

  Widget _buildDynamicQuestions(
      List<DemoQuestionModel> questions,
      _S str,
      bool isAr,
      bool isMobile,
      ) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questions.asMap().entries.map((e) {
          final i = e.key;
          final q = e.value;
          return Padding(
            padding: EdgeInsets.only(
                bottom: i < questions.length - 1 ? 12.h : 0),
            child: _dynQuestion(q, str, isAr),
          );
        }).toList(),
      );
    }
    final List<Widget> rows = [];
    for (int i = 0; i < questions.length; i += 2) {
      final left  = questions[i];
      final right = i + 1 < questions.length ? questions[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(
              bottom: i + 2 < questions.length ? 12.h : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _dynQuestion(left, str, isAr)),
              SizedBox(width: 12.w),
              Expanded(
                child: right != null
                    ? _dynQuestion(right, str, isAr)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _dynQuestion(DemoQuestionModel q, _S str, bool isAr) {
    final qLabel   = isAr ? q.question.ar : q.question.en;
    final iconPath = _iconForQuestion(q.id);
    final hasError = _sub &&
        q.required &&
        (q.type == QuestionType.text
            ? (_dynControllers[q.id]?.text.trim() ?? '').isEmpty
            : (_answers[q.id]?.toString() ?? '').isEmpty);

    if (q.type == QuestionType.text) {
      _dynControllers.putIfAbsent(q.id, () => TextEditingController());
      return CustomValidatedTextFieldMaster(
        label:            '$qLabel${q.required ? ' *' : ''}',
        hint:             str.textHere,
        controller:       _dynControllers[q.id]!,
        height:           36,
        submitted:        _sub,
        fillColor:        const Color(0xFFF6F6F6),
        primaryColor:     _C.primary,
        textDirection:    str.td,
        textAlign:        isAr ? TextAlign.right : TextAlign.left,
        labelPrefixSvg:   iconPath,
        labelPrefixColor: _C.iconCol,
        onChanged:        (_) => setState(() {}),
      );
    }

    final dropItems = q.values
        .map((v) => {
      'key':   v.id,
      'value': isAr ? v.label.ar : v.label.en,
    })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownFormFieldInvMaster(
          label:            '$qLabel${q.required ? ' *' : ''}',
          hint:             Text(
            str.chooseHere,
            textDirection: str.td,
            style: StyleText.fontSize12Weight400.copyWith(color: _C.hint),
          ),
          selectedValue:    _answers[q.id] as String?,
          items:            dropItems,
          widthIcon:        18,
          heightIcon:       18,
          height:           36,
          dropdownColor:    const Color(0xFFF6F6F6),
          primaryColor:     _C.primary,
          textDirection:    str.td,                          // ← RTL/LTR
          onChanged:        (v) => setState(() => _answers[q.id] = v),
          labelPrefixSvg:   iconPath,
          labelPrefixColor: _C.iconCol,
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: _errText(str),
          )
        else
          SizedBox(height: 18.h),
      ],
    );
  }

  String _iconForQuestion(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('primary') || lower.contains('reason')) {
      return 'assets/demos/primary_reson.svg';
    }
    if (lower.contains('how') || lower.contains('hear')) {
      return 'assets/demos/how_herer_about.svg';
    }
    return 'assets/demos/primary_reson.svg';
  }

  Widget _errText(_S str) => Text(
    str.fieldRequired,
    style: TextStyle(
      fontSize:   10.sp,
      fontWeight: FontWeight.w700,
      color:      _C.error,
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// CONFIRM SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _ConfirmScreen extends StatelessWidget {
  final RequestDemoPageModel model;
  final bool isAr;
  const _ConfirmScreen({required this.model, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final str    = _S(isAr);
    final svgUrl = model.confirmSvgUrl;
    final title  =
    (isAr ? model.confirmTitle.ar : model.confirmTitle.en).isNotEmpty
        ? (isAr ? model.confirmTitle.ar : model.confirmTitle.en)
        : str.confirmTitle;
    final desc   =
    (isAr ? model.confirmDescription.ar : model.confirmDescription.en)
        .isNotEmpty
        ? (isAr
        ? model.confirmDescription.ar
        : model.confirmDescription.en)
        : str.confirmDesc;

    return Scaffold(
      backgroundColor: _C.back,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Container(
              width:   double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color:        _C.card,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (svgUrl.isNotEmpty)
                    SvgPicture.network(
                      svgUrl,
                      height:             220.h,
                      fit:                BoxFit.contain,
                      placeholderBuilder: (_) =>
                      const Center(child: CircleProgressMaster()),
                    )
                  else
                    Icon(Icons.check_circle_outline,
                        size: 80.sp, color: _C.primary),

                  SizedBox(height: 24.h),

                  Text(title,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize20Weight600.copyWith(
                          color: _C.primary, fontWeight: FontWeight.w700)),

                  SizedBox(height: 12.h),

                  Text(desc,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: _C.label, height: 1.6)),

                  SizedBox(height: 32.h),

                  SizedBox(
                    width:  double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () => context.read<_SubmitCubit>().reset(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _C.primary,
                        elevation:       0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(str.submitAnother,
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: _C.primary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}