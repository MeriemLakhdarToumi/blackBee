import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screens.dart';
import 'screens/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Honeypot App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/signup': (context) => SignupScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(), // Add this route
      },
    );
  }
}
