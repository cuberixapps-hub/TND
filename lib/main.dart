import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_environment.dart';
import 'core/navigation/app_navigation.dart';
import 'services/ad_service.dart';
import 'services/revenue_cat_service.dart';
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

  // RevenueCat before runApp so Riverpod never calls Purchases pre-configure.
  // NOTE: ATT must be requested AFTER the app is presented and in the active state,
  // otherwise iOS/iPadOS (especially iPadOS 26.1) will silently drop the dialog.
  // We therefore defer ATT until the first frame is on screen (see _TruthOrDareAppState).
  await RevenueCatService().initialize();

  runApp(const ProviderScope(child: TruthOrDareApp()));
}

/// Request App Tracking Transparency permission on iOS.
/// Must be invoked only once the app is presented and in the active state.
Future<void> _requestTrackingPermission() async {
  // Only request on iOS / iPadOS
  if (!Platform.isIOS) return;

  try {
    // Check current status first
    TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('🔒 ATT Current Status: $status');

    // If not determined, request permission.
    if (status == TrackingStatus.notDetermined) {
      // Small delay so the system dialog is presented after the first frame
      // is committed and the app is fully in the foreground/active state.
      await Future.delayed(const Duration(milliseconds: 400));

      status = await AppTrackingTransparency
          .requestTrackingAuthorization();
      debugPrint('🔒 ATT New Status: $status');
    }
  } catch (e) {
    debugPrint('🔒 ATT Error: $e');
  }
}

class TruthOrDareApp extends StatefulWidget {
  const TruthOrDareApp({super.key});

  @override
  State<TruthOrDareApp> createState() => _TruthOrDareAppState();
}

class _TruthOrDareAppState extends State<TruthOrDareApp> {
  @override
  void initState() {
    super.initState();
    // Request ATT and initialize ads after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTrackingAndAds();
    });
  }

  Future<void> _initializeTrackingAndAds() async {
    debugPrint(
      '🌍 Build environment: ${AppEnvironmentConfig.name} '
      '(AdMob production units: ${AppEnvironmentConfig.useProductionAdMobUnitIds})',
    );

    // Request ATT AFTER the app is visible and in the active state.
    // This fixes the iPadOS 26.1 issue where the system dialog never appears
    // because it was requested pre-runApp.
    await _requestTrackingPermission();

    // Initialize AdService (includes MobileAds initialization) only after ATT
    // has resolved so AdMob picks up the correct tracking authorization.
    await AdService().initialize();

    debugPrint('✅ ATT + Ads initialized (RevenueCat done in main)');
  }

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
