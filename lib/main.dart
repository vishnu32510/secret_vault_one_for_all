import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secretvaultoneforall/bloc_observer.dart';
import 'package:secretvaultoneforall/core/config/global_keys.dart';
import 'package:secretvaultoneforall/core/config/routes.dart';
import 'package:secretvaultoneforall/core/di/injection.dart';
import 'package:secretvaultoneforall/features/authentication/wrappers/authentication_wrapper.dart';
import 'package:secretvaultoneforall/features/theme/theme_bloc.dart';
import 'package:secretvaultoneforall/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = SimpleBlocObserver();
  setupDI();
  runApp(const SafepadApp());
}

class SafepadApp extends StatelessWidget {
  const SafepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthenticationWrapper(
      child: MultiBlocProvider(
        providers: [BlocProvider<ThemeBloc>(create: (_) => getIt<ThemeBloc>())],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Safepad',
              debugShowCheckedModeBanner: false,
              theme: LightThemeState.lightTheme.themeData,
              darkTheme: DarkThemeState.darkTheme.themeData,
              themeMode: themeState.themeMode,
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              onGenerateRoute: CustomRouter.generateRoute,
              initialRoute: AppRoutes.home,
            );
          },
        ),
      ),
    );
  }
}
