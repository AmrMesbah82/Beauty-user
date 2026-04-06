// ******************* FILE INFO *******************
// File Name: our_products_page.dart
// Description: "Our Products" page for the Beauty App (Bayanatz).
//              Two tabs: Client Service & Owner Service.
//              All data is STATIC (not from Firebase).
//              All images use SvgPicture.asset() for .svg files.
//              Image positions match Figma: left, center, or right per section.
// Created by: Claude for Amr Mesbah
// Uses: CustomSegmentedTabs, AppPageShell, SvgPicture.asset()

import 'package:beauty_user/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../core/custom_tab.dart';
import '../theme/appcolors.dart';
import '../widgets/app_page_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — parse hex color from branding
// ─────────────────────────────────────────────────────────────────────────────

Color _parseHex(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT ENUM — controls image position per section
// ─────────────────────────────────────────────────────────────────────────────

enum _SectionLayout {
  /// Text LEFT, Image RIGHT (side-by-side)
  imageRight,

  /// Image LEFT, Text RIGHT (side-by-side)
  imageLeft,

  /// Image CENTER (above), Text CENTER (below) — stacked
  imageCenter,
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ProductSection {
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final String svgAsset;
  final _SectionLayout layout;

  const _ProductSection({
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.svgAsset,
    required this.layout,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT SERVICE — static sections data
// ─────────────────────────────────────────────────────────────────────────────

const List<_ProductSection> _clientSections = [
  // 1 — Our Services (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Our Services',
    titleAr: 'خدماتنا',
    bodyEn:
    'Beauty App, It provides you with many salons according to your '
        'geographical location with various services and prices, and you can '
        'choose what suits you according to your budget, and some salons '
        'also provide services at home.',
    bodyAr:
    'تطبيق Beauty، يوفر لك العديد من الصالونات حسب موقعك الجغرافي '
        'بخدمات وأسعار متنوعة، ويمكنك اختيار ما يناسبك حسب ميزانيتك، '
        'وبعض الصالونات توفر خدمات منزلية أيضًا.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 2 — View Salons & Offers (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'View Salons & Offers',
    titleAr: 'عرض الصالونات والعروض',
    bodyEn:
    'Our application provides a variety of salons according to your location and '
        'determines how far away from you and its evaluation and shows many '
        'discounts on services and products have and some of these salons provide '
        'services at home.',
    bodyAr:
    'يوفر تطبيقنا مجموعة متنوعة من الصالونات حسب موقعك ويحدد بُعدها '
        'عنك وتقييمها ويعرض العديد من الخصومات على الخدمات والمنتجات، '
        'وبعض هذه الصالونات توفر خدمات منزلية.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 3 — Location (image CENTER, text CENTER)
  _ProductSection(
    titleEn: 'Location',
    titleAr: 'الموقع',
    bodyEn:
    'You can change your geographical location and save many of your geographical '
        'locations and change them, which leads to a difference in the salons displayed.',
    bodyAr:
    'يمكنك تغيير موقعك الجغرافي وحفظ العديد من مواقعك الجغرافية '
        'وتغييرها، مما يؤدي إلى اختلاف الصالونات المعروضة.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageCenter,
  ),

  // 4 — Salon Profile (image LEFT, text RIGHT)
  _ProductSection(
    titleEn: 'Salon Profile',
    titleAr: 'ملف الصالون',
    bodyEn:
    'You can see the salon, its type (women\'s or men\'s), address, rating, distance, '
        'appointment, photos of some of its works and the availability of its services at home.\n\n'
        'You can also communicate with him via social media, call or messages via the '
        'application.',
    bodyAr:
    'يمكنك رؤية الصالون ونوعه (نسائي أو رجالي) وعنوانه وتقييمه ومسافته '
        'ومواعيده وصور بعض أعماله ومدى توفر خدماته المنزلية.\n\n'
        'يمكنك أيضًا التواصل معه عبر وسائل التواصل الاجتماعي أو الاتصال أو الرسائل عبر التطبيق.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageLeft,
  ),

  // 5 — Services (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Services',
    titleAr: 'الخدمات',
    bodyEn:
    'When you log in to the salon page, you can see all its services '
        'according to their classification(skin, hair and nails .... Etc.), the '
        'price of each of them, their rating, the time they take, some '
        'instructions, affiliate specialists and customer opinions.',
    bodyAr:
    'عند دخولك صفحة الصالون، يمكنك رؤية جميع خدماته حسب تصنيفها '
        '(بشرة، شعر، أظافر... إلخ)، سعر كل منها، تقييمها، الوقت الذي تستغرقه، '
        'بعض التعليمات، الأخصائيين المعتمدين وآراء العملاء.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 6 — Specialists (image CENTER, text CENTER)
  _ProductSection(
    titleEn: 'Specialists',
    titleAr: 'المتخصصون',
    bodyEn:
    'You can see all the specialists in the salon or see the specialists for each service, '
        'their ratings, prices, years of experience, the availability of the service at home, '
        'see some of their works and customer reviews.',
    bodyAr:
    'يمكنك رؤية جميع المتخصصين في الصالون أو رؤية المتخصصين لكل خدمة، '
        'تقييماتهم، أسعارهم، سنوات خبرتهم، مدى توفر الخدمة المنزلية، '
        'ورؤية بعض أعمالهم وآراء العملاء.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageCenter,
  ),

  // 7 — Products (image LEFT, text RIGHT)
  _ProductSection(
    titleEn: 'Products',
    titleAr: 'المنتجات',
    bodyEn:
    'You can see all the products for each salon by their rating, Price, rating and if there '
        'are offers on them, you can also see their description, ingredients, method of use, '
        'purpose and customer opinions.',
    bodyAr:
    'يمكنك رؤية جميع منتجات كل صالون حسب تقييمها وسعرها وإذا كانت '
        'هناك عروض عليها، ويمكنك أيضًا رؤية وصفها ومكوناتها وطريقة الاستخدام '
        'والغرض منها وآراء العملاء.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageLeft,
  ),

  // 8 — Reviews (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Reviews',
    titleAr: 'التقييمات',
    bodyEn:
    'You can see all the reviews and customer opinions at the salon, service and '
        'service specialist levels to have a comprehensive and clear vision.',
    bodyAr:
    'يمكنك رؤية جميع التقييمات وآراء العملاء على مستوى الصالون والخدمة '
        'والأخصائي للحصول على رؤية شاملة وواضحة.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 9 — Booking (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Booking',
    titleAr: 'الحجز',
    bodyEn:
    'You will enjoy the ease of booking, whether you book a service if you like, '
        'whether it is inside the salon or at home. You can select the services you want '
        'and choose the specialist for each service, date and time, and you can also set '
        'an alarm to remind you of the re-booking.',
    bodyAr:
    'ستستمتع بسهولة الحجز، سواء حجزت خدمة تعجبك داخل الصالون أو في المنزل. '
        'يمكنك اختيار الخدمات التي تريدها واختيار الأخصائي لكل خدمة والتاريخ والوقت، '
        'ويمكنك أيضًا ضبط تنبيه لتذكيرك بإعادة الحجز.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 10 — History (image LEFT, text RIGHT)
  _ProductSection(
    titleEn: 'History',
    titleAr: 'السجل',
    bodyEn:
    'The application allows you to save all your future bookings, whether you can '
        'modify their date, affiliated specialist, canceled, completed or canceled, and also '
        'saves your ratings for each booking.',
    bodyAr:
    'يتيح لك التطبيق حفظ جميع حجوزاتك المستقبلية، سواء كنت تستطيع تعديل '
        'تاريخها أو الأخصائي المرتبط بها أو إلغاؤها أو إكمالها، كما يحفظ تقييماتك لكل حجز.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageLeft,
  ),

  // 11 — Messages (image CENTER, text CENTER)
  _ProductSection(
    titleEn: 'Messages',
    titleAr: 'الرسائل',
    bodyEn:
    'You can contact the salon for inquiries, to book an appointment or to solve any problem.',
    bodyAr:
    'يمكنك التواصل مع الصالون للاستفسارات أو لحجز موعد أو لحل أي مشكلة.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageCenter,
  ),

  // 12 — Saved (image LEFT, text RIGHT)
  _ProductSection(
    titleEn: 'Saved',
    titleAr: 'المحفوظات',
    bodyEn:
    'You can save any service or any Salon you like or want to try in your own '
        'section, whether you have a coupon according to your desire or the application '
        'has saved and automatically divided.',
    bodyAr:
    'يمكنك حفظ أي خدمة أو أي صالون تعجبك أو تريد تجربته في قسمك الخاص، '
        'سواء كان لديك قسيمة حسب رغبتك أو قام التطبيق بالحفظ والتقسيم تلقائيًا.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageLeft,
  ),

  // 13 — Invoices (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Invoices',
    titleAr: 'الفواتير',
    bodyEn:
    'The application allows sending your invoices and classifying them if they '
        'were paid or not, or payment failed, and so on.',
    bodyAr:
    'يتيح التطبيق إرسال فواتيرك وتصنيفها إذا كانت مدفوعة أم لا أو فشل الدفع وما إلى ذلك.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// OWNER SERVICE — static sections data
// ─────────────────────────────────────────────────────────────────────────────

const List<_ProductSection> _ownerSections = [
  // 1 — Our Services (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Our Services',
    titleAr: 'خدماتنا',
    bodyEn:
    'The beauty application, helps you manage your salon with ease by '
        'following up all bookings, customer reviews, all the work of '
        'employees and products of the salon, if any.',
    bodyAr:
    'تطبيق التجميل يساعدك في إدارة صالونك بسهولة من خلال متابعة '
        'جميع الحجوزات ومراجعات العملاء وجميع أعمال الموظفين ومنتجات الصالون إن وجدت.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 2 — Dashboard (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Dashboard',
    titleAr: 'لوحة التحكم',
    bodyEn:
    'The application helps the salon owner in managing the salon by displaying a '
        'dashboard with all the salon information and statistics for bookings, employees '
        'and customers.',
    bodyAr:
    'يساعد التطبيق صاحب الصالون في إدارة الصالون من خلال عرض لوحة تحكم '
        'بجميع معلومات وإحصائيات الصالون للحجوزات والموظفين والعملاء.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 3 — Employees (image CENTER, text CENTER)
  _ProductSection(
    titleEn: 'Employees',
    titleAr: 'الموظفون',
    bodyEn:
    'There is a special section for employees of the salon and all their information, '
        'the tasks they performed, their working hours and their assessment by the clients.',
    bodyAr:
    'يوجد قسم خاص لموظفي الصالون وجميع معلوماتهم والمهام التي أدوها '
        'وساعات عملهم وتقييمهم من قبل العملاء.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageCenter,
  ),

  // 4 — Calendar (image RIGHT, text LEFT)
  _ProductSection(
    titleEn: 'Calendar',
    titleAr: 'التقويم',
    bodyEn:
    'There is a Callender to track daily bookings made, not made and canceled '
        'according to each service and each service provider.',
    bodyAr:
    'يوجد تقويم لتتبع الحجوزات اليومية التي تمت أو لم تتم أو تم إلغاؤها '
        'حسب كل خدمة وكل مقدم خدمة.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 5 — Booking (image LEFT, text RIGHT)
  _ProductSection(
    titleEn: 'Booking',
    titleAr: 'الحجز',
    bodyEn:
    'The application helps the owner in following up customer reservations, '
        'whether in the salon or at home, and also allows him the ability to modify '
        'the reservation or cancel.',
    bodyAr:
    'يساعد التطبيق المالك في متابعة حجوزات العملاء سواء في الصالون أو في المنزل، '
        'كما يتيح له القدرة على تعديل الحجز أو إلغائه.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageLeft,
  ),

  // 6 — Notifications (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Notifications',
    titleAr: 'الإشعارات',
    bodyEn:
    'The owner is allowed to send notifications to salon workers or '
        'customers for various purposes, whether reminding an '
        'appointment, sending an invoice or other...',
    bodyAr:
    'يُسمح للمالك بإرسال إشعارات لعمال الصالون أو العملاء لأغراض مختلفة، '
        'سواء التذكير بموعد أو إرسال فاتورة أو غير ذلك...',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 7 — Promotions (image LEFT, text RIGHT)
  _ProductSection(
    titleEn: 'Promotions',
    titleAr: 'العروض الترويجية',
    bodyEn:
    'The owner is allowed to send promotional offers to all customers or special '
        'customers of the service provider, and he can also choose the display method, color '
        'and other.',
    bodyAr:
    'يُسمح للمالك بإرسال عروض ترويجية لجميع العملاء أو عملاء مقدم الخدمة المميزين، '
        'ويمكنه أيضًا اختيار طريقة العرض واللون وغير ذلك.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageLeft,
  ),

  // 8 — Messages (image CENTER, text CENTER)
  _ProductSection(
    titleEn: 'Messages',
    titleAr: 'الرسائل',
    bodyEn:
    'There is a Messages section to communicate with the salon staff or customers to respond to inquiries or receive '
        'reservations or complaints, there are also groups for employees and customers to send offers or follow up.',
    bodyAr:
    'يوجد قسم رسائل للتواصل مع طاقم الصالون أو العملاء للرد على الاستفسارات '
        'أو استقبال الحجوزات أو الشكاوى، وهناك أيضًا مجموعات للموظفين والعملاء لإرسال العروض أو المتابعة.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageCenter,
  ),

  // 9 — Schedule Message (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Schedule Message',
    titleAr: 'جدولة الرسائل',
    bodyEn:
    'There is a feature that makes it easier for the owner to send messages by '
        'scheduling messages and sending them at the specified time and time.',
    bodyAr:
    'توجد ميزة تسهل على المالك إرسال الرسائل عن طريق جدولتها وإرسالها في الوقت المحدد.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 10 — Salon Settings (image LEFT, text RIGHT)
  _ProductSection(
    titleEn: 'Salon Settings',
    titleAr: 'إعدادات الصالون',
    bodyEn:
    'The owner can control the salon through the settings that enable him to enter '
        'salon information, location, branches, services, employees, business Photos, '
        'control colors and add social media links.',
    bodyAr:
    'يمكن للمالك التحكم في الصالون من خلال الإعدادات التي تمكنه من إدخال '
        'معلومات الصالون والموقع والفروع والخدمات والموظفين وصور العمل '
        'والتحكم في الألوان وإضافة روابط التواصل الاجتماعي.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageLeft,
  ),

  // 11 — Appointment Role Management (text LEFT, image RIGHT)
  _ProductSection(
    titleEn: 'Appointment Role Management',
    titleAr: 'إدارة أدوار المواعيد',
    bodyEn:
    'The owner can appoint one of the employees on his behalf to do the work of the '
        'salon by creating an email and a temporary password that can be changed later.',
    bodyAr:
    'يمكن للمالك تعيين أحد الموظفين نيابة عنه للقيام بعمل الصالون '
        'عن طريق إنشاء بريد إلكتروني وكلمة مرور مؤقتة يمكن تغييرها لاحقًا.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageRight,
  ),

  // 12 — Salon (image CENTER, text CENTER)
  _ProductSection(
    titleEn: 'Salon',
    titleAr: 'الصالون',
    bodyEn:
    'The owner can add all the services inside the salon and divide them into sections, '
        'how many can add the products of the salon if they exist.',
    bodyAr:
    'يمكن للمالك إضافة جميع الخدمات داخل الصالون وتقسيمها إلى أقسام، '
        'ويمكنه إضافة منتجات الصالون إن وجدت.',
    svgAsset: 'assets/images/dashboard_image.svg',
    layout: _SectionLayout.imageCenter,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// OUR PRODUCTS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class OurProductsPage extends StatefulWidget {
  const OurProductsPage({super.key});

  @override
  State<OurProductsPage> createState() => _OurProductsPageState();
}

class _OurProductsPageState extends State<OurProductsPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final data = switch (homeState) {
          HomeCmsLoaded(:final data) => data,
          HomeCmsSaved(:final data) => data,
          HomeCmsSaving(:final data) => data,
          HomeCmsError(:final lastData) => lastData,
          _ => null,
        };

        final primaryColor = data != null
            ? _parseHex(data.branding.primaryColor, fallback: AppColors.primary)
            : AppColors.primary;

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isAr = langState.isArabic;

            final sections = _selectedTabIndex == 0
                ? _clientSections
                : _ownerSections;

            return AppPageShell(
              currentRoute: '/about',
              body: Column(
                children: [
                  SizedBox(height: 24.h),

                  // ═══════════════════════════════════════════════════════
                  // SEGMENTED TABS — Client Service / Owner Service
                  // ═══════════════════════════════════════════════════════
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Center(
                      child: SizedBox(
                        width: 400.w,
                        child: CustomSegmentedTabs(
                          tabs: isAr
                              ? ['خدمة العميل', 'خدمة المالك']
                              : ['Client Service', 'Owner Service'],
                          selectedIndex: _selectedTabIndex,
                          onTabSelected: (index) {
                            setState(() => _selectedTabIndex = index);
                          },
                          selectedColor: primaryColor,
                          equalWidth: true,
                          spacing: 0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // ═══════════════════════════════════════════════════════
                  // FIRST SECTION — "Our Services" heading + image
                  // ═══════════════════════════════════════════════════════
                  _ProductSectionWidget(
                    section: sections[0],
                    primaryColor: primaryColor,
                    isAr: isAr,
                  ),

                  // ═══════════════════════════════════════════════════════
                  // DOWNLOAD NOW BAR
                  // ═══════════════════════════════════════════════════════
                  _DownloadNowBar(
                    primaryColor: primaryColor,
                    label: isAr ? 'حمّل الآن' : 'Download Now',
                  ),

                  SizedBox(height: 30.h),

                  // ═══════════════════════════════════════════════════════
                  // REMAINING SECTIONS (index 1+)
                  // ═══════════════════════════════════════════════════════
                  ...List.generate(
                    sections.length - 1,
                        (i) => Padding(
                      padding: EdgeInsets.only(bottom: 30.h),
                      child: _ProductSectionWidget(
                        section: sections[i + 1],
                        primaryColor: primaryColor,
                        isAr: isAr,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOWNLOAD NOW BAR
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadNowBar extends StatelessWidget {
  final Color primaryColor;
  final String label;

  const _DownloadNowBar({
    required this.primaryColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: primaryColor,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 10.w,
            children: [
              _MiniStoreBadge(
                svgAsset: 'assets/beauty/home/google_play.svg',
                onTap: () {
                  // TODO: launch Google Play URL
                },
              ),
              _MiniStoreBadge(
                svgAsset: 'assets/beauty/home/app_store.svg',
                onTap: () {
                  // TODO: launch App Store URL
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStoreBadge extends StatelessWidget {
  final String svgAsset;
  final VoidCallback? onTap;

  const _MiniStoreBadge({required this.svgAsset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: SvgPicture.asset(
          svgAsset,
          height: 36.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT SECTION WIDGET — handles all 3 layouts
// ─────────────────────────────────────────────────────────────────────────────

class _ProductSectionWidget extends StatelessWidget {
  final _ProductSection section;
  final Color primaryColor;
  final bool isAr;

  const _ProductSectionWidget({
    required this.section,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final title = isAr ? section.titleAr : section.titleEn;
    final body = isAr ? section.bodyAr : section.bodyEn;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          switch (section.layout) {
          // ── IMAGE CENTER (stacked: image above, text below) ──
            case _SectionLayout.imageCenter:
              return _CenterLayout(
                title: title,
                body: body,
                svgAsset: section.svgAsset,
                primaryColor: primaryColor,
              );

          // ── IMAGE RIGHT (text left, image right) ──
            case _SectionLayout.imageRight:
              if (!isWide) {
                return _StackedFallback(
                  title: title,
                  body: body,
                  svgAsset: section.svgAsset,
                  primaryColor: primaryColor,
                );
              }
              return _SideBySideLayout(
                title: title,
                body: body,
                svgAsset: section.svgAsset,
                primaryColor: primaryColor,
                imageOnLeft: false,
              );

          // ── IMAGE LEFT (image left, text right) ──
            case _SectionLayout.imageLeft:
              if (!isWide) {
                return _StackedFallback(
                  title: title,
                  body: body,
                  svgAsset: section.svgAsset,
                  primaryColor: primaryColor,
                );
              }
              return _SideBySideLayout(
                title: title,
                body: body,
                svgAsset: section.svgAsset,
                primaryColor: primaryColor,
                imageOnLeft: true,
              );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CENTER LAYOUT — image on top, text below (centered)
// ─────────────────────────────────────────────────────────────────────────────

class _CenterLayout extends StatelessWidget {
  final String title;
  final String body;
  final String svgAsset;
  final Color primaryColor;

  const _CenterLayout({
    required this.title,
    required this.body,
    required this.svgAsset,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Image ──
        SvgPicture.asset(
          svgAsset,
          height: 280.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 20.h),

        // ── Title ──
        Text(
          title,
          style: AppTextStyles.font20BlackCairoSemiBold,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),

        // ── Body ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            body,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
              height: 1.7,
              color: AppColors.secondaryBlack,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDE-BY-SIDE LAYOUT — image left or right
// ─────────────────────────────────────────────────────────────────────────────

class _SideBySideLayout extends StatelessWidget {
  final String title;
  final String body;
  final String svgAsset;
  final Color primaryColor;
  final bool imageOnLeft;

  const _SideBySideLayout({
    required this.title,
    required this.body,
    required this.svgAsset,
    required this.primaryColor,
    required this.imageOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = SvgPicture.asset(
      svgAsset,
      height: 280.h,
      fit: BoxFit.contain,
    );

    final textWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          body,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            height: 1.7,
            color: AppColors.secondaryBlack,
          ),
        ),
      ],
    );

    if (imageOnLeft) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: imageWidget),
          SizedBox(width: 30.w),
          Expanded(flex: 6, child: textWidget),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: textWidget),
        SizedBox(width: 30.w),
        Expanded(flex: 4, child: imageWidget),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STACKED FALLBACK — for narrow screens (image above, text below)
// ─────────────────────────────────────────────────────────────────────────────

class _StackedFallback extends StatelessWidget {
  final String title;
  final String body;
  final String svgAsset;
  final Color primaryColor;

  const _StackedFallback({
    required this.title,
    required this.body,
    required this.svgAsset,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SvgPicture.asset(
            svgAsset,
            height: 250.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: AppTextStyles.font20BlackCairoSemiBold.copyWith(
            color: primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          body,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            height: 1.7,
            color: AppColors.secondaryBlack,
          ),
        ),
      ],
    );
  }
}