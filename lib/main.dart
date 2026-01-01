import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/analytics_service.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    ),
  );

  // Initialize Firebase Analytics (privacy-configured)
  await analytics.initialize();

  runApp(const ProviderScope(child: FuliTrackApp()));
}

class FuliTrackApp extends StatelessWidget {
  const FuliTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuliTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(
        child: AppWrapper(),
      ),
    );
  }
}

/// Wrapper to handle onboarding flow
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool? _hasCompletedOnboarding;
  bool? _hasGrantedPermission;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    final permissionGranted = prefs.getBool('permission_granted') ?? false;
    setState(() {
      _hasCompletedOnboarding = onboardingCompleted;
      _hasGrantedPermission = permissionGranted;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    setState(() => _hasCompletedOnboarding = true);
  }

  Future<void> _completePermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_granted', true);
    setState(() => _hasGrantedPermission = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCompletedOnboarding == null || _hasGrantedPermission == null) {
      // Loading state
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasCompletedOnboarding == false) {
      return OnboardingScreen(
        onComplete: _completeOnboarding,
      );
    }

    if (_hasGrantedPermission == false) {
      return PermissionScreen(
        onGranted: _completePermission,
      );
    }

    return const HomeScreen();
  }
}
