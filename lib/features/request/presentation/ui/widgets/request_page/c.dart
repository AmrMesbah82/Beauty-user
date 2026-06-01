part of '../../pages/request_page.dart';
const double _kDesktopBreak = 600;
const double _kFieldHeight  = 46; // ← +10 from original 36

// ════════════════════════════════════════════════════════════════════════════
// COLOR HELPERS
// ════════════════════════════════════════════════════════════════════════════

Color _parseHex(String hex, {required Color fallback}) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    final value = int.tryParse('FF$h', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

Color _resolvePrimaryColor({
  required String primaryColorHex,
  required String malePrimaryColorHex,
  required bool isMale,
}) {
  final hex = isMale ? malePrimaryColorHex : primaryColorHex;
  return _parseHex(hex,
      fallback: isMale ? const Color(0xFF1565C0) : const Color(0xFFD16F9A));
}

Color _resolveMainWidgetColor(HomeCmsState homeState) {
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

/// Country → cities map. Each entry: {'key': id, 'value_en': ..., 'value_ar': ...}
const Map<String, List<Map<String, String>>> _kCitiesByCountry = {
  'egypt': [
    {'key': 'cairo',          'value_en': 'Cairo',            'value_ar': 'القاهرة'},
    {'key': 'alexandria',     'value_en': 'Alexandria',       'value_ar': 'الإسكندرية'},
    {'key': 'giza',           'value_en': 'Giza',             'value_ar': 'الجيزة'},
    {'key': 'sharm',          'value_en': 'Sharm El-Sheikh',  'value_ar': 'شرم الشيخ'},
    {'key': 'hurghada',       'value_en': 'Hurghada',         'value_ar': 'الغردقة'},
    {'key': 'luxor',          'value_en': 'Luxor',            'value_ar': 'الأقصر'},
    {'key': 'aswan',          'value_en': 'Aswan',            'value_ar': 'أسوان'},
    {'key': 'mansoura',       'value_en': 'Mansoura',         'value_ar': 'المنصورة'},
    {'key': 'tanta',          'value_en': 'Tanta',            'value_ar': 'طنطا'},
    {'key': 'zagazig',        'value_en': 'Zagazig',          'value_ar': 'الزقازيق'},
    {'key': 'ismailia',       'value_en': 'Ismailia',         'value_ar': 'الإسماعيلية'},
    {'key': 'suez',           'value_en': 'Suez',             'value_ar': 'السويس'},
    {'key': 'port_said',      'value_en': 'Port Said',        'value_ar': 'بورسعيد'},
    {'key': 'new_cairo',      'value_en': 'New Cairo',        'value_ar': 'القاهرة الجديدة'},
    {'key': '6th_october',    'value_en': '6th of October',   'value_ar': 'السادس من أكتوبر'},
  ],
  'saudi_arabia': [
    {'key': 'riyadh',         'value_en': 'Riyadh',           'value_ar': 'الرياض'},
    {'key': 'jeddah',         'value_en': 'Jeddah',           'value_ar': 'جدة'},
    {'key': 'mecca',          'value_en': 'Mecca',            'value_ar': 'مكة المكرمة'},
    {'key': 'medina',         'value_en': 'Medina',           'value_ar': 'المدينة المنورة'},
    {'key': 'dammam',         'value_en': 'Dammam',           'value_ar': 'الدمام'},
    {'key': 'khobar',         'value_en': 'Al Khobar',        'value_ar': 'الخبر'},
    {'key': 'dhahran',        'value_en': 'Dhahran',          'value_ar': 'الظهران'},
    {'key': 'tabuk',          'value_en': 'Tabuk',            'value_ar': 'تبوك'},
    {'key': 'abha',           'value_en': 'Abha',             'value_ar': 'أبها'},
    {'key': 'najran',         'value_en': 'Najran',           'value_ar': 'نجران'},
    {'key': 'hail',           'value_en': 'Hail',             'value_ar': 'حائل'},
    {'key': 'jubail',         'value_en': 'Jubail',           'value_ar': 'الجبيل'},
    {'key': 'yanbu',          'value_en': 'Yanbu',            'value_ar': 'ينبع'},
    {'key': 'taif',           'value_en': 'Taif',             'value_ar': 'الطائف'},
    {'key': 'qassim',         'value_en': 'Qassim',           'value_ar': 'القصيم'},
  ],
  'uae': [
    {'key': 'dubai',          'value_en': 'Dubai',            'value_ar': 'دبي'},
    {'key': 'abu_dhabi',      'value_en': 'Abu Dhabi',        'value_ar': 'أبوظبي'},
    {'key': 'sharjah',        'value_en': 'Sharjah',          'value_ar': 'الشارقة'},
    {'key': 'ajman',          'value_en': 'Ajman',            'value_ar': 'عجمان'},
    {'key': 'rak',            'value_en': 'Ras Al Khaimah',   'value_ar': 'رأس الخيمة'},
    {'key': 'fujairah',       'value_en': 'Fujairah',         'value_ar': 'الفجيرة'},
    {'key': 'umm_quwain',     'value_en': 'Umm Al Quwain',    'value_ar': 'أم القيوين'},
    {'key': 'al_ain',         'value_en': 'Al Ain',           'value_ar': 'العين'},
  ],
  'kuwait': [
    {'key': 'kuwait_city',    'value_en': 'Kuwait City',      'value_ar': 'مدينة الكويت'},
    {'key': 'hawalli',        'value_en': 'Hawalli',          'value_ar': 'حولي'},
    {'key': 'salmiya',        'value_en': 'Salmiya',          'value_ar': 'السالمية'},
    {'key': 'farwaniya',      'value_en': 'Farwaniya',        'value_ar': 'الفروانية'},
    {'key': 'ahmadi',         'value_en': 'Ahmadi',           'value_ar': 'الأحمدي'},
    {'key': 'jahra',          'value_en': 'Al Jahra',         'value_ar': 'الجهراء'},
    {'key': 'mubarak',        'value_en': 'Mubarak Al-Kabeer','value_ar': 'مبارك الكبير'},
  ],
  'qatar': [
    {'key': 'doha',           'value_en': 'Doha',             'value_ar': 'الدوحة'},
    {'key': 'al_rayyan',      'value_en': 'Al Rayyan',        'value_ar': 'الريان'},
    {'key': 'al_wakrah',      'value_en': 'Al Wakrah',        'value_ar': 'الوكرة'},
    {'key': 'al_khor',        'value_en': 'Al Khor',          'value_ar': 'الخور'},
    {'key': 'lusail',         'value_en': 'Lusail',           'value_ar': 'لوسيل'},
    {'key': 'al_shamal',      'value_en': 'Al Shamal',        'value_ar': 'الشمال'},
    {'key': 'umm_salal',      'value_en': 'Umm Salal',        'value_ar': 'أم صلال'},
  ],
  'bahrain': [
    {'key': 'manama',         'value_en': 'Manama',           'value_ar': 'المنامة'},
    {'key': 'muharraq',       'value_en': 'Muharraq',         'value_ar': 'المحرق'},
    {'key': 'riffa',          'value_en': 'Riffa',            'value_ar': 'الرفاع'},
    {'key': 'hamad_town',     'value_en': 'Hamad Town',       'value_ar': 'مدينة حمد'},
    {'key': 'isa_town',       'value_en': 'Isa Town',         'value_ar': 'مدينة عيسى'},
    {'key': 'sitra',          'value_en': 'Sitra',            'value_ar': 'سترة'},
    {'key': 'budaiya',        'value_en': 'Budaiya',          'value_ar': 'البديع'},
  ],
  'jordan': [
    {'key': 'amman',          'value_en': 'Amman',            'value_ar': 'عمّان'},
    {'key': 'zarqa',          'value_en': 'Zarqa',            'value_ar': 'الزرقاء'},
    {'key': 'irbid',          'value_en': 'Irbid',            'value_ar': 'إربد'},
    {'key': 'aqaba',          'value_en': 'Aqaba',            'value_ar': 'العقبة'},
    {'key': 'salt',           'value_en': 'Salt',             'value_ar': 'السلط'},
    {'key': 'madaba',         'value_en': 'Madaba',           'value_ar': 'مادبا'},
    {'key': 'jerash',         'value_en': 'Jerash',           'value_ar': 'جرش'},
    {'key': 'karak',          'value_en': 'Karak',            'value_ar': 'الكرك'},
  ],
  'lebanon': [
    {'key': 'beirut',         'value_en': 'Beirut',           'value_ar': 'بيروت'},
    {'key': 'tripoli_lb',     'value_en': 'Tripoli',          'value_ar': 'طرابلس'},
    {'key': 'sidon',          'value_en': 'Sidon',            'value_ar': 'صيدا'},
    {'key': 'tyre',           'value_en': 'Tyre',             'value_ar': 'صور'},
    {'key': 'jounieh',        'value_en': 'Jounieh',          'value_ar': 'جونيه'},
    {'key': 'zahle',          'value_en': 'Zahle',            'value_ar': 'زحلة'},
    {'key': 'baalbek',        'value_en': 'Baalbek',          'value_ar': 'بعلبك'},
  ],
};

List<Map<String, String>> _citiesForCountry(String? countryKey, bool isAr) {
  if (countryKey == null || countryKey.isEmpty) return [];
  final raw = _kCitiesByCountry[countryKey] ?? [];
  return raw.map((e) => {
    'key':   e['key']!,
    'value': isAr ? e['value_ar']! : e['value_en']!,
  }).toList();
}

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
  return raw.map((e) => {
    'key':   e['key']!,
    'value': isAr ? e['value_ar']! : e['value_en']!,
  }).toList();
}

// ════════════════════════════════════════════════════════════════════════════
// LOCALIZED STRINGS
// ════════════════════════════════════════════════════════════════════════════
