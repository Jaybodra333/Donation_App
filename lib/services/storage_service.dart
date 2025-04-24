import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  // Get local profile image path
  Future<String?> getProfileImagePath(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, 'profile_$userId.jpg');
      final file = File(imagePath);
      
      if (await file.exists()) {
        return imagePath;
      }
      return null;
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  // Save profile image to local storage
  Future<String?> saveProfileImage(String userId, File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, 'profile_$userId.jpg');
      
      // Copy the selected image to the application documents directory
      final savedImage = await imageFile.copy(imagePath);
      return savedImage.path;
    } catch (e) {
      print('Error saving profile image: $e');
      return null;
    }
  }

  // Delete profile image from local storage
  Future<bool> deleteProfileImage(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, 'profile_$userId.jpg');
      final file = File(imagePath);
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }
}