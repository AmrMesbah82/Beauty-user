part of '../../pages/request_page.dart';

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
  String get selectCountry => isAr ? 'اختر الدولة أولاً'             : 'Select country first';
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
