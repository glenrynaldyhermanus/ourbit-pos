import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';

import 'src/core/config/app_config.dart';
import 'src/core/di/dependency_injection.dart';
import 'src/core/routes/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/services/app_initialization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set URL strategy untuk web (no hash routing)
  if (kIsWeb) {
    // Use path URL strategy instead of hash
    // This will make URLs like /payment instead of /#/payment
    setPathUrlStrategy();
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialize app dan handle token jika ada
  await AppInitializationService.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: DependencyInjection.getProviders(),
      child: MaterialApp.router(
        title: 'Ourbit POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          // Force landscape orientation for desktop/tablet
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);

          // Set system UI overlay style
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
          );

          return child!;
        },
      ),
    );
  }
}
