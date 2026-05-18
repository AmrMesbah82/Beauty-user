
import 'package:beauty_user/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_web_plugins/url_strategy.dart';


import 'features/contact_us/presentation/controller/contacu_us_location_cubit.dart';
import 'features/home/data/repo_imp/home_repository_impl.dart';
import 'features/home/presentation/controller/gender_cubit.dart';
import 'features/home/presentation/controller/home_cubit.dart';
import 'features/home/presentation/controller/lang_state.dart';
import 'features/main/data/repo_imp/master_repo_imp.dart';
import 'features/main/presentation/controller/master_cubit.dart';
import 'features/our_product/data/repo_imp/client_services_repo_imp.dart';
import 'features/our_product/data/repo_imp/owner_services_repo_imp.dart';
import 'features/our_product/presentation/controller/client_services_cubit.dart';
import 'features/our_product/presentation/controller/owner_services_cubit.dart';
import 'features/overview/data/repo_imp/overview_repo_imp.dart';
import 'features/overview/presentation/controller/overview_cubit.dart';
import 'features/request/data/repo_imp/request_demo_repo_imp.dart';
import 'features/request/presentation/controller/request_demo_cubit.dart';
import 'firebase_options.dart';

Size _getDesignSize({
  required double screenWidth,
  required double screenHeight,
}) {
  final isLandscape = screenWidth > screenHeight;
  if (screenWidth >= 1920) return const Size(1920, 1080);
  if (screenWidth >= 1366) return const Size(1366, 768);
  if (screenWidth >= 768) {
    return isLandscape ? const Size(1024, 768) : const Size(768, 1024);
  }
  return isLandscape ? const Size(812, 375) : const Size(375, 812);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      sslEnabled: true,
      webExperimentalForceLongPolling: true,
      webExperimentalAutoDetectLongPolling: false,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen =
        View.of(context).physicalSize / View.of(context).devicePixelRatio;
    final designSize = _getDesignSize(
      screenWidth: screen.width,
      screenHeight: screen.height,
    );

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      builder: (ctx, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<LanguageCubit>(
              create: (_) => LanguageCubit(),
            ),
            BlocProvider<HomeCmsCubit>(
              create: (_) => HomeCmsCubit(
                repository: HomeRepositoryImpl(),
              )..load(),
            ),
            BlocProvider<MasterCmsCubit>(
              create: (_) => MasterCmsCubit(
                MasterRepoImp(),
              )..load(),
            ),
            BlocProvider<OverviewCmsCubit>(
              create: (_) => OverviewCmsCubit(
                OverviewRepoImp(),
              )..load(),
            ),
            BlocProvider<ClientServicesCmsCubit>(
              create: (_) => ClientServicesCmsCubit(
                ClientServicesRepoImp(),
              )..load(),
            ),
            BlocProvider<OwnerServicesCmsCubit>(
              create: (_) => OwnerServicesCmsCubit(
                OwnerServicesRepoImp(),
              )..load(),
            ),
            BlocProvider(
              create: (_) => GenderCubit(),
            ),
            BlocProvider<ContactUsCmsCubit>(
              create: (_) => ContactUsCmsCubit()..load(),
            ),
            BlocProvider(
              create: (_) => RequestDemoCmsCubit(RequestDemoRepoImp())..load(),
            ),
          ],
          child: MaterialApp.router(
            title: 'SpaCareTime',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}