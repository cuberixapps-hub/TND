import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_navigation.dart';
import 'services/ad_service.dart';
import 'presentation/screens/quirky_home_screen.dart';
import 'presentation/screens/modern_player_setup_screen.dart';
import 'presentation/screens/ultra_modern_game_play_screen.dart';
import 'presentation/screens/modern_scoreboard_screen.dart';
import 'presentation/screens/modern_game_over_screen.dart';
import 'presentation/screens/modern_settings_screen.dart';
import 'presentation/screens/custom_challenge_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize AdService (includes MobileAds initialization)
  await AdService().initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: TruthOrDareApp()));
}

class TruthOrDareApp extends StatelessWidget {
  const TruthOrDareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      navigatorObservers: [AppNavigationObserver()],
      home: const QuirkyHomeScreen(),
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case AppRoutes.home:
        page = const QuirkyHomeScreen();
        break;
      case AppRoutes.playerSetup:
        final GameMode mode = settings.arguments as GameMode;
        page = ModernPlayerSetupScreen(mode: mode);
        break;
      case AppRoutes.gameplay:
        page = const UltraModernGamePlayScreen();
        break;
      case AppRoutes.scoreboard:
        page = const ModernScoreboardScreen();
        break;
      case AppRoutes.gameOver:
        page = const ModernGameOverScreen();
        break;
      case AppRoutes.settings:
        page = const ModernSettingsScreen();
        break;
      case AppRoutes.customChallenge:
        page = const CustomChallengeScreen();
        break;
      default:
        page = const QuirkyHomeScreen();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
