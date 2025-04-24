import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/donor_dashboard.dart';
import 'screens/ngo_dashboard.dart';
import 'screens/create_donation_screen.dart';
import 'screens/my_donations_screen.dart';
import 'screens/ngo_donations_screen.dart';
import 'screens/ngo_donation_management_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/donor-dashboard': (context) => const DonorDashboard(),
        '/ngo-dashboard': (context) => const NGODashboard(),
        '/create-donation': (context) => const CreateDonationScreen(),
        '/my-donations': (context) => const MyDonationsScreen(),
        '/manage-donations': (context) => const NGODonationsScreen(),
        '/donation-management': (context) => const NGODonationManagementScreen(),
        '/analytics': (context) => const AnalyticsDashboardScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        try {
          final userModel = await AuthService().getCurrentUserModel();
          print('Current user role: ${userModel?.role}'); // Add debug print
          return userModel;
        } catch (e) {
          print('Error getting user model: $e');
          return null;
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        final userModel = snapshot.data!;
        final role = userModel.role.trim().toLowerCase();
        print('Navigating based on role: $role'); // Add debug print

        if (role == 'donor') {
          return const DonorDashboard();
        } else if (role == 'ngo') {
          return const NGODashboard();
        } else {
          // Handle invalid role
          print('Invalid role detected: $role');
          return const LoginScreen();
        }
      },
    );
  }
}
