import 'package:flutter/material.dart';
import 'package:volt_find/HomeScreen.dart';
import 'package:volt_find/OnboardingScreen.dart';
import 'package:volt_find/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volt_find/SignupScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },

      // Handle undefined routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      },
    );
  }
}
