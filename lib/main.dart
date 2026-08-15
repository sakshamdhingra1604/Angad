import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'services/vpn_service.dart';
import 'services/security_service.dart';
import 'services/websocket_service.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark immersive status/nav bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.charcoalMid,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Init services
  final security = SecurityService();
  await security.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => VpnService()),
        ChangeNotifierProvider.value(value: security),
        ChangeNotifierProvider(create: (_) => WebsocketService()),
      ],
      child: const AngadApp(),
    ),
  );
}

class AngadApp extends StatelessWidget {
  const AngadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      title: 'Angad — AI Cyber Protection',
      debugShowCheckedModeBanner: false,
      themeMode: themeService.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/home': (_) => const NavigationWrapper(),
      },
    );
  }
}
