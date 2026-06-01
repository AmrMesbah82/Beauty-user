part of '../../pages/request_page.dart';

class _ConfirmScreen extends StatelessWidget {
  final RequestDemoPageModel model;
  final bool isAr;
  final Color primaryColor;
  final Color mainWidgetColor;

  const _ConfirmScreen({
    required this.model,
    required this.isAr,
    required this.primaryColor,
    required this.mainWidgetColor,
  });

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
        ? (isAr ? model.confirmDescription.ar : model.confirmDescription.en)
        : str.confirmDesc;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Container(
              width:   double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color:        mainWidgetColor,
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
                        size: 80.sp, color: primaryColor),

                  SizedBox(height: 24.h),

                  Text(title,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize20Weight600.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700)),

                  SizedBox(height: 12.h),

                  Text(desc,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: const Color(0xFF333333), height: 1.6)),

                  SizedBox(height: 32.h),

                  SizedBox(
                    width:  double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () => context.read<_SubmitCubit>().reset(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        elevation:       0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(str.submitAnother,
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: primaryColor)),
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
