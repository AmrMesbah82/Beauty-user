// ******************* FILE INFO *******************
// File Name: app_router.dart
// Description: Public website router for beauty_user app.
//              Routes use clean URL paths that match page names.
//
//              Route Mapping:
//              /             → HomePage
//              /overview     → OverviewPage
//              /our-products → OurProductsPage
//              /about-us     → AboutPage
//              /terms        → TermsOfServicePage
//              /contact-us   → ContactPage

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/about_us/presentation/ui/pages/about_us_page.dart';
import '../../features/contact_us/presentation/ui/pages/contact_us_page.dart';
import '../../features/home/presentation/controller/home_cubit.dart';
import '../../features/home/presentation/controller/lang_state.dart';
import '../../features/home/presentation/ui/pages/home_page.dart';
import '../../features/our_product/presentation/ui/pages/our_products_page.dart';
import '../../features/overview/presentation/ui/pages/overview_page.dart';
import '../../features/terms_of_services/presentation/ui/pages/terms_of_service_page.dart';



// ═══════════════════════════════════════════════════════════════════════════════
// PURE FADE PAGE TRANSITION
// ═══════════════════════════════════════════════════════════════════════════════

CustomTransitionPage<T> fadePage<T>({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 400),
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
      );

      return FadeTransition(
        opacity: fadeOut,
        child: FadeTransition(
          opacity: fadeIn,
          child: pageChild,
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER — wraps a page with the required BlocProviders
// ═══════════════════════════════════════════════════════════════════════════════

Widget _withBlocs(BuildContext context, Widget page) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: context.read<HomeCmsCubit>()),
      BlocProvider.value(value: context.read<LanguageCubit>()),
    ],
    child: page,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROUTER — public routes (clean URL paths matching page names)
// ═══════════════════════════════════════════════════════════════════════════════

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [

      // ── / → HomePage ──────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const HomePage()),
        ),
      ),

      // ── /overview → OverviewPage ───────────────────────────────────────────
      GoRoute(
        path: '/overview',
        name: 'overview',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const OverviewPage()),
        ),
      ),

      // ── /our-products → OurProductsPage ────────────────────────────────────
      GoRoute(
        path: '/our-products',
        name: 'our-products',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const OurProductsPage()),
        ),
      ),

      // ── /about-us → AboutPage ──────────────────────────────────────────────
      GoRoute(
        path: '/about-us',
        name: 'about-us',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const AboutPage()),
        ),
      ),

      // ── /terms → TermsOfServicePage ────────────────────────────────────────
      GoRoute(
        path: '/terms',
        name: 'terms',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const TermsOfServicePage()),
        ),
      ),

      // ── /contact-us → ContactPage ──────────────────────────────────────────
      GoRoute(
        path: '/contact-us',
        name: 'contact-us',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const ContactPage()),
        ),
      ),

    ],
  );
}