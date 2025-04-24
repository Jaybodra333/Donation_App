import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../models/user_model.dart';
import '../services/donation_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NGODonationManagementScreen extends StatefulWidget {
  const NGODonationManagementScreen({super.key});

  @override
  State<NGODonationManagementScreen> createState() => _NGODonationManagementScreenState();
}

class _NGODonationManagementScreenState extends State<NGODonationManagementScreen> {
  final DonationService _donationService = DonationService();
  bool _isLoading = false;
  bool _isLoadingDonor = true;
  UserModel? _donorDetails;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize loading state to false so we can start loading when the screen builds
    _isLoadingDonor = false;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDonorDetails(String donorId) async {
    setState(() => _isLoadingDonor = true);
    try {
      final donorDetails = await _donationService.getDonorDetails(donorId);
      if (mounted) {
        setState(() {
          _donorDetails = donorDetails;
          _isLoadingDonor = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading donor details: $e')),
        );
        setState(() => _isLoadingDonor = false);
      }
    }
  }

  Future<void> _updateDonationStatus(String donationId, String status) async {
    setState(() => _isLoading = true);
    try {
      await _donationService.updateDonationStatus(
        donationId: donationId, 
        status: status,
        notes: _notesController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation $status successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating donation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final donation = ModalRoute.of(context)!.settings.arguments as DonationModel;
    
    // Load donor details if not already loaded
    if (_donorDetails == null && !_isLoadingDonor) {
      _loadDonorDetails(donation.donorId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(donation),
                const SizedBox(height: 24),
                _buildDonorCard(donation.donorId),
                const SizedBox(height: 24),
                _buildDonationDetails(donation),
                const SizedBox(height: 24),
                _buildActionSection(donation),
              ],
            ),
          ),
    );
  }

  Widget _buildStatusCard(DonationModel donation) {
    Color statusColor;
    IconData statusIcon;

    switch (donation.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(donation.status.toUpperCase()),
                        backgroundColor: statusColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(donation.category),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorCard(String donorId) {
    if (_isLoadingDonor) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_donorDetails == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donor Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Donor information unavailable',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => _loadDonorDetails(donorId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donor Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: _donorDetails!.profileImagePath != null
                      ? NetworkImage(_donorDetails!.profileImagePath!)
                      : null,
                  child: _donorDetails!.profileImagePath == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _donorDetails!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _donorDetails!.email,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_donorDetails!.phoneNumber != null && _donorDetails!.phoneNumber!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _donorDetails!.phoneNumber!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_donorDetails!.phoneNumber != null && _donorDetails!.phoneNumber!.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Make sure phone number is properly formatted
                        final phoneNumber = _donorDetails!.phoneNumber!.trim().replaceAll(RegExp(r'\s+'), '');
                        
                        // Create tel: URI - using a different approach for better compatibility
                        final Uri phoneUri = Uri.parse('tel:${phoneNumber}');
                        
                        try {
                          if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not launch phone app')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error launching phone call: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Create mailto: URI - using a different approach for better compatibility
                      final Uri emailUri = Uri.parse('mailto:${_donorDetails!.email}');
                      
                      try {
                        if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch email app')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error launching email: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationDetails(DonationModel donation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildDetailRow('Description', donation.description),
            _buildDetailRow('Created Date', _formatDate(donation.createdAt)),
            if (donation.location != null)
              _buildDetailRow('Location', donation.location!),
            const Divider(),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add notes about this donation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(DonationModel donation) {
    // Show different action buttons based on current status
    if (donation.status.toLowerCase() == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmationDialog(
                donation.id,
                'accepted',
                'Are you sure you want to accept this donation?',
              ),
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmationDialog(
                donation.id,
                'rejected',
                'Are you sure you want to reject this donation?',
              ),
              icon: const Icon(Icons.close),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    } else if (donation.status.toLowerCase() == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showConfirmationDialog(
            donation.id,
            'completed',
            'Mark this donation as completed?',
          ),
          icon: const Icon(Icons.task_alt),
          label: const Text('Mark as Completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    } else {
      // For rejected and completed donations, show a message
      return Card(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'This donation is ${donation.status.toLowerCase()}. No further action is required.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _showConfirmationDialog(
    String donationId,
    String newStatus,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${newStatus.capitalize()}'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateDonationStatus(donationId, newStatus);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}