import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/pages/guest_home_page.dart';
import 'package:hotel_booking_app/widgets/main_nav.dart';

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  String? _userType;
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuthListener();
    });
  }

  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (mounted) {
          setState(() {
            _currentUser = null;
            _userType = null;
            _isLoading = false;
          });
        }
      } else {
        _currentUser = user;
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            if (mounted) {
              setState(() {
                _userType = userDoc['userType'] ?? 'user';
                _isLoading = false;
              });
            }
          } else {
            debugPrint("User document not found for UID: ${user.uid}");
            if (mounted) {
              setState(() {
                _userType = 'user';
                _isLoading = false;
              });
            }
          }
        } catch (e) {
          debugPrint("Error fetching user role: $e");
          if (mounted) {
            setState(() {
              _userType = 'user';
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
        return MainNav(
          isLoggedIn: true,
          userType: _userType,
        );
      } else {
        return const GuestHomePage();
      }
    }
  }
}
