import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { donor, ngo }

class UserModel {
  final String uid;
  String name;
  final String email;
  final String role;
  String? phoneNumber;
  String? address;
  String? organizationName;
  String? profileImagePath; // Local path reference
  String? bio;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.address,
    this.organizationName,
    this.profileImagePath,
    this.bio,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'donor',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      organizationName: data['organizationName'],
      bio: data['bio'],
      // Note: profile image path is not stored in Firebase, only referenced locally
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'phoneNumber': phoneNumber,
        'address': address,
        'organizationName': organizationName,
        'bio': bio,
        // profileImagePath is not stored in Firebase
      };

  // Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? address,
    String? organizationName,
    String? profileImagePath,
    String? bio,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: this.email,
      role: this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      organizationName: organizationName ?? this.organizationName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      bio: bio ?? this.bio,
    );
  }

  static UserRole stringToRole(String role) {
    return UserRole.values.firstWhere(
      (e) => e.toString() == 'UserRole.$role',
      orElse: () => UserRole.donor,
    );
  }

  static String roleToString(UserRole role) {
    return role.toString().split('.').last;
  }

  bool isDonor() => role.trim().toLowerCase() == 'donor';
  bool isNGO() => role.trim().toLowerCase() == 'ngo';
}