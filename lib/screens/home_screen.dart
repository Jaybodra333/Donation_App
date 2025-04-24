import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: authService.getCurrentUserModel(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('User data not found'));
          }

          final userModel = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userModel.role == UserRole.ngo ? userModel.organizationName : userModel.email}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${userModel.role.toString().split('.').last.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                if (userModel.role == UserRole.donor)
                  const Text(
                    'As a donor, you can:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                else
                  const Text(
                    'As an NGO, you can:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 16),
                if (userModel.role == UserRole.donor)
                  _buildDonorFeatures()
                else
                  _buildNGOFeatures(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonorFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem('Browse donation campaigns'),
        _buildFeatureItem('Make donations'),
        _buildFeatureItem('Track your donations'),
        _buildFeatureItem('View donation history'),
      ],
    );
  }

  Widget _buildNGOFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem('Create donation campaigns'),
        _buildFeatureItem('Manage donations'),
        _buildFeatureItem('View donor analytics'),
        _buildFeatureItem('Update organization profile'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
} 