import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';
import 'auth_service.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Submit a new feedback/rating
  Future<FeedbackModel> submitFeedback({
    required String ngoId,
    required double rating,
    String? comment,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'No authenticated user found';
      }

      // Get the user's name for the feedback
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final donorName = userData?['name'] ?? 'Anonymous Donor';

      // Check if user has already submitted feedback for this NGO
      final existingFeedback = await _firestore
          .collection('feedback')
          .where('ngoId', isEqualTo: ngoId)
          .where('donorId', isEqualTo: user.uid)
          .get();

      // If feedback exists, update it instead of creating a new one
      if (existingFeedback.docs.isNotEmpty) {
        final existingDoc = existingFeedback.docs.first;
        final updatedFeedback = FeedbackModel(
          id: existingDoc.id,
          ngoId: ngoId,
          donorId: user.uid,
          donorName: donorName,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('feedback')
            .doc(existingDoc.id)
            .update(updatedFeedback.toMap());

        // Update the NGO's average rating
        await _updateNgoAverageRating(ngoId);
        
        return updatedFeedback;
      } else {
        // Create a new feedback document
        final docRef = _firestore.collection('feedback').doc();
        
        final newFeedback = FeedbackModel(
          id: docRef.id,
          ngoId: ngoId,
          donorId: user.uid,
          donorName: donorName,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        );

        await docRef.set(newFeedback.toMap());

        // Update the NGO's average rating
        await _updateNgoAverageRating(ngoId);
        
        return newFeedback;
      }
    } catch (e) {
      throw 'Failed to submit feedback: $e';
    }
  }

  // Get all feedback for a specific NGO
  Future<List<FeedbackModel>> getFeedbackForNgo(String ngoId) async {
    try {
      final snapshot = await _firestore
          .collection('feedback')
          .where('ngoId', isEqualTo: ngoId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get feedback: $e';
    }
  }

  // Check if the current user has already rated this NGO
  Future<FeedbackModel?> getUserFeedbackForNgo(String ngoId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return null;
      }

      final snapshot = await _firestore
          .collection('feedback')
          .where('ngoId', isEqualTo: ngoId)
          .where('donorId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return FeedbackModel.fromMap(snapshot.docs.first.data());
    } catch (e) {
      print('Error getting user feedback: $e');
      return null;
    }
  }

  // Calculate and update the average rating for an NGO
  Future<void> _updateNgoAverageRating(String ngoId) async {
    try {
      final snapshot = await _firestore
          .collection('feedback')
          .where('ngoId', isEqualTo: ngoId)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No feedback documents found for NGO: $ngoId');
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      for (var doc in snapshot.docs) {
        var ratingValue = doc.data()['rating'];
        if (ratingValue is int) {
          totalRating += (ratingValue as int).toDouble();
        } else if (ratingValue is double) {
          totalRating += ratingValue;
        } else {
          // Try to parse string or other types
          final parsedValue = double.tryParse(ratingValue.toString());
          if (parsedValue != null) {
            totalRating += parsedValue;
          }
        }
      }
      
      final averageRating = totalRating / snapshot.docs.length;
      
      print('Updating NGO $ngoId with new averageRating: $averageRating, feedbackCount: ${snapshot.docs.length}');
      
      // Update the NGO's profile with the new average rating
      await _firestore
          .collection('users')
          .doc(ngoId)
          .collection('ngo_details')
          .doc('profile')
          .set({
        'rating': averageRating,
        'feedbackCount': snapshot.docs.length,
      }, SetOptions(merge: true)); // Using merge to not overwrite other fields
      
      print('Successfully updated NGO rating data in Firestore');
    } catch (e) {
      print('Error updating NGO average rating: $e');
    }
  }
}