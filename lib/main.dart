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
import 'package:volt_find/presentation/screens/customer/booking/book_now_screen.dart';
import 'package:volt_find/presentation/screens/customer/booking/booking_confirmation_screen.dart';
import 'package:volt_find/presentation/screens/customer/home/HomeScreen.dart';
import 'package:volt_find/presentation/screens/customer/home/ViewMapScreen.dart';
import 'package:volt_find/presentation/screens/customer/profile/booking_history_screen.dart';
import 'package:volt_find/presentation/screens/customer/profile/settings_screen.dart';
import 'package:volt_find/presentation/screens/customer/search/search_screen.dart';
import 'package:volt_find/presentation/screens/customer/station/station_details_screen.dart';
import 'package:volt_find/presentation/screens/customer/profile/profile_screen.dart';

// Station Owner Screens
import 'package:volt_find/presentation/screens/station_owner/station_dashboard_screen.dart';
import 'package:volt_find/presentation/screens/station_owner/update_availability_screen.dart';
import 'package:volt_find/presentation/screens/station_owner/edit_station_screen.dart';

// Firebase config
import 'firebase_options.dart';

// Providers
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/app_theme_provider.dart';

// Domain layer use cases
import 'domain/usecases/user/get_user_usecase.dart';
import 'domain/usecases/user/update_user_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final auth = firebase_auth.FirebaseAuth.instance;

  final userRepository = UserRepositoryImpl(firestore, auth);
  final getUserUseCase = GetUserUseCase(userRepository);
  final updateUserUseCase = UpdateUserUseCase(userRepository);

  runApp(
    MultiProvider(
      providers: [
        // Theme Provider — must be first so MaterialApp can consume it
        ChangeNotifierProvider(
          create: (_) => AppThemeProvider(),
        ),
        // User Provider
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            getUserUseCase: getUserUseCase,
            updateUserUseCase: updateUserUseCase,
            auth: auth,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ─── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardColor: Colors.white,
      useMaterial3: true,
    );
  }

  // ─── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
        primary: Colors.green.shade400,
        secondary: Colors.blue.shade300,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A1A),
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
          backgroundColor: Colors.green.shade500,
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
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardColor: const Color(0xFF1E1E1E),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();

    return MaterialApp(
      title: 'VoltFind EV Charging',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
      routes: {
        // Auth Routes
        '/onboarding': (context) => const OnboardingScreen(),
        '/user-type-selection': (context) => const UserTypeSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),

        // Customer Routes
        '/home': (context) => const HomeScreen(),
        '/view-map': (context) => const ViewMapScreen(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const EditProfileScreen(),
        '/station-details': (context) => const StationDetailsScreen(),
        '/book-now': (context) => const BookNowScreen(),
        '/booking-confirmation': (context) => const BookingConfirmationScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/booking-history': (context) => BookingHistoryScreen(),

        // Station Owner Routes
        '/station-dashboard': (context) => const StationDashboardScreen(),
        '/update-availability': (context) => const UpdateAvailabilityScreen(),
        '/edit-station': (context) => const EditStationScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      },
    );
  }
}

/// AuthWrapper - Checks authentication state and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return UserTypeRouter(user: snapshot.data!);
        }

        return const OnboardingScreen();
      },
    );
  }
}

/// UserTypeRouter - Fetches user type and routes to correct screen
class UserTypeRouter extends StatelessWidget {
  final firebase_auth.User user;

  const UserTypeRouter({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          firebase_auth.FirebaseAuth.instance.signOut();
          return const LoginScreen();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userType = userData?['userType'] ?? 'customer';
        final isActive = userData?['isActive'] ?? true;

        if (!isActive) {
          firebase_auth.FirebaseAuth.instance.signOut();
          return const LoginScreen();
        }

        if (userType == 'stationOwner') {
          return const StationDashboardScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}