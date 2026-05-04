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

import '../controller/home/home_cubit.dart';
import '../controller/home/lang_state.dart';
import '../page/about_page.dart';
import '../page/contact_page.dart';
import '../page/home_page.dart';
import '../page/our_products_page.dart';
import '../page/overview_page.dart';
import '../page/terms_of_service_page.dart';

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