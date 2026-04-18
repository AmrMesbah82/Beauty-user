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
//              /terms    → TermsOfServicePage ✅ NEW

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
import '../page/terms_of_service_page.dart'; // ✅ NEW

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE + ANGLE + FADE PAGE TRANSITION
// ═══════════════════════════════════════════════════════════════════════════════

enum SlideDirection { fromRight, fromLeft, fromBottom }

CustomTransitionPage<T> animatedPage<T>({
  required LocalKey key,
  required Widget child,
  SlideDirection slideDirection = SlideDirection.fromRight,
  Duration duration = const Duration(milliseconds: 650),
  Curve curve = Curves.easeOutCubic,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final Offset beginOffset = switch (slideDirection) {
        SlideDirection.fromRight  => const Offset(0.12, 0.0),
        SlideDirection.fromLeft   => const Offset(-0.12, 0.0),
        SlideDirection.fromBottom => const Offset(0.0, 0.08),
      };

      final slideAnim = Tween<Offset>(begin: beginOffset, end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
        ),
      );

      final skewSign = slideDirection == SlideDirection.fromLeft ? 1.0 : -1.0;
      final skewAnim = Tween<double>(begin: skewSign * 0.05, end: 0.0)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final scaleAnim = Tween<double>(begin: 0.97, end: 1.0)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final exitFade = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: exitFade,
        child: FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateY(skewAnim.value)
                  ..scale(scaleAnim.value),
                alignment: Alignment.center,
                child: child,
              ),
              child: pageChild,
            ),
          ),
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
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _withBlocs(context, const HomePage()),
        ),
      ),

      // ── /services → OverviewPage (CMS label: "Overview") ──────────────────
      GoRoute(
        path: '/services',
        name: 'overview',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _withBlocs(context, const OverviewPage()),
        ),
      ),

      // ── /about → OurProductsPage (CMS label: "Our Products") ──────────────
      GoRoute(
        path: '/about',
        name: 'our-products',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _withBlocs(context, const OurProductsPage()),
        ),
      ),

      // ── /contact → AboutPage (CMS label: "About Us") ──────────────────────
      GoRoute(
        path: '/contact',
        name: 'about-us',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _withBlocs(context, const AboutPage()),
        ),
      ),

      // ── /terms → TermsOfServicePage ✅ NEW ───────────────────────────────
      GoRoute(
        path: '/terms',
        name: 'terms',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _withBlocs(context, const TermsOfServicePage()),
        ),
      ),


      GoRoute(
        path: '/contactus',
        name: 'contactus',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _withBlocs(context, const ContactPage()),
        ),
      ),

    ],
  );
}