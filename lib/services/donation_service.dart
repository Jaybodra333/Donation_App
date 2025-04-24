import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';
import 'auth_service.dart';
import '../models/user_model.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<DonationModel> createDonation({
    required String title,
    required String description,
    required String category,
    required String ngoId,
    String? location,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'No authenticated user found';
      }

      // Create a new document reference
      final docRef = _firestore.collection('donations').doc();

      final donation = DonationModel(
        id: docRef.id,
        donorId: user.uid,
        title: title,
        description: description,
        category: category,
        status: 'pending',
        createdAt: DateTime.now(),
        assignedTo: ngoId,
        location: location,
      );

      // Save to Firestore
      await docRef.set(donation.toMap());
      return donation;
    } catch (e) {
      throw 'Failed to create donation: $e';
    }
  }

  Stream<List<DonationModel>> getDonationsStream(String userId) {
    return _firestore
        .collection('donations')
        .where('donorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DonationModel.fromMap(doc.data()))
            .toList());
  }
  
  // Modified method to only show donations assigned to the current NGO
  Stream<List<DonationModel>> getDonationsForNGOByStatus(String status) {
    final user = _authService.currentUser;
    if (user == null) {
      throw 'No authenticated user found';
    }
    
    if (status.toLowerCase() == 'pending') {
      // For pending donations, get only those specifically assigned to this NGO
      return _firestore
          .collection('donations')
          .where('status', isEqualTo: status)
          .where('assignedTo', isEqualTo: user.uid)  // <-- Changed to only show pending donations assigned to this NGO
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => DonationModel.fromMap(doc.data()))
              .toList());
    } else {
      // For other statuses, continue to fetch all donations for this NGO with client-side filtering
      return _firestore
          .collection('donations')
          .where('assignedTo', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
            List<DocumentSnapshot> filteredDocs = snapshot.docs
                .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == status)
                .toList();
                
            // Sort manually by createdAt
            filteredDocs.sort((a, b) {
              DateTime dateA = DateTime.parse((a.data() as Map<String, dynamic>)['createdAt']);
              DateTime dateB = DateTime.parse((b.data() as Map<String, dynamic>)['createdAt']);
              return dateB.compareTo(dateA); // Descending order
            });
            
            return filteredDocs
                .map((doc) => DonationModel.fromMap(doc.data() as Map<String, dynamic>))
                .toList();
          });
    }
  }
  
  // Get donor details for a donation
  Future<UserModel?> getDonorDetails(String donorId) async {
    try {
      print('Fetching donor details for ID: $donorId');
      final docSnapshot = await _firestore.collection('users').doc(donorId).get();
      
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        print('No donor found with ID: $donorId');
        return null;
      }
      
      final userData = docSnapshot.data()!;
      print('Found donor data: ${userData['name']}');
      return UserModel.fromMap({
        ...userData,
        'uid': donorId,
      });
    } catch (e) {
      print('Error fetching donor details: $e');
      return null;
    }
  }

  // Update donation status
  Future<void> updateDonationStatus({
    required String donationId,
    required String status,
    String? notes,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'No authenticated user found';
      }
      
      // Get the donation document
      final donationDoc = await _firestore.collection('donations').doc(donationId).get();
      
      if (!donationDoc.exists) {
        throw 'Donation not found';
      }
      
      final updateData = {
        'status': status,
      };
      
      // Add notes if provided
      if (notes != null && notes.isNotEmpty) {
        updateData['notes'] = notes;
      }
      
      // Update the donation
      await _firestore.collection('donations').doc(donationId).update(updateData);
    } catch (e) {
      throw 'Failed to update donation status: $e';
    }
  }
  
  // Get donation statistics for NGO dashboard - modified to only count relevant donations
  Future<Map<String, int>> getDonationStatistics() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'No authenticated user found';
      }
      
      final stats = {
        'pending': 0,
        'accepted': 0,
        'completed': 0,
        'thisMonth': 0,
      };
      
      // Get all donations assigned to this NGO
      final ngoSnap = await _firestore
          .collection('donations')
          .where('assignedTo', isEqualTo: user.uid)
          .get();
      
      // Filter on the client side
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      
      int pendingCount = 0;
      int acceptedCount = 0;
      int completedCount = 0;
      int thisMonthCount = 0;
      
      for (var doc in ngoSnap.docs) {
        final data = doc.data();
        
        // Count by status
        if (data['status'] == 'pending') {
          pendingCount++;
        } else if (data['status'] == 'accepted') {
          acceptedCount++;
        } else if (data['status'] == 'completed') {
          completedCount++;
        }
        
        // Count this month's donations
        final createdAt = DateTime.parse(data['createdAt']);
        if (createdAt.isAfter(monthStart) || createdAt.isAtSameMomentAs(monthStart)) {
          thisMonthCount++;
        }
      }
      
      stats['pending'] = pendingCount;
      stats['accepted'] = acceptedCount;
      stats['completed'] = completedCount;
      stats['thisMonth'] = thisMonthCount;
      
      return stats;
    } catch (e) {
      throw 'Failed to get donation statistics: $e';
    }
  }
  
  // Get NGO details for a donation
  Future<Map<String, String>> getNgoNames(List<String> ngoIds) async {
    try {
      Map<String, String> ngoNames = {};
      
      // Create a batch of futures to fetch all NGOs in parallel
      final futures = ngoIds.map((ngoId) async {
        if (ngoId.isEmpty) return;
        
        // First, try to get from the users collection
        final docSnapshot = await _firestore.collection('users').doc(ngoId).get();
        
        if (docSnapshot.exists && docSnapshot.data() != null) {
          final userData = docSnapshot.data()!;
          
          // Check if the user document has the organization name directly
          if (userData.containsKey('organizationName') && userData['organizationName'] != null) {
            ngoNames[ngoId] = userData['organizationName'];
            return;
          }
          
          // If not, check if there's a name field we can use
          if (userData.containsKey('name') && userData['name'] != null) {
            ngoNames[ngoId] = userData['name'];
            return;
          }
          
          // As a fallback, try to get from the ngo_details subcollection
          try {
            final detailsDoc = await _firestore
                .collection('users')
                .doc(ngoId)
                .collection('ngo_details')
                .doc('profile')
                .get();
                
            if (detailsDoc.exists && detailsDoc.data() != null) {
              final details = detailsDoc.data()!;
              if (details.containsKey('organizationName') && details['organizationName'] != null) {
                ngoNames[ngoId] = details['organizationName'];
                return;
              }
            }
          } catch (e) {
            print('Error fetching NGO profile details: $e');
          }
          
          // If still no name found, use a more distinctive default
          ngoNames[ngoId] = 'NGO (ID: ${ngoId.substring(0, 4)}...)';
        } else {
          // If the document doesn't exist, provide a clearer placeholder
          ngoNames[ngoId] = 'Unknown NGO';
        }
      });
      
      // Wait for all futures to complete
      await Future.wait(futures.where((f) => f != null));
      
      print('Retrieved NGO names: $ngoNames');
      return ngoNames;
    } catch (e) {
      print('Error fetching NGO names: $e');
      return {};
    }
  }
}