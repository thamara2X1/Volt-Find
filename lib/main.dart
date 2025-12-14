import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_find/domain/repositories/user_repository_impl.dart';
import 'package:volt_find/presentation/screens/auth/LoginScreen.dart';
import 'package:volt_find/presentation/screens/auth/OnboardingScreen.dart';
import 'package:volt_find/presentation/screens/auth/SignupScreen.dart';
import 'package:volt_find/presentation/screens/auth/UserTypeSelectionScreen.dart';
import 'package:volt_find/presentation/screens/customer/home/HomeScreen.dart';
import 'package:volt_find/presentation/screens/customer/home/ViewMapScreen.dart';

// Firebase config
import 'firebase_options.dart';

// Presentation layer screens
// import 'presentation/screens/auth/onboarding_screen.dart';
// import 'presentation/screens/auth/login_screen.dart';
// import 'presentation/screens/auth/signup_screen.dart';
// import 'presentation/screens/auth/user_type_selection_screen.dart';
// import 'presentation/screens/customer/home/home_screen.dart';
// import 'presentation/screens/customer/home/view_map_screen.dart';
import 'presentation/screens/customer/profile/profile_screen.dart'; // Added profile screen

// Providers
import 'presentation/providers/user_provider.dart';

// Data layer
// import 'data/repositories/user_repository_impl.dart';

// Domain layer use cases
import 'domain/usecases/user/get_user_usecase.dart';
import 'domain/usecases/user/update_user_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase instances
  final firestore = FirebaseFirestore.instance;
  final auth = firebase_auth.FirebaseAuth.instance;

  // Initialize User dependencies for Clean Architecture
  final userRepository = UserRepositoryImpl(firestore, auth);
  final getUserUseCase = GetUserUseCase(userRepository);
  final updateUserUseCase = UpdateUserUseCase(userRepository);

  runApp(
    MultiProvider(
      providers: [
        // User Provider
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            getUserUseCase: getUserUseCase,
            updateUserUseCase: updateUserUseCase,
            auth: auth,
          ),
        ),
        // Add other providers here as you create them:
        // ChangeNotifierProvider(create: (_) => StationProvider()),
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoltFind EV Charging',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade600,
          secondary: Colors.blue.shade600,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade600,
          elevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade600, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        // Auth Routes
        '/onboarding': (context) => const OnboardingScreen(),
        '/user-type-selection': (context) => const UserTypeSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        
        // Customer Routes
        '/home': (context) => const HomeScreen(),
        '/view-map': (context) => const ViewMapScreen(),
        '/profile': (context) => const EditProfileScreen(), // Added profile route
        
        // Add other routes here:
        // '/search': (context) => SearchScreen(),
        // '/station-details': (context) => StationDetailsScreen(),
        // '/booking': (context) => BookingScreen(),
        // '/settings': (context) => SettingsScreen(),
        // '/edit-profile': (context) => EditProfileScreen(),
        // '/vehicle-info': (context) => VehicleInfoScreen(),
        // '/booking-history': (context) => BookingHistoryScreen(),
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