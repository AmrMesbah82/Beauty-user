part of '../../pages/contact_us_page.dart';

class _DropdownField extends StatelessWidget {
  final String label, hint;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool submitted, isRtl, isMobile, isSearchable;
  final Color primaryColor;
  final String? iconPath;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.submitted,
    required this.isRtl,
    required this.isMobile,
    required this.primaryColor,
    this.isSearchable = false,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && (value == null || value!.isEmpty);
    final String requiredMsg = _t(
      context,
      en: 'This field is required',
      ar: 'هذا الحقل مطلوب',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormLabel(label: label, isRtl: isRtl), // ← pass isRtl
        SizedBox(height: 3.h),
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items: items,
          onChanged: onChanged,
          width: double.infinity,
          height: 44,           // ← increased height
          dropdownColor: const Color(0xFFF5F5F5),
          borderRadius: 4,
          widthIcon: 16,
          heightIcon: 16,
          iconPath: iconPath,
          primaryColor: primaryColor,
          textDirection: isRtl   // ← ADD THIS
              ? TextDirection.rtl
              : TextDirection.ltr,
          hint: Text(
            hint,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryBlack,
            ),
            textDirection:        // ← ADD THIS
            isRtl ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        if (showError) ...[
          SizedBox(height: 2.h),
          Text(
            requiredMsg,
            style: StyleText.fontSize12Weight400.copyWith(
              color: Colors.red,
              fontSize: 11.sp,
            ),
            textAlign: isRtl ? TextAlign.right : TextAlign.left, // ← FIX
            textDirection:                                         // ← FIX
            isRtl ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
        SizedBox(height: 2.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO-STYLE PHONE FIELD (Desktop/Tablet)
// Matches the phone field from request_demo_page.dart:
//   • Label row with leading SVG icon
//   • Code picker in a separate rounded box on the left
//   • Text field fills the remaining width
// ═══════════════════════════════════════════════════════════════════════════════
