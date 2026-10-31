import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/greeting_screen.dart';
import 'screens/live_map_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('--- Initializing Firebase ---');
  try {
    await Firebase.initializeApp();
    print('--- Firebase Initialized Successfully ---');
  } catch (e) {
    print('--- Firebase Initialization Failed: $e ---');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Dispatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/greeting': (context) => const GreetingScreen(),
        '/map': (context) => const LiveMapScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
