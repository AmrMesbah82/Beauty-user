// ******************* FILE INFO *******************
// File Name: app_router.dart
// Description: Public website router for beauty_user app.
//              Routes use CMS route keys (/, /services, /about, /contact, etc.)
//              go_router is kept for the shell; in-app nav uses Navigator.push.
//
//              CMS Route Mapping:
//              /         → HomePage
//              /services → OverviewPage
//              /about    → OurProductsPage
//              /contact  → AboutPage
//              /terms    → TermsOfServicePage
//              /contactus → ContactPage

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
// ROUTER — public routes (keys match CMS navButton routes)
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

      // ── /services → OverviewPage ───────────────────────────────────────────
      GoRoute(
        path: '/services',
        name: 'overview',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const OverviewPage()),
        ),
      ),

      // ── /about → OurProductsPage ───────────────────────────────────────────
      GoRoute(
        path: '/about',
        name: 'our-products',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const OurProductsPage()),
        ),
      ),

      // ── /contact → AboutPage ───────────────────────────────────────────────
      GoRoute(
        path: '/contact',
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

      // ── /contactus → ContactPage ───────────────────────────────────────────
      GoRoute(
        path: '/contactus',
        name: 'contactus',
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: _withBlocs(context, const ContactPage()),
        ),
      ),

    ],
  );
}