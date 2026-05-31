part of '../../pages/request_page.dart';

class _Inner extends StatelessWidget {
  final String gender;
  const _Inner({required this.gender});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final bool isAr = langState.isArabic;

        return BlocBuilder<HomeCmsCubit, HomeCmsState>(
          builder: (context, homeState) {
            return BlocBuilder<GenderCubit, GenderState>(
              builder: (context, genderState) {
                final bool isMale = genderState.isMale;

                final Color primaryColor = switch (homeState) {
                  HomeCmsLoaded(:final data) => _resolvePrimaryColor(
                    primaryColorHex: data.branding.primaryColor,
                    malePrimaryColorHex: data.branding.malePrimaryColor,
                    isMale: isMale,
                  ),
                  HomeCmsSaved(:final data) => _resolvePrimaryColor(
                    primaryColorHex: data.branding.primaryColor,
                    malePrimaryColorHex: data.branding.malePrimaryColor,
                    isMale: isMale,
                  ),
                  _ => isMale ? _C.primaryMale : _C.primaryFemale,
                };

                final Color mainWidgetColor = _resolveMainWidgetColor(homeState);

                return BlocBuilder<RequestDemoCmsCubit, RequestDemoCmsState>(
                  builder: (ctx, cmsState) {
                    if (cmsState is RequestDemoCmsInitial ||
                        cmsState is RequestDemoCmsLoading) {
                      return Scaffold(
                        backgroundColor: _C.back,
                        body: Center(
                            child: CircularProgressIndicator(color: primaryColor)),
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
                          return _ConfirmScreen(
                            model: m!,
                            isAr: isAr,
                            primaryColor: primaryColor,
                            mainWidgetColor: mainWidgetColor,
                          );
                        }
                        return _FormScreen(
                          model:           m!,
                          gender:          gender,
                          isLoading:       submitState is _SubmitLoading,
                          isAr:            isAr,
                          primaryColor:    primaryColor,
                          mainWidgetColor: mainWidgetColor,
                        );
                      },
                    );
                  },
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
