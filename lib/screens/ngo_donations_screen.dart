import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../services/donation_service.dart';
import '../services/auth_service.dart';

class NGODonationsScreen extends StatefulWidget {
  const NGODonationsScreen({super.key});

  @override
  State<NGODonationsScreen> createState() => _NGODonationsScreenState();
}

class _NGODonationsScreenState extends State<NGODonationsScreen> with SingleTickerProviderStateMixin {
  final DonationService _donationService = DonationService();
  final AuthService _authService = AuthService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDonationList('pending'),
          _buildDonationList('accepted'),
          _buildDonationList('completed'),
          _buildDonationList('rejected'),
        ],
      ),
    );
  }

  Widget _buildDonationList(String status) {
    return StreamBuilder<List<DonationModel>>(
      stream: _donationService.getDonationsForNGOByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No $status donations'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final donation = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    '/donation-management', 
                    arguments: donation
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              donation.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(donation.category),
                            backgroundColor: _getCategoryColor(donation.category),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        donation.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(donation.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios, 
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.green.shade100;
      case 'clothes':
        return Colors.blue.shade100;
      case 'books':
        return Colors.amber.shade100;
      case 'blood':
        return Colors.red.shade100;
      default:
        return Colors.purple.shade100;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}