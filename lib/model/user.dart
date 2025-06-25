import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final DateTime createdAt;
  final String userType;
  final String? fcmToken; 

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.createdAt,
    this.userType = 'user',
    this.fcmToken, 
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userType: map['userType'] ?? 'user',
      fcmToken: map['fcmToken'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'createdAt': createdAt,
      'userType': userType,
      'fcmToken': fcmToken, 
    };
  }

  static Future<AppUser?> fetchUserById(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('AppUser: Error fetching user $uid: $e');
      return null;
    }
  }

  Future<void> updateFcmToken(String? newToken) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': newToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      debugPrint('AppUser: FCM Token updated in Firestore for user $uid to $newToken');
    } catch (e) {
      debugPrint('AppUser: Error updating FCM token for user $uid: $e');
    }
  }
}
