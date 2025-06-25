import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/pages/guest_home_page.dart';
import 'package:hotel_booking_app/widgets/main_nav.dart'; // Using MainNav for all authenticated users

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  String? _userType;
  bool _isLoading = true;
  User? _currentUser; // To hold the current authenticated user

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuthListener();
    });
  }

  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // User is not logged in
        if (mounted) {
          setState(() {
            _currentUser = null;
            _userType = null;
            _isLoading = false;
          });
        }
      } else {
        // User is logged in, fetch their role from Firestore
        _currentUser = user;
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            if (mounted) {
              setState(() {
                _userType = userDoc['userType'] ?? 'user'; // Default to 'user'
                _isLoading = false;
              });
            }
          } else {
            // User document not found in Firestore, assume regular user
            debugPrint("User document not found for UID: ${user.uid}");
            if (mounted) {
              setState(() {
                _userType = 'user'; // Fallback to 'user'
                _isLoading = false;
              });
            }
          }
        } catch (e) {
          debugPrint("Error fetching user role: $e");
          if (mounted) {
            setState(() {
              _userType = 'user'; // Fallback to 'user' on error
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      if (_currentUser != null) {
        // User is authenticated, pass userType to MainNav
        return MainNav(
          isLoggedIn: true,
          userType: _userType, // Pass the determined userType
        );
      } else {
        // User is not authenticated, show LoginPage
        return const GuestHomePage();
      }
    }
  }
}
