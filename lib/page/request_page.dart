/// File Name: request_demo_page.dart
///
/// PUBLIC-FACING page — matches Figma design exactly:
///   • Header SVG above a single white card
///   • All form fields (Salon Info + Contact + Dynamic Questions) in ONE container
///   • Uses CustomValidatedTextFieldMaster for text inputs
///   • Uses CustomDropdownFormFieldInvMaster for dropdowns
///   • Send Request button below the card
///   • Confirm screen after success

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

import '../../controller/request/request_demo_cubit.dart';
import '../../controller/request/request_demo_state.dart';
import '../../model/request/request_demo_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUBMIT — STATE  (private, embedded)
// ════════════════════════════════════════════════════════════════════════════
abstract class _SubmitState {}
class _SubmitInitial extends _SubmitState {}
class _SubmitLoading extends _SubmitState {}
class _SubmitSuccess extends _SubmitState {}
class _SubmitError   extends _SubmitState {
  final String message;
  _SubmitError(this.message);
}

// ════════════════════════════════════════════════════════════════════════════
// SUBMIT — CUBIT  (private, embedded)
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
        'salonName':        salonName,
        'country':          country,
        'city':             city,
        'noBranches':       noBranches,
        'noEmployees':      noEmployees,
        'firstName':        firstName,
        'lastName':         lastName,
        'countryCode':      phoneCode,
        'phone':            phoneNumber,
        'email':            email,
        'entityType':       gender,        // gender → entityType
        'status':           'New',         // must match DemoStatus.newDemo.label
        'submissionDate':   FieldValue.serverTimestamp(),
        'primaryReason':    '',
        'howDidYouHearAboutUs': '',
        'note':             '',
        'questionAnswers':  dynamicAnswers,
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
  static const Color primary  = Color(0xFFD16F9A);
  static const Color back     = Color(0xFFF5F5F5);
  static const Color label    = Color(0xFF333333);
  static const Color hint     = Color(0xFFAAAAAA);
  static const Color border   = Color(0xFFE0E0E0);
  static const Color card     = Color(0xFFFFFFFF);
  static const Color error    = Color(0xFFE53935);
  static const Color section  = Color(0xFF555555);
}

// ── Static dropdown options ──────────────────────────────────────────────────
const List<Map<String, String>> _kCountries = [
  {'key': 'egypt',        'value': 'Egypt'},
  {'key': 'saudi_arabia', 'value': 'Saudi Arabia'},
  {'key': 'uae',          'value': 'UAE'},
  {'key': 'kuwait',       'value': 'Kuwait'},
  {'key': 'qatar',        'value': 'Qatar'},
  {'key': 'bahrain',      'value': 'Bahrain'},
  {'key': 'jordan',       'value': 'Jordan'},
  {'key': 'lebanon',      'value': 'Lebanon'},
];

const List<Map<String, String>> _kCities = [
  {'key': 'cairo',       'value': 'Cairo'},
  {'key': 'alexandria',  'value': 'Alexandria'},
  {'key': 'riyadh',      'value': 'Riyadh'},
  {'key': 'jeddah',      'value': 'Jeddah'},
  {'key': 'dubai',       'value': 'Dubai'},
  {'key': 'abu_dhabi',   'value': 'Abu Dhabi'},
  {'key': 'kuwait_city', 'value': 'Kuwait City'},
  {'key': 'doha',        'value': 'Doha'},
];

const List<Map<String, String>> _kBranches = [
  {'key': '1',    'value': '1'},
  {'key': '2_5',  'value': '2 - 5'},
  {'key': '6_10', 'value': '6 - 10'},
  {'key': '11_20','value': '11 - 20'},
  {'key': '20+',  'value': '20+'},
];

const List<Map<String, String>> _kEmployees = [
  {'key': '1_5',   'value': '1 - 5'},
  {'key': '6_15',  'value': '6 - 15'},
  {'key': '16_30', 'value': '16 - 30'},
  {'key': '31_50', 'value': '31 - 50'},
  {'key': '50+',   'value': '50+'},
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

class _Inner extends StatelessWidget {
  final String gender;
  const _Inner({required this.gender});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestDemoCmsCubit, RequestDemoCmsState>(
      builder: (ctx, cmsState) {
        if (cmsState is RequestDemoCmsInitial ||
            cmsState is RequestDemoCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
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
                content: Text(s.message),
                backgroundColor: _C.error,
              ));
            }
          },
          builder: (ctx, submitState) {
            if (submitState is _SubmitSuccess) {
              return _ConfirmScreen(model: m!);
            }
            return _FormScreen(
              model: m!,
              gender: gender,
              isLoading: submitState is _SubmitLoading,
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

  const _FormScreen({
    required this.model,
    required this.gender,
    required this.isLoading,
  });

  @override
  State<_FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<_FormScreen> {
  bool _sub = false;

  // Controllers — static fields
  final _salonName   = TextEditingController();
  final _firstName   = TextEditingController();
  final _lastName    = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _email       = TextEditingController();

  // Dropdown selections — static fields
  String? _country;
  String? _city;
  String? _noBranches;
  String? _noEmployees;
  String  _phoneCode = '+20';

  // Dynamic question answers: questionId → value
  final Map<String, dynamic> _answers = {};

  // Controllers for text-type dynamic questions
  final Map<String, TextEditingController> _dynControllers = {};

  @override
  void didUpdateWidget(_FormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDynControllers();
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final m    = widget.model;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: _C.back,
      body: AppPageShell(
        currentRoute: '/Demo',
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 680.w),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // ── Header SVG ───────────────────────────────────────────
                    if (m.headerSvgUrl.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 260.h,
                        decoration: const BoxDecoration(),
                        padding: EdgeInsets.all(12.w),
                        child: SvgPicture.network(
                          m.headerSvgUrl,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) =>
                          const Center(child: CircleProgressMaster()),
                        ),
                      ),

                    SizedBox(height: 14.h),

                    // ── Page title ───────────────────────────────────────────
                    if ((isAr
                        ? m.headerTitle.ar
                        : m.headerTitle.en)
                        .isNotEmpty)
                      Text(
                        isAr ? m.headerTitle.ar : m.headerTitle.en,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize20Weight600.copyWith(
                          color: _C.label,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                    SizedBox(height: 20.h),

                    // ══════════════════════════════════════════════════════════
                    // SINGLE WHITE CARD — all form sections inside
                    // ══════════════════════════════════════════════════════════
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: _C.card,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: _C.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ─── Salon Information ─────────────────────────────
                          _sectionTitle(
                              isAr ? 'معلومات الصالون' : 'Salon Information'),
                          SizedBox(height: 12.h),

                          // Salon Name — full width
                          Row(
                            children: [
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: isAr ? 'اسم الصالون' : 'Salon Name',
                                  hint:  isAr ? 'أدخل هنا' : 'Text here',
                                  controller: _salonName,
                                  height: 36,
                                  submitted: _sub,
                                  fillColor: const Color(0xFFF6F6F6),
                                  primaryColor: _C.primary,
                                  textDirection: isAr
                                      ? ui.TextDirection.rtl
                                      : ui.TextDirection.ltr,
                                  textAlign:
                                  isAr ? TextAlign.right : TextAlign.left,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(child: Column())
                            ],
                          ),

                          // Country + City — side by side
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomDropdownFormFieldInvMaster(
                                  label: isAr ? 'الدولة' : 'Country',
                                  hint: Text(
                                    isAr ? 'اختر' : 'Choose here',
                                    style: StyleText.fontSize12Weight400
                                        .copyWith(color: _C.hint),
                                  ),
                                  selectedValue: _country,
                                  items: _kCountries,
                                  widthIcon: 18,
                                  heightIcon: 18,
                                  height: 36,
                                  dropdownColor: const Color(0xFFF6F6F6),
                                  primaryColor: _C.primary,
                                  onChanged: (v) =>
                                      setState(() => _country = v),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomDropdownFormFieldInvMaster(
                                  dropdownColor: const Color(0xFFF6F6F6),
                                  label: isAr ? 'المدينة' : 'City',
                                  hint: Text(
                                    isAr ? 'اختر' : 'Choose here',
                                    style: StyleText.fontSize12Weight400
                                        .copyWith(color: _C.hint),
                                  ),
                                  selectedValue: _city,
                                  items: _kCities,
                                  widthIcon: 18,
                                  heightIcon: 18,
                                  height: 36,
                                  primaryColor: _C.primary,
                                  onChanged: (v) =>
                                      setState(() => _city = v),
                                ),
                              ),
                            ],
                          ),

                          if (_sub && (_country == null || _city == null))
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _country == null
                                        ? _errText(isAr)
                                        : const SizedBox.shrink(),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _city == null
                                        ? _errText(isAr)
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 14.h),

                          // Branches label
                          Text(
                            isAr ? 'الفروع' : 'Branches',
                            style: StyleText.fontSize16Weight600
                                .copyWith(color: _C.section),
                          ),
                          SizedBox(height: 10.h),

                          // No.Branches + No.Employees — side by side
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomDropdownFormFieldInvMaster(
                                  label: isAr ? 'عدد الفروع' : 'No.Branches',
                                  hint: Text(
                                    isAr ? 'اختر' : 'Choose here',
                                    style: StyleText.fontSize12Weight400
                                        .copyWith(color: _C.hint),
                                  ),
                                  selectedValue: _noBranches,
                                  items: _kBranches,
                                  widthIcon: 18,
                                  heightIcon: 18,
                                  height: 36,
                                  dropdownColor: const Color(0xFFF6F6F6),
                                  primaryColor: _C.primary,
                                  onChanged: (v) =>
                                      setState(() => _noBranches = v),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomDropdownFormFieldInvMaster(
                                  label:
                                  isAr ? 'عدد الموظفين' : 'No.Employees',
                                  hint: Text(
                                    isAr ? 'اختر' : 'Choose here',
                                    style: StyleText.fontSize12Weight400
                                        .copyWith(color: _C.hint),
                                  ),
                                  selectedValue: _noEmployees,
                                  items: _kEmployees,
                                  widthIcon: 18,
                                  heightIcon: 18,
                                  height: 36,
                                  dropdownColor: const Color(0xFFF6F6F6),
                                  primaryColor: _C.primary,
                                  onChanged: (v) =>
                                      setState(() => _noEmployees = v),
                                ),
                              ),
                            ],
                          ),

                          if (_sub &&
                              (_noBranches == null || _noEmployees == null))
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _noBranches == null
                                        ? _errText(isAr)
                                        : const SizedBox.shrink(),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _noEmployees == null
                                        ? _errText(isAr)
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 20.h),

                          // ─── Contact Information ───────────────────────────
                          _sectionTitle(isAr
                              ? 'معلومات التواصل'
                              : 'Contact  Information'),
                          SizedBox(height: 12.h),

                          // First Name + Last Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: isAr ? 'الاسم الأول' : 'First Name',
                                  hint:  isAr ? 'أدخل هنا' : 'Text here',
                                  controller: _firstName,
                                  height: 36,
                                  submitted: _sub,
                                  fillColor: const Color(0xFFF6F6F6),
                                  primaryColor: _C.primary,
                                  textDirection: isAr
                                      ? ui.TextDirection.rtl
                                      : ui.TextDirection.ltr,
                                  textAlign: isAr
                                      ? TextAlign.right
                                      : TextAlign.left,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: isAr ? 'الاسم الأخير' : 'Last Name',
                                  hint:  isAr ? 'أدخل هنا' : 'Text here',
                                  controller: _lastName,
                                  height: 36,
                                  submitted: _sub,
                                  fillColor: const Color(0xFFF6F6F6),
                                  primaryColor: _C.primary,
                                  textDirection: isAr
                                      ? ui.TextDirection.rtl
                                      : ui.TextDirection.ltr,
                                  textAlign: isAr
                                      ? TextAlign.right
                                      : TextAlign.left,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),

                          // Phone + Email
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _phoneRow(isAr)),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: isAr
                                      ? 'البريد الإلكتروني'
                                      : 'Email',
                                  hint: isAr ? 'أدخل هنا' : 'Text here',
                                  controller: _email,
                                  height: 36,
                                  submitted: _sub,
                                  fillColor: const Color(0xFFF6F6F6),
                                  primaryColor: _C.primary,
                                  textDirection: ui.TextDirection.ltr,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),

                          // ─── Dynamic Demo Questions ────────────────────────
                          if (m.demoQuestions.isNotEmpty) ...[
                            SizedBox(height: 20.h),
                            _sectionTitle(isAr
                                ? 'أسئلة تجريبية'
                                : 'Demo Related Questions'),
                            SizedBox(height: 12.h),
                            ...List.generate(
                              m.demoQuestions.length,
                                  (i) {
                                final q = m.demoQuestions[i];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < m.demoQuestions.length - 1
                                        ? 12.h
                                        : 0,
                                  ),
                                  child: _dynQuestion(q, isAr),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── Send Request Button ──────────────────────────────────
                    SizedBox(
                      width: 400.w,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          disabledBackgroundColor:
                          _C.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          elevation: 0,
                        ),
                        child: widget.isLoading
                            ? SizedBox(
                          width: 22.w,
                          height: 22.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          isAr ? 'إرسال الطلب' : 'Send Request',
                          style: StyleText.fontSize16Weight600
                              .copyWith(color: Colors.white),
                        ),
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

  // ── Section title ─────────────────────────────────────────────────────────
  Widget _sectionTitle(String t) => Text(
    t,
    style: StyleText.fontSize16Weight600.copyWith(color: _C.section),
  );

  // ── Phone row: code picker + number field ─────────────────────────────────
  Widget _phoneRow(bool isAr) {
    final isEmpty = _sub && _phoneNumber.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'رقم الهاتف' : 'Phone Number',
          style: StyleText.fontSize14Weight600.copyWith(color: _C.label),
        ),
        SizedBox(height: 6.h),
        SizedBox(
          height: 36.h,
          child: Row(
            children: [
              Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: isEmpty ? _C.error : Colors.transparent,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _phoneCode,
                    isDense: true,
                    style: StyleText.fontSize12Weight400
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
                  height: 36.h,
                  child: TextField(
                    controller: _phoneNumber,
                    keyboardType: TextInputType.phone,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: _C.label),
                    decoration: InputDecoration(
                      hintText:
                      isAr ? 'رقم الهاتف' : 'Phone Number *',
                      hintStyle: StyleText.fontSize12Weight400
                          .copyWith(color: _C.hint),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 10.h),
                      filled: true,
                      fillColor: const Color(0xFFF6F6F6),
                      isDense: true,
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
            child: Text(
              isAr ? 'هذا الحقل مطلوب' : 'This field is required.',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: _C.error,
              ),
            ),
          ),
        if (!isEmpty) SizedBox(height: 18.h),
      ],
    );
  }

  // ── Dynamic question ──────────────────────────────────────────────────────
  Widget _dynQuestion(DemoQuestionModel q, bool isAr) {
    final qLabel   = isAr ? q.question.ar : q.question.en;
    final hasError = _sub && q.required &&
        (q.type == QuestionType.text
            ? (_dynControllers[q.id]?.text.trim() ?? '').isEmpty
            : (_answers[q.id]?.toString() ?? '').isEmpty);

    if (q.type == QuestionType.text) {
      _dynControllers.putIfAbsent(q.id, () => TextEditingController());
      return CustomValidatedTextFieldMaster(
        label:     '$qLabel${q.required ? ' *' : ''}',
        hint:      isAr ? 'أدخل هنا' : 'Text here',
        controller: _dynControllers[q.id]!,
        height:    36,
        submitted:  _sub,
        fillColor: const Color(0xFFF6F6F6),
        primaryColor: _C.primary,
        textDirection:
        isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        textAlign: isAr ? TextAlign.right : TextAlign.left,
        onChanged: (_) => setState(() {}),
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
          label: '$qLabel${q.required ? ' *' : ''}',
          hint: Text(
            isAr ? 'اختر' : 'Choose here',
            style: StyleText.fontSize12Weight400.copyWith(color: _C.hint),
          ),
          selectedValue: _answers[q.id] as String?,
          items: dropItems,
          widthIcon:    18,
          heightIcon:   18,
          height:       36,
          dropdownColor: const Color(0xFFF6F6F6),
          primaryColor:  _C.primary,
          onChanged: (v) => setState(() => _answers[q.id] = v),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              isAr ? 'هذا الحقل مطلوب' : 'This field is required.',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: _C.error,
              ),
            ),
          ),
        if (!hasError) SizedBox(height: 18.h),
      ],
    );
  }

  Widget _errText(bool isAr) => Text(
    isAr ? 'هذا الحقل مطلوب' : 'This field is required.',
    style: TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      color: _C.error,
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// CONFIRM SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _ConfirmScreen extends StatelessWidget {
  final RequestDemoPageModel model;
  const _ConfirmScreen({required this.model});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final svgUrl = model.confirmSvgUrl;
    final title = (isAr ? model.confirmTitle.ar : model.confirmTitle.en).isNotEmpty
        ? (isAr ? model.confirmTitle.ar : model.confirmTitle.en)
        : 'Waiting till Customer Services Call You';
    final desc  = (isAr ? model.confirmDescription.ar : model.confirmDescription.en).isNotEmpty
        ? (isAr ? model.confirmDescription.ar : model.confirmDescription.en)
        : "Your demo request has been successfully submitted, thank you! "
        "We'll be in touch soon to confirm the details.";

    return Scaffold(
      backgroundColor: _C.back,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (svgUrl.isNotEmpty)
                    SvgPicture.network(
                      svgUrl,
                      height: 220.h,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) =>
                      const Center(child: CircleProgressMaster()),
                    )
                  else
                    Icon(Icons.check_circle_outline,
                        size: 80.sp, color: _C.primary),

                  SizedBox(height: 24.h),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize20Weight600
                        .copyWith(color: _C.primary,fontWeight: FontWeight.w700),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: _C.label, height: 1.6),
                  ),

                  SizedBox(height: 32.h),

                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: OutlinedButton(
                      onPressed: () =>
                          context.read<_SubmitCubit>().reset(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _C.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        isAr ? 'إرسال طلب آخر' : 'Submit Another Request',
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: _C.primary),
                      ),
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