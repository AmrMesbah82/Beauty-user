part of '../../pages/our_products_page.dart';

class _ClientServiceTab extends StatelessWidget {
  final Color primaryColor;
  final bool isAr;

  const _ClientServiceTab({
    super.key,
    required this.primaryColor,
    required this.isAr,
  });

  Color? _getMainWidgetColor(BuildContext context) {
    final homeState = context.watch<HomeCmsCubit>().state;
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

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<ClientServicesCubit, ClientServicesState>(
      builder: (context, state) {
        if (state is ClientServicesError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 40.w),
            child: Center(
              child: Text(
                state.message,
                style: AppTextStyles.font14BlackCairoRegular.copyWith(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }


        final data = switch (state) {
          ClientServicesLoaded(:final data) => data,
          ClientServicesSaved(:final data) => data,
          _ => context.read<ClientServicesCubit>().current,
        };

        final mockups = data.mockups.items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header hero
            _Reveal(
              delay: const Duration(milliseconds: 80),
              direction: _SlideDirection.fromBottom,
              duration: const Duration(milliseconds: 650),
              child: _ClientHeaderHero(
                header: data.header,
                primaryColor: primaryColor,
                isAr: isAr,
              ),
            ),

            SizedBox(height: 20.h),

            // Download bar
            _Reveal(
              delay: const Duration(milliseconds: 140),
              direction: _SlideDirection.fromLeft,
              duration: const Duration(milliseconds: 650),
              child: _DownloadNowBar(
                primaryColor: primaryColor,
                label: isAr
                    ? (data.download.title.ar.isNotEmpty
                    ? data.download.title.ar
                    : 'حمّل الآن')
                    : (data.download.title.en.isNotEmpty
                    ? data.download.title.en
                    : 'Download Now'),
                appStoreLink: data.download.appStoreLink,
                googlePlayLink: data.download.googlePlayLink,
              ),
            ),

            SizedBox(height: 30.h),

            // Mockup sections — staggered Reveal per item
            // Mockup sections — staggered Reveal per item
            ...List.generate(mockups.length, (i) {
              final direction = i.isEven
                  ? _SlideDirection.fromLeft
                  : _SlideDirection.fromRight;
              return _Reveal(
                key: ValueKey('client_mockup_$i'),
                delay: Duration(milliseconds: 200 + i * 80),
                direction: direction,
                duration: const Duration(milliseconds: 650),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: Builder(
                    builder: (context) {
                      final Color? backgroundColor = _getMainWidgetColor(context);
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: backgroundColor,  // ← Changed from Colors.white
                          borderRadius: BorderRadius.circular(16.r),  // ← Changed from 8.r to 16.r
                        ),
                        child: _ClientMockupSectionWidget(
                          item: mockups[i],
                          primaryColor: primaryColor,
                          isAr: isAr,
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OWNER SERVICE TAB
// ══════════════════════════════════════════════════════════════════════════════
