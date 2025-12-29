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
      // ✅ CRITICAL: Use AuthWrapper instead of fixed initialRoute
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
        '/settings': (context) => SettingsScreen(),
        '/booking-history': (context) => BookingHistoryScreen(),
        
        // Station Owner Routes
        '/station-dashboard': (context) => const StationDashboardScreen(),
        '/update-availability': (context) => const UpdateAvailabilityScreen(),
        '/edit-station': (context) => const EditStationScreen(),
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

/// AuthWrapper - Checks authentication state and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User is logged in: ${snapshot.data!.uid}');
          return UserTypeRouter(user: snapshot.data!);
        }

        // If no user is logged in, show onboarding
        print('❌ No user logged in, showing onboarding');
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
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        // Show loading while fetching user data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // If error occurred or no data
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          print('❌ Error fetching user data or document does not exist');
          // Sign out user and return to login
          firebase_auth.FirebaseAuth.instance.signOut();
          return const LoginScreen();
        }

        // Get user type from Firestore
        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userType = userData?['userType'] ?? 'customer';
        final isActive = userData?['isActive'] ?? true;

        print('✅ User type: $userType');
        print('✅ Active status: $isActive');

        // Check if user is active
        if (!isActive) {
          print('❌ User is not active');
          firebase_auth.FirebaseAuth.instance.signOut();
          return const LoginScreen();
        }

        // Navigate based on user type
        if (userType == 'stationOwner') {
          print('🚗 Routing to Station Dashboard');
          return const StationDashboardScreen();
        } else {
          print('🏠 Routing to Home Screen');
          return const HomeScreen();
        }
      },
    );
  }
}