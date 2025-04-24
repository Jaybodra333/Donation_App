import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter for auth instance
  FirebaseAuth get auth => _auth;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user model with null safety
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      // Ensure role has a default value if null
      data['role'] = data['role'] ?? 'donor';
      
      return UserModel.fromMap(data);
    } catch (e) {
      print('Error in getCurrentUserModel: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, 
      String password, 
      String name,
      UserRole role, 
      {String? organizationName}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        role: role.toString().split('.').last, // Convert enum to string properly
        organizationName: organizationName,
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'An account already exists for that email.';
      }
      throw e.message ?? 'An error occurred during sign up.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided.';
      }
      throw e.message ?? 'An error occurred during sign in.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Update user profile data
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .update(updatedUser.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      throw 'Failed to update profile. Please try again.';
    }
  }
  
  // Update user password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw 'User not authenticated';
      
      // Re-authenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw 'Current password is incorrect.';
      }
      throw e.message ?? 'Failed to update password.';
    } catch (e) {
      print('Error updating password: $e');
      throw 'Failed to update password. Please try again.';
    }
  }
}