import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class NgoCategory {
  static const String education = 'Education';
  static const String healthcare = 'Healthcare';
  static const String environment = 'Environment';
  static const String animalWelfare = 'Animal Welfare';
  static const String humanRights = 'Human Rights';
  static const String foodRelief = 'Food Relief';
  static const String disasterRelief = 'Disaster Relief';
  static const String other = 'Other';

  static List<String> getCategories() {
    return [
      education,
      healthcare,
      environment,
      animalWelfare,
      humanRights,
      foodRelief,
      disasterRelief,
      other
    ];
  }
}

class NgoListingModel {
  final String id;
  final String name;
  final String organizationName;
  final String description;
  final List<String> categories;
  final String location;
  final String? profileImagePath;
  final double? rating;
  final int? donationsReceived;
  final int? feedbackCount;
  
  NgoListingModel({
    required this.id,
    required this.name,
    required this.organizationName,
    required this.description,
    required this.categories,
    required this.location,
    this.profileImagePath,
    this.rating,
    this.donationsReceived,
    this.feedbackCount,
  });

  factory NgoListingModel.fromUserModel(UserModel user, Map<String, dynamic> additionalData) {
    // Extract categories safely, ensuring we always have a valid list
    List<String> categoryList = [];
    try {
      if (additionalData['categories'] != null) {
        if (additionalData['categories'] is List) {
          categoryList = List<String>.from(additionalData['categories']);
        } else if (additionalData['categories'] is String) {
          categoryList = [(additionalData['categories'] as String)];
        }
      }
    } catch (e) {
      print('Error parsing categories: $e');
    }
    
    // Ensure we have at least one category
    if (categoryList.isEmpty) {
      categoryList = [NgoCategory.other];
    }
    
    // Handle rating value carefully, ensuring we properly convert types
    double? ratingValue;
    try {
      if (additionalData['rating'] != null) {
        if (additionalData['rating'] is double) {
          ratingValue = additionalData['rating'];
        } else if (additionalData['rating'] is int) {
          ratingValue = (additionalData['rating'] as int).toDouble();
        } else {
          // Handle string or other types by trying to parse them
          ratingValue = double.tryParse(additionalData['rating'].toString());
        }
        print('Successfully processed rating for ${user.name}: $ratingValue');
      }
    } catch (e) {
      print('Error parsing rating: $e');
    }
    
    // Handle feedback count
    int? feedbackCountValue;
    try {
      if (additionalData['feedbackCount'] != null) {
        if (additionalData['feedbackCount'] is int) {
          feedbackCountValue = additionalData['feedbackCount'];
        } else {
          // Try to parse other types to int
          feedbackCountValue = int.tryParse(additionalData['feedbackCount'].toString());
        }
        print('Successfully processed feedback count for ${user.name}: $feedbackCountValue');
      }
    } catch (e) {
      print('Error parsing feedback count: $e');
    }
    
    return NgoListingModel(
      id: user.uid,
      name: user.name,
      organizationName: user.organizationName ?? 'Unknown Organization',
      description: additionalData['description'] ?? 'No description available',
      categories: categoryList,
      location: user.address ?? 'No location provided',
      profileImagePath: user.profileImagePath,
      rating: ratingValue,
      donationsReceived: additionalData['donationsReceived'] is int ? 
                         additionalData['donationsReceived'] : null,
      feedbackCount: feedbackCountValue,
    );
  }

  factory NgoListingModel.fromMap(Map<String, dynamic> data) {
    // Extract categories safely
    List<String> categoryList = [];
    try {
      if (data['categories'] != null) {
        if (data['categories'] is List) {
          categoryList = List<String>.from(data['categories']);
        } else if (data['categories'] is String) {
          categoryList = [(data['categories'] as String)];
        }
      }
    } catch (e) {
      print('Error parsing categories in fromMap: $e');
    }
    
    if (categoryList.isEmpty) {
      categoryList = [NgoCategory.other];
    }
    
    return NgoListingModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      organizationName: data['organizationName'] ?? 'Unknown Organization',
      description: data['description'] ?? 'No description available',
      categories: categoryList,
      location: data['location'] ?? 'No location provided',
      profileImagePath: data['profileImagePath'],
      rating: data['rating'] != null ? 
              (data['rating'] is double ? data['rating'] : 
               data['rating'] is int ? (data['rating'] as int).toDouble() : null) : 
              null,
      donationsReceived: data['donationsReceived'] is int ? 
                         data['donationsReceived'] : null,
      feedbackCount: data['feedbackCount'] is int ? 
                     data['feedbackCount'] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organizationName': organizationName,
      'description': description,
      'categories': categories,
      'location': location,
      'rating': rating,
      'donationsReceived': donationsReceived,
      'feedbackCount': feedbackCount,
    };
  }
}