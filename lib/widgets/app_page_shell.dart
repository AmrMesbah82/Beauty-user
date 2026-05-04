import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/home/home_cubit.dart';
import '../controller/home/home_state.dart';
import '../controller/home/lang_state.dart';
import '../theme/appcolors.dart';
import 'app_footer.dart';
import 'app_navbar.dart';

Color _parseColor(String hex, {required Color fallback}) {
  try {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  } catch (_) {}
  return fallback;
}

/// Maps new clean URL paths back to the Firebase nav button route keys
/// so the navbar can highlight the correct active item.
String _toFirebaseRoute(String route) {
  return switch (route) {
    '/overview'     => '/services',
    '/our-products' => '/about',
    '/about-us'     => '/contact',
    '/contact-us'   => '/contactus',
    _               => route,
  };
}

class AppPageShell extends StatelessWidget {
  final String currentRoute;
  final Widget body;
  final bool scrollable;
  final void Function(String route)? onNavItemTap;
  final Color? backgroundColor;
  final double? maxBodyWidth;

  const AppPageShell({
    super.key,
    required this.currentRoute,
    required this.body,
    this.scrollable = true,
    this.onNavItemTap,
    this.backgroundColor,
    this.maxBodyWidth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final Color bgColor = backgroundColor ??
            switch (homeState) {
              HomeCmsLoaded(:final data) => _parseColor(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              HomeCmsSaved(:final data) => _parseColor(
                data.branding.backgroundColor,
                fallback: AppColors.background,
              ),
              _ => AppColors.background,
            };

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isRtl = langState.isArabic;
            final double screenW = MediaQuery.of(context).size.width;
            final double contentMaxW = maxBodyWidth ?? 1000.w;
            final double effectiveMaxW = contentMaxW.clamp(0, screenW);

            Widget bodyContent = Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: effectiveMaxW),
                child: SizedBox(
                  width: effectiveMaxW,
                  child: body,
                ),
              ),
            );

            if (scrollable) {
              bodyContent = SingleChildScrollView(child: bodyContent);
            }

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: bgColor,
                body: Column(
                  children: [
                    Material(
                      color: bgColor,
                      elevation: 0,
                      child: AppNavbar(
                        currentRoute: _toFirebaseRoute(currentRoute),
                        onItemTap: onNavItemTap,
                      ),
                    ),
                    Expanded(child: bodyContent),
                    const AppFooter(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}