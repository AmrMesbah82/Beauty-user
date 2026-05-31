part of '../../pages/our_products_page.dart';

class _OwnerServiceTab extends StatelessWidget {
  final Color primaryColor;
  final bool isAr;

  const _OwnerServiceTab({
    super.key,
    required this.primaryColor,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = _getMainWidgetColor(context);
    return BlocBuilder<OwnerServicesCubit, OwnerServicesState>(
      builder: (context, state) {
        if (state is OwnerServicesError) {
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
          OwnerServicesLoaded(:final data) => data,
          OwnerServicesSaved(:final data) => data,
          _ => context.read<OwnerServicesCubit>().current,
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
              child: _OwnerHeaderHero(
                header: data.header,
                primaryColor: primaryColor,
                isAr: isAr,
              ),
            ),

            SizedBox(height: 20.h),

            // Download bar
            _Reveal(
              delay: const Duration(milliseconds: 140),
              direction: _SlideDirection.fromRight,
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
            ...List.generate(mockups.length, (i) {
              final direction = i.isEven
                  ? _SlideDirection.fromRight
                  : _SlideDirection.fromLeft;
              return _Reveal(
                key: ValueKey('owner_mockup_$i'),
                delay: Duration(milliseconds: 200 + i * 80),
                direction: direction,
                duration: const Duration(milliseconds: 650),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: _OwnerMockupSectionWidget(
                      item: mockups[i],
                      primaryColor: primaryColor,
                      isAr: isAr,
                    ),
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
// CLIENT HEADER HERO
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT HEADER HERO (WITH MAIN WIDGET COLOR BACKGROUND)
// ══════════════════════════════════════════════════════════════════════════════
