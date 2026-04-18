/// ******************* FILE INFO *******************
/// File Name: owner_services_main_page.dart
/// Description: Main (read-only) page for Owner Services CMS.
///              Shows: Header, Download Applications, Mockups sections
///              with Female/Male toggle, Last Updated timestamp,
///              Edit Owner View & Preview Screen buttons.
/// Created by: Amr Mesbah
/// Last Update: 10/04/2026

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';



import '../../controller/owner_services/owner_services_cubit.dart';
import '../../controller/owner_services/owner_services_state.dart';
import '../../core/custom_svg.dart';
import '../../core/widget/circle_progress.dart';
import '../../model/owner_services/owner_services_model.dart';
import '../../theme/new_theme.dart';
import 'owner_services_edit_page.dart';
import 'owner_services_preview_page.dart';


class _C {
  static const Color primary   = Color(0xFFD16F9A);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFE0E0E0);
  static const Color labelText = Color(0xFF333333);
  static const Color hintText  = Color(0xFFAAAAAA);
  static const Color back      = Color(0xFFF1F2ED);
}

class OwnerServicesMainPage extends StatefulWidget {
  const OwnerServicesMainPage({super.key});

  @override
  State<OwnerServicesMainPage> createState() => _OwnerServicesMainPageState();
}

class _OwnerServicesMainPageState extends State<OwnerServicesMainPage> {
  // ── Accordion ─────────────────────────────────────────────────────────────
  final Map<String, bool> _open = {
    'header': true,
    'download': true,
    'mockups': true,
  };

  @override
  void initState() {
    super.initState();
    print('[OwnerServicesMainPage] ✅ initState');
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OwnerServicesEditPage(),
      ),
    );
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OwnerServicesPreviewPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerServicesCmsCubit, OwnerServicesCmsState>(
      builder: (context, state) {
        final cubit = context.read<OwnerServicesCmsCubit>();

        if (state is OwnerServicesCmsInitial ||
            state is OwnerServicesCmsLoading) {
          return const Scaffold(
            backgroundColor: _C.back,
            body: Center(
                child: CircularProgressIndicator(color: _C.primary)),
          );
        }

        final data = cubit.current;

        return Scaffold(
          backgroundColor: _C.back,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 1000.w,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title row ─────────────────────────────
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Owner Services Details',
                                  style: StyleText.fontSize45Weight600
                                      .copyWith(
                                      color: _C.primary,
                                      fontWeight: FontWeight.w700)),
                              _previewScreenBtn(),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // ── Gender toggle + Last Updated + Edit ──
                          Row(
                            children: [
                              _genderToggle(cubit),
                              const Spacer(),
                              if (data.lastUpdated != null)
                                Padding(
                                  padding:
                                  EdgeInsets.only(right: 12.w),
                                  child: Text(
                                    'Last Updated On ${DateFormat('dd MMM yyyy').format(data.lastUpdated!)}',
                                    style: StyleText
                                        .fontSize10Weight400
                                        .copyWith(color: _C.primary),
                                  ),
                                ),
                              _editOwnerViewBtn(),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── Header section ───────────────────────
                          _accordionWrap(
                              'header', 'Header', [_headerView(data)]),
                          SizedBox(height: 10.h),

                          // ── Download section ─────────────────────
                          _accordionWrap('download',
                              'Download Applications', [_downloadView(data)]),
                          SizedBox(height: 10.h),

                          // ── Mockups section ──────────────────────
                          _accordionWrap(
                              'mockups', 'Mockups', [_mockupsView(data)]),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Gender toggle ─────────────────────────────────────────────────────────
  Widget _genderToggle(OwnerServicesCmsCubit cubit) {
    return Row(children: [
      _genderPill('Female', cubit.activeGender == 'female', () {
        cubit.switchGender('female');
      }),
      SizedBox(width: 6.w),
      _genderPill('Male', cubit.activeGender == 'male', () {
        cubit.switchGender('male');
      }),
    ]);
  }

  Widget _genderPill(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? _C.primary : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _C.primary),
        ),
        child: Text(label,
            style: StyleText.fontSize10Weight400.copyWith(
                color: active ? Colors.white : _C.primary)),
      ),
    );
  }

  // ── Preview Screen button ─────────────────────────────────────────────────
  Widget _previewScreenBtn() => GestureDetector(
    onTap: _navigateToPreview,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _C.primary,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text('Preview Screen',
          style: StyleText.fontSize12Weight500
              .copyWith(color: Colors.white)),
    ),
  );

  // ── Edit Owner View button ────────────────────────────────────────────────
  Widget _editOwnerViewBtn() => GestureDetector(
    onTap: _navigateToEdit,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Edit Owner View',
            style: StyleText.fontSize12Weight500
                .copyWith(color: _C.labelText)),
        SizedBox(width: 4.w),
        Icon(Icons.edit_outlined,
            size: 14.sp, color: _C.labelText),
      ]),
    ),
  );

  // ── Accordion wrapper ─────────────────────────────────────────────────────
  Widget _accordionWrap(
      String key, String title, List<Widget> children) {
    final isOpen = _open[key] ?? true;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: isOpen
                    ? BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    topRight: Radius.circular(6.r))
                    : BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp),
              ]),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _headerView(OwnerServicesPageModel data) => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _readLabel('SVG'),
          SizedBox(height: 6.h),
          _imgCircleView(data.header.imageUrl),
          SizedBox(height: 12.h),
          _readBiRow('Title', 'العنوان', data.header.title.en,
              data.header.title.ar),
          SizedBox(height: 10.h),
          _readLabel('Description'),
          SizedBox(height: 4.h),
          _readBox(data.header.description.en),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: _readLabel('الوصف'),
          ),
          SizedBox(height: 4.h),
          _readBox(data.header.description.ar,
              textDirection: ui.TextDirection.rtl),
        ]),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _downloadView(OwnerServicesPageModel data) => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _readBiRow('Title', 'العنوان', data.download.title.en,
              data.download.title.ar),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(
                child: _readLabelValue(
                    'Apple Store Link', data.download.appStoreLink)),
            SizedBox(width: 16.w),
            Expanded(
                child: _readLabelValue(
                    'Android Link', data.download.googlePlayLink)),
          ]),
        ]),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCKUPS VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _mockupsView(OwnerServicesPageModel data) => Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
              data.mockups.items.length,
                  (i) => _mockupItemView(data.mockups.items[i], i)),
          if (data.mockups.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text('No mockups added yet.',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: _C.hintText)),
            ),
        ]),
  );

  Widget _mockupItemView(OwnerServicesMockupItemModel item, int i) =>
      Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _readLabel('Mockup ${i + 1}'),
              SizedBox(height: 6.h),
              _readLabel('SVG'),
              SizedBox(height: 4.h),
              Row(
                children: [
                  _imgCircleView(item.imageUrl),
                  SizedBox(width: 16.w),
                  _alignmentDisplay(item.alignment),
                ],
              ),
              SizedBox(height: 10.h),
              _readBiRow('Title', 'العنوان', item.title.en,
                  item.title.ar),
              SizedBox(height: 10.h),
              _readLabel('Description'),
              SizedBox(height: 4.h),
              _readBox(item.description.en),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: _readLabel('الوصف'),
              ),
              SizedBox(height: 4.h),
              _readBox(item.description.ar,
                  textDirection: ui.TextDirection.rtl),
              if (i <
                  (context
                      .read<OwnerServicesCmsCubit>()
                      .current
                      .mockups
                      .items
                      .length -
                      1))
                Divider(height: 24.h, color: _C.border),
            ]),
      );

  Widget _alignmentDisplay(String alignment) {
    return Row(children: [
      for (final a in ['left', 'centered', 'right'])
        Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: Container(
            padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: a == alignment ? _C.primary : Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                  color: a == alignment ? _C.primary : _C.border),
            ),
            child: Text(
              a[0].toUpperCase() + a.substring(1),
              style: StyleText.fontSize10Weight400.copyWith(
                  color: a == alignment ? Colors.white : _C.labelText),
            ),
          ),
        ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED READ-ONLY HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _readLabel(String t) => Text(t,
      style:
      StyleText.fontSize12Weight500.copyWith(color: _C.labelText));

  Widget _readBox(String text,
      {ui.TextDirection textDirection = ui.TextDirection.ltr}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text.isEmpty ? '—' : text,
        textDirection: textDirection,
        style: StyleText.fontSize12Weight400.copyWith(
            color: text.isEmpty ? _C.hintText : _C.labelText),
      ),
    );
  }

  Widget _readBiRow(
      String enLbl, String arLbl, String enVal, String arVal) {
    return Row(children: [
      Expanded(child: _readLabelValue(enLbl, enVal)),
      SizedBox(width: 16.w),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _readLabel(arLbl),
              SizedBox(height: 4.h),
              _readBox(arVal, textDirection: ui.TextDirection.rtl),
            ]),
      ),
    ]);
  }

  Widget _readLabelValue(String label, String value) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _readLabel(label),
          SizedBox(height: 4.h),
          _readBox(value),
        ]);
  }

  Widget _imgCircleView(String url) {
    if (url.isEmpty) {
      return Container(
        width: 70.w,
        height: 70.h,
        decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9), shape: BoxShape.circle),
        child: Center(
            child: CustomSvg(
                assetPath: 'assets/home_control/image.svg',
                width: 20.w,
                height: 20.h,
                fit: BoxFit.fill)),
      );
    }
    return Container(
      width: 70.w,
      height: 70.h,
      decoration:
      const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
          child: ClipOval(
              child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: SvgPicture.network(url,
                      width: 20.w,
                      height: 20.h,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) =>
                      const CircleProgressMaster())))),
    );
  }
}