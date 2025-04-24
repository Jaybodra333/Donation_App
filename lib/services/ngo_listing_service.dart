import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ngo_listing_model.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class NgoListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _storageService = LocalStorageService();
  
  // Get all NGOs
  Future<List<NgoListingModel>> getVerifiedNgos() async {
    try {
      print('Fetching NGOs...');
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'ngo')
          .get();
          
      print('Found ${querySnapshot.docs.length} NGO documents');
      return _processNgoQuerySnapshot(querySnapshot);
    } catch (e) {
      print('Error fetching NGOs: $e');
      return [];
    }
  }
  
  // Add a new method that matches the one being called in the screen
  Future<List<NgoListingModel>> getNgos() async {
    return getVerifiedNgos();
  }
  
  // Get NGOs filtered by category and/or location
  Future<List<NgoListingModel>> getFilteredNgos({
    List<String>? categories,
    String? location,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'ngo');
      
      // We'll fetch all NGOs and then filter them in memory,
      // as Firestore doesn't support direct array-contains queries with multiple values efficiently
      final querySnapshot = await query.get();
      List<NgoListingModel> ngos = await _processNgoQuerySnapshot(querySnapshot);
      
      // Filter by categories if provided
      if (categories != null && categories.isNotEmpty) {
        ngos = ngos.where((ngo) {
          return ngo.categories.any((category) => categories.contains(category));
        }).toList();
      }
      
      // Filter by location if provided
      if (location != null && location.isNotEmpty) {
        final locationLower = location.toLowerCase();
        ngos = ngos.where((ngo) {
          return ngo.location.toLowerCase().contains(locationLower);
        }).toList();
      }
      
      return ngos;
    } catch (e) {
      print('Error fetching filtered NGOs: $e');
      return [];
    }
  }
  
  // New method to search NGOs by name, location, or category
  Future<List<NgoListingModel>> searchNgos(String searchQuery) async {
    try {
      if (searchQuery.isEmpty) {
        return getVerifiedNgos();
      }
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'ngo')
          .get();
          
      List<NgoListingModel> ngos = await _processNgoQuerySnapshot(querySnapshot);
      
      // Convert search query to lowercase for case-insensitive comparison
      final searchLower = searchQuery.toLowerCase();
      
      // Filter NGOs by name, location, or category
      return ngos.where((ngo) {
        // Check if query matches organization name
        final nameMatch = ngo.organizationName.toLowerCase().contains(searchLower);
        
        // Check if query matches location
        final locationMatch = ngo.location.toLowerCase().contains(searchLower);
        
        // Check if query matches any category
        final categoryMatch = ngo.categories.any(
          (category) => category.toLowerCase().contains(searchLower)
        );
        
        // Return true if any of the fields match
        return nameMatch || locationMatch || categoryMatch;
      }).toList();
    } catch (e) {
      print('Error searching NGOs: $e');
      return [];
    }
  }
  
  // Process query snapshot and convert to NgoListingModel list
  Future<List<NgoListingModel>> _processNgoQuerySnapshot(QuerySnapshot querySnapshot) async {
    List<NgoListingModel> ngos = [];
    
    for (var doc in querySnapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      
      print('Processing NGO document: ${doc.id}, data: ${userData['name']}');
      
      // Get additional NGO data from the ngo_details subcollection
      Map<String, dynamic> additionalData = {};
      try {
        final detailsDoc = await _firestore
            .collection('users')
            .doc(doc.id)
            .collection('ngo_details')
            .doc('profile')
            .get();
            
        if (detailsDoc.exists && detailsDoc.data() != null) {
          additionalData = detailsDoc.data()!;
          print('Found additional details for ${doc.id}: ${additionalData.toString()}');
          
          // Debug rating information
          if (additionalData.containsKey('rating')) {
            print('Rating found for ${doc.id}: ${additionalData['rating']}');
          } else {
            print('No rating data found for ${doc.id}');
          }
          
          if (additionalData.containsKey('feedbackCount')) {
            print('Feedback count found for ${doc.id}: ${additionalData['feedbackCount']}');
          } else {
            print('No feedback count found for ${doc.id}');
          }
        } else {
          print('No additional details document for ${doc.id}');
          // Provide default values for required fields
          additionalData = {
            'description': 'No description available',
            'categories': [NgoCategory.other]
          };
        }
      } catch (e) {
        print('Error fetching additional NGO data for ${doc.id}: $e');
        // Provide default values if there's an error
        additionalData = {
          'description': 'No description available',
          'categories': [NgoCategory.other]
        };
      }
      
      // Create user model first
      final userModel = UserModel.fromMap({
        ...userData,
        'uid': doc.id,
      });
      
      // Try to load profile image if it exists
      try {
        final imagePath = await _storageService.getProfileImagePath(doc.id);
        if (imagePath != null) {
          userModel.profileImagePath = imagePath;
          print('Found profile image for ${doc.id}');
        }
      } catch (e) {
        print('Error loading profile image for ${doc.id}: $e');
      }
      
      // Create NGO listing model
      final ngoModel = NgoListingModel.fromUserModel(userModel, additionalData);
      
      // Debug the created NGO model
      print('NGO Model ${ngoModel.organizationName} - Rating: ${ngoModel.rating}, Feedback Count: ${ngoModel.feedbackCount}');
      
      ngos.add(ngoModel);
      print('Added NGO to list: ${ngoModel.name}');
    }
    
    print('Processed ${ngos.length} NGOs');
    return ngos;
  }
  
  // Get detailed information about a specific NGO
  Future<NgoListingModel?> getNgoDetails(String ngoId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(ngoId).get();
      
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }
      
      final userData = docSnapshot.data()!;
      
      // Verify this is an NGO
      if (userData['role'] != 'ngo') {
        return null;
      }
      
      // Get additional NGO data
      Map<String, dynamic> additionalData = {};
      try {
        final detailsDoc = await _firestore
            .collection('users')
            .doc(ngoId)
            .collection('ngo_details')
            .doc('profile')
            .get();
            
        if (detailsDoc.exists && detailsDoc.data() != null) {
          additionalData = detailsDoc.data()!;
        }
      } catch (e) {
        print('Error fetching additional NGO data: $e');
      }
      
      // Create user model
      final userModel = UserModel.fromMap({
        ...userData,
        'uid': ngoId,
      });
      
      // Try to load profile image
      try {
        final imagePath = await _storageService.getProfileImagePath(ngoId);
        if (imagePath != null) {
          userModel.profileImagePath = imagePath;
        }
      } catch (e) {
        print('Error loading profile image: $e');
      }
      
      // Create and return NGO listing model
      return NgoListingModel.fromUserModel(userModel, additionalData);
    } catch (e) {
      print('Error fetching NGO details: $e');
      return null;
    }
  }
}