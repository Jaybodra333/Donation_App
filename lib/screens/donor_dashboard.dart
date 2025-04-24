import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/donation_service.dart';
import '../models/donation_model.dart';
import 'profile_screen.dart';
import 'ngo_listing_screen.dart';
import 'analytics_dashboard_screen.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final AuthService _authService = AuthService();
  final DonationService _donationService = DonationService();
  Map<String, String> _ngoNames = {}; // Cache for NGO names

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Donor Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: () async {
                                await _authService.signOut();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Make an impact today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Features grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Features grid 
              SizedBox(
                height: 325, // Increased from 280 to 300px for more vertical space
                child: GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.1, // Changed from 1.3 to 1.1 to make cards taller
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildFeatureCard(
                      'Make Donation',
                      Icons.card_giftcard,
                      'Support causes you care about',
                      Colors.deepPurple.shade50,
                      () => Navigator.pushNamed(context, '/create-donation'),
                    ),
                    _buildFeatureCard(
                      'NGO Directory',
                      Icons.volunteer_activism,
                      'Discover organizations',
                      Colors.green.shade50,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NgoListingScreen()),
                      ),
                    ),
                    _buildFeatureCard(
                      'My Donations',
                      Icons.history,
                      'Track your donation history',
                      Colors.orange.shade50,
                      () => Navigator.pushNamed(context, '/my-donations'),
                    ),
                    _buildFeatureCard(
                      'Analytics',
                      Icons.bar_chart,
                      'View your impact data',
                      Colors.blue.shade50,
                      () => Navigator.pushNamed(context, '/analytics'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Recent Donations heading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Donations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/my-donations'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Donation history section - no longer in an Expanded widget
              _buildDonationHistoryList(),
              
              // Add padding at the bottom for better scrolling experience
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, String subtitle, Color bgColor, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.deepPurple,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 2, // Changed from 1 to 2 lines to show full description
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationHistoryList() {
    return StreamBuilder<List<DonationModel>>(
      stream: _donationService.getDonationsStream(_authService.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Error loading donations', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No donations yet', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/create-donation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Make a Donation'),
                  ),
                ],
              ),
            ),
          );
        }

        // Limit to the most recent 5 donations
        final donations = snapshot.data!.take(5).toList();
        
        // Get all unique NGO IDs to look up
        final ngoIds = donations
            .map((donation) => donation.assignedTo)
            .where((id) => id != null && id.isNotEmpty)
            .map((id) => id!)
            .toSet()
            .toList();
        
        // Use FutureBuilder to fetch NGO names
        return FutureBuilder<Map<String, String>>(
          future: _donationService.getNgoNames(ngoIds),
          builder: (context, ngoSnapshot) {
            if (ngoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Save ngo names in cache
            if (ngoSnapshot.hasData) {
              _ngoNames = ngoSnapshot.data!;
            }
            
            return SizedBox(
              // Set a fixed height for the ListView since it's inside a SingleChildScrollView
              height: 400,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                // Allow the ListView to scroll within its container
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];
                  // Get NGO name from cache, fallback to ID if not found
                  final ngoName = donation.assignedTo != null 
                      ? _ngoNames[donation.assignedTo] ?? 'Unknown NGO'
                      : 'Not assigned';
                  
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status indicator
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 5, right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(donation.status),
                            ),
                          ),
                          
                          // Donation info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "To: $ngoName", // Use the looked up NGO name instead of ID
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(donation.status).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        donation.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(donation.status).withOpacity(1),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        donation.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Date and information
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(donation.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                donation.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Format as yyyy-MM-dd
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}