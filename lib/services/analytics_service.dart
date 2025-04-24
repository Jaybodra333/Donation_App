import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import 'auth_service.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get donation trends over time
  Future<Map<String, dynamic>> getDonationTrends() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'No authenticated user found';
      }

      final userModel = await _authService.getCurrentUserModel();
      final isNGO = userModel?.role.toLowerCase() == 'ngo';
      
      QuerySnapshot snapshot;
      if (isNGO) {
        // For NGOs, get only their assigned donations
        snapshot = await _firestore
            .collection('donations')
            .where('assignedTo', isEqualTo: user.uid)
            .orderBy('createdAt')
            .get();
      } else {
        // For donors, get only their donated items
        snapshot = await _firestore
            .collection('donations')
            .where('donorId', isEqualTo: user.uid)
            .orderBy('createdAt')
            .get();
      }

      // Group donations by month
      final Map<String, int> monthlyTrends = {};
      final Map<String, int> categoryTrends = {};
      final Map<String, int> statusCounts = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = DateTime.parse(data['createdAt']);
        final monthKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        
        // Update monthly trends
        monthlyTrends[monthKey] = (monthlyTrends[monthKey] ?? 0) + 1;
        
        // Update category trends
        final category = data['category'] as String;
        categoryTrends[category] = (categoryTrends[category] ?? 0) + 1;
        
        // Update status counts
        final status = data['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'monthlyTrends': monthlyTrends,
        'categoryTrends': categoryTrends,
        'statusCounts': statusCounts,
        'totalDonations': snapshot.docs.length,
      };
    } catch (e) {
      print('Error getting donation trends: $e');
      throw 'Failed to get donation trends: $e';
    }
  }

  // Get geographic distribution of donations
  Future<Map<String, int>> getGeographicDistribution() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'No authenticated user found';
      }

      final userModel = await _authService.getCurrentUserModel();
      final isNGO = userModel?.role.toLowerCase() == 'ngo';
      
      QuerySnapshot snapshot;
      if (isNGO) {
        // For NGOs, get only their assigned donations
        snapshot = await _firestore
            .collection('donations')
            .where('assignedTo', isEqualTo: user.uid)
            .get();
      } else {
        // For donors, get all donations if they want to see the impact
        snapshot = await _firestore
            .collection('donations')
            .where('donorId', isEqualTo: user.uid)
            .get();
      }

      // Group donations by location
      final Map<String, int> locationCounts = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String location = data['location'] as String? ?? 'Unknown';
        
        // Extract just the city/region for simpler grouping
        if (location.contains(',')) {
          location = location.split(',')[0].trim();
        }
        
        locationCounts[location] = (locationCounts[location] ?? 0) + 1;
      }

      return locationCounts;
    } catch (e) {
      print('Error getting geographic distribution: $e');
      throw 'Failed to get geographic distribution: $e';
    }
  }

  // Get impact metrics
  Future<Map<String, dynamic>> getImpactMetrics() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw 'No authenticated user found';
      }

      final userModel = await _authService.getCurrentUserModel();
      final isNGO = userModel?.role.toLowerCase() == 'ngo';
      
      QuerySnapshot snapshot;
      if (isNGO) {
        // For NGOs, get only completed donations
        snapshot = await _firestore
            .collection('donations')
            .where('assignedTo', isEqualTo: user.uid)
            .where('status', isEqualTo: 'completed')
            .get();
      } else {
        // For donors, get their completed donations
        snapshot = await _firestore
            .collection('donations')
            .where('donorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'completed')
            .get();
      }

      // Count total completed donations
      final int completedCount = snapshot.docs.length;
      
      // Count by category
      final Map<String, int> categoryImpact = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String;
        categoryImpact[category] = (categoryImpact[category] ?? 0) + 1;
      }

      // Get total benefited NGOs (for donor) or donors (for NGO)
      Set<String> uniquePartners = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (isNGO) {
          uniquePartners.add(data['donorId'] as String);
        } else {
          if (data['assignedTo'] != null) {
            uniquePartners.add(data['assignedTo'] as String);
          }
        }
      }

      return {
        'completedDonations': completedCount,
        'categoryImpact': categoryImpact,
        'uniquePartners': uniquePartners.length,
        'estimatedImpact': completedCount * 5, // Simple metric: 5 people helped per donation
      };
    } catch (e) {
      print('Error getting impact metrics: $e');
      throw 'Failed to get impact metrics: $e';
    }
  }

  // Get all analytics in one call
  Future<Map<String, dynamic>> getAllAnalytics() async {
    try {
      final trends = await getDonationTrends();
      final geographicData = await getGeographicDistribution();
      final impact = await getImpactMetrics();

      return {
        'trends': trends,
        'geographic': geographicData,
        'impact': impact,
      };
    } catch (e) {
      print('Error getting all analytics: $e');
      throw 'Failed to get analytics: $e';
    }
  }
}