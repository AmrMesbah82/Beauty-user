part of '../../pages/contact_us_page.dart';

class _MobileIconDropdown extends StatelessWidget {
  final String hint, iconPath;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool submitted, isRtl;
  final Color primaryColor;

  const _MobileIconDropdown({
    required this.hint,
    required this.iconPath,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.submitted,
    required this.isRtl,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && (value == null || value!.isEmpty);
    final String errMsg = isRtl ? 'هذا الحقل مطلوب' : 'This field is required';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownFormFieldInvMaster(
          selectedValue: value,
          items: items,
          onChanged: onChanged,
          widthIcon: 18,
          heightIcon: 18,
          iconPath: iconPath,
          primaryColor: primaryColor,
          dropdownColor: const Color(0xFFF5F5F5),
          width: double.infinity,
          height: 46,
          borderRadius: 8,
          hint: Text(
            hint,
            style: StyleText.fontSize12Weight400.copyWith(
              color: Colors.grey.shade400,
              fontSize: 12.sp,
            ),
          ),
        ),
        if (showError) ...[
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errMsg,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEMO-STYLE MOBILE PHONE FIELD
// Matches request_demo_page.dart phone field style:
//   • Label row: SVG icon + label text
//   • Code picker box (rounded) + number TextField side by side
// ═══════════════════════════════════════════════════════════════════════════════
