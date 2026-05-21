part of '../../pages/request_page.dart';

class _FormScreen extends StatefulWidget {
  final RequestDemoPageModel model;
  final String gender;
  final bool isLoading;
  final bool isAr;
  final Color primaryColor;
  final Color mainWidgetColor;

  const _FormScreen({
    required this.model,
    required this.gender,
    required this.isLoading,
    required this.isAr,
    required this.primaryColor,
    required this.mainWidgetColor,
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
  String? _city;      // ← reset when country changes
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

  Widget _hint(_S str) => Text(
    str.chooseHere,
    textDirection: str.td,
    style: StyleText.fontSize12Weight400.copyWith(color: _C.hint),
  );

  Widget _cityHint(_S str) => Text(
    _country == null ? str.selectCountry : str.chooseHere,
    textDirection: str.td,
    style: StyleText.fontSize12Weight400.copyWith(color: _C.hint),
  );

  @override
  Widget build(BuildContext context) {
    final isAr        = widget.isAr;
    final str         = _S(isAr);
    final primary     = widget.primaryColor;
    final widgetColor = widget.mainWidgetColor;
    final width       = MediaQuery.of(context).size.width;
    final isMobile    = width < _kDesktopBreak;
    final m           = widget.model;

    final countries   = _localise(_kCountriesRaw, isAr);
    final cities      = _citiesForCountry(_country, isAr);  // ← filtered
    final branches    = _localise(_kBranchesRaw,  isAr);
    final employees   = _localise(_kEmployeesRaw, isAr);

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
                          color:      primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                    SizedBox(height: 20.h),

                    Container(
                      width:   double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color:        widgetColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _sectionTitle(str.salonInfo, primary),
                          SizedBox(height: 12.h),

                          // ── Salon Name ──────────────────────────────
                          CustomValidatedTextFieldMaster(
                            label:            str.salonName,
                            hint:             str.textHere,
                            controller:       _salonName,
                            height:           _kFieldHeight,
                            submitted:        _sub,
                            fillColor:        const Color(0xFFF6F6F6),
                            primaryColor:     primary,
                            textDirection:    str.td,
                            textAlign:        isAr ? TextAlign.right : TextAlign.left,
                            labelPrefixSvg:   'assets/demos/salone_name.svg',
                            labelPrefixColor: primary,
                          ),

                          SizedBox(height: 10.h),

                          // ── Country + City ──────────────────────────
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
                                  height:           _kFieldHeight,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     primary,
                                  textDirection:    str.td,
                                  onChanged: (v) => setState(() {
                                    _country = v;
                                    _city = null; // ← reset city on country change
                                  }),
                                  labelPrefixSvg:   'assets/demos/country_city.svg',
                                  labelPrefixColor: primary,
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
                                  hint:             _cityHint(str),
                                  selectedValue:    _city,
                                  // ← only cities for selected country;
                                  //   empty list disables the dropdown
                                  items:            cities,
                                  widthIcon:        18,
                                  heightIcon:       18,
                                  height:           _kFieldHeight,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     primary,
                                  textDirection:    str.td,
                                  onChanged: (v) {
                                    if (_country == null) return;
                                    setState(() => _city = v);
                                  },
                                  labelPrefixSvg:   'assets/demos/country_city.svg',
                                  labelPrefixColor: primary,
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
                                  .copyWith(color: primary)),
                          SizedBox(height: 10.h),

                          // ── Branches + Employees ────────────────────
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
                                  height:           _kFieldHeight,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     primary,
                                  textDirection:    str.td,
                                  onChanged: (v) => setState(() => _noBranches = v),
                                  labelPrefixSvg:   'assets/demos/no_branch.svg',
                                  labelPrefixColor: primary,
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
                                  height:           _kFieldHeight,
                                  dropdownColor:    const Color(0xFFF6F6F6),
                                  primaryColor:     primary,
                                  textDirection:    str.td,
                                  onChanged: (v) => setState(() => _noEmployees = v),
                                  labelPrefixSvg:   'assets/demos/no_employee.svg',
                                  labelPrefixColor: primary,
                                ),
                                if (_sub && _noEmployees == null)
                                  _errText(str)
                                else
                                  SizedBox(height: 18.h),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          _sectionTitle(str.contactInfo, primary),
                          SizedBox(height: 12.h),

                          // ── First + Last Name ───────────────────────
                          _twoOrOne(
                            isMobile: isMobile,
                            left: CustomValidatedTextFieldMaster(
                              label:            str.firstName,
                              hint:             str.textHere,
                              controller:       _firstName,
                              height:           _kFieldHeight,
                              submitted:        _sub,
                              fillColor:        const Color(0xFFF6F6F6),
                              primaryColor:     primary,
                              textDirection:    str.td,
                              textAlign:        isAr ? TextAlign.right : TextAlign.left,
                              labelPrefixSvg:   'assets/demos/name.svg',
                              labelPrefixColor: primary,
                            ),
                            right: CustomValidatedTextFieldMaster(
                              label:            str.lastName,
                              hint:             str.textHere,
                              controller:       _lastName,
                              height:           _kFieldHeight,
                              submitted:        _sub,
                              fillColor:        const Color(0xFFF6F6F6),
                              primaryColor:     primary,
                              textDirection:    str.td,
                              textAlign:        isAr ? TextAlign.right : TextAlign.left,
                              labelPrefixSvg:   'assets/demos/name.svg',
                              labelPrefixColor: primary,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // ── Phone + Email ───────────────────────────
                          // ── Phone + Email ───────────────────────────
                          _twoOrOne(
                            isMobile: isMobile,
                            left:  _phoneField(str, isAr, primary),
                            right: CustomValidatedTextFieldMaster(
                              label:            str.email,
                              hint:             str.textHere,
                              controller:       _email,
                              height:           _kFieldHeight,
                              submitted:        _sub,
                              fillColor:        const Color(0xFFF6F6F6),
                              primaryColor:     primary,
                              textDirection:    ui.TextDirection.ltr,
                              textAlign:        isAr ? TextAlign.right : TextAlign.left,
                              labelPrefixSvg:   'assets/demos/email.svg',
                              labelPrefixColor: primary,
                              customEmptyError: str.fieldRequired,  // ← NEW: Pass localized error message
                            ),
                          ),

                          if (m.demoQuestions.isNotEmpty) ...[
                            SizedBox(height: 20.h),
                            _sectionTitle(str.demoQuestions, primary),
                            SizedBox(height: 12.h),
                            _buildDynamicQuestions(
                                m.demoQuestions, str, isAr, isMobile, primary),
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
                          backgroundColor:         primary,
                          disabledBackgroundColor: primary.withOpacity(0.6),
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

  Widget _sectionTitle(String t, Color primary) => Text(
    t,
    style: StyleText.fontSize16Weight600.copyWith(color: primary),
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

  Widget _phoneField(_S str, bool isAr, Color primary) {
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
              colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
            ),
            SizedBox(width: 5.w),
            Text(str.phoneNumber,
                style: StyleText.fontSize14Weight400
                    .copyWith(color: const Color(0xFF333333))),
          ],
        ),
        SizedBox(height: 6.h),
        SizedBox(
          height: _kFieldHeight.h,
          child: Row(
            children: [
              Container(
                height:  _kFieldHeight.h,
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
                  height: _kFieldHeight.h + 4,
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
                          horizontal: 8.w, vertical: 16.h),
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
                        borderSide: BorderSide(color: primary, width: 1.5),
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
      Color primary,
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
            child: _dynQuestion(q, str, isAr, primary),
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
              Expanded(child: _dynQuestion(left, str, isAr, primary)),
              SizedBox(width: 12.w),
              Expanded(
                child: right != null
                    ? _dynQuestion(right, str, isAr, primary)
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

  Widget _dynQuestion(DemoQuestionModel q, _S str, bool isAr, Color primary) {
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
        height:           _kFieldHeight,
        submitted:        _sub,
        fillColor:        const Color(0xFFF6F6F6),
        primaryColor:     primary,
        textDirection:    str.td,
        textAlign:        isAr ? TextAlign.right : TextAlign.left,
        labelPrefixSvg:   iconPath,
        labelPrefixColor: primary,
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
          height:           _kFieldHeight,
          dropdownColor:    const Color(0xFFF6F6F6),
          primaryColor:     primary,
          textDirection:    str.td,
          onChanged:        (v) => setState(() => _answers[q.id] = v),
          labelPrefixSvg:   iconPath,
          labelPrefixColor: primary,
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
    if (lower.contains('primary') || lower.contains('reason'))
      return 'assets/demos/primary_reson.svg';
    if (lower.contains('how') || lower.contains('hear'))
      return 'assets/demos/how_herer_about.svg';
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
