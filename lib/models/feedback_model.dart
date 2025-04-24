import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String ngoId;
  final String donorId;
  final String donorName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.ngoId,
    required this.donorId,
    required this.donorName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> data) {
    // Handle rating whether it's stored as int or double
    double rating;
    if (data['rating'] is int) {
      rating = (data['rating'] as int).toDouble();
    } else {
      rating = data['rating'] as double;
    }
    
    return FeedbackModel(
      id: data['id'],
      ngoId: data['ngoId'],
      donorId: data['donorId'],
      donorName: data['donorName'],
      rating: rating,
      comment: data['comment'],
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ngoId': ngoId,
      'donorId': donorId,
      'donorName': donorName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}