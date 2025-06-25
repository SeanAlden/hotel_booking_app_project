import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/pages/admin_book_page.dart';
import 'package:hotel_booking_app/pages/favorite_page.dart';
import 'package:hotel_booking_app/pages/guest_home_page.dart';
import 'package:hotel_booking_app/pages/history_page.dart';
import 'package:hotel_booking_app/pages/home_page.dart';
import 'package:hotel_booking_app/pages/login_page.dart';
import 'package:hotel_booking_app/pages/profile_page.dart';
import 'package:hotel_booking_app/pages/admin_home_page.dart';
import 'package:hotel_booking_app/pages/user_view_page.dart'; 

class MainNav extends StatefulWidget {
  final bool isLoggedIn;
  final String? userType; // Added userType to determine navigation items
  const MainNav({super.key, required this.isLoggedIn, this.userType});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    // Logic for guests trying to access non-home tabs
    if (!widget.isLoggedIn && index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please login to access this feature."),
            backgroundColor: Colors.red),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // After logout, pushReplacement to LoginPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages;
    List<BottomNavigationBarItem> navItems;
    // String appBarTitle = "Hotel Book App"; // Default title

    if (widget.userType == 'admin') {
      // Admin specific pages and navigation
      pages = [
        const AdminHomePage(), // Admin's main dashboard
        // const Center(child: Text("Admin Users Page", style: TextStyle(fontSize: 24))), // Placeholder
        const UserViewPage(),
        // const Center(child: Text("Bookings Page", style: TextStyle(fontSize: 24))), // Placeholder
        const AdminBookPage(), // Admin can also have a profile page
        const ProfilePage(), // Admin can also have a profile page
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
      // appBarTitle = "Admin Dashboard";
    } else if (widget.isLoggedIn && widget.userType == 'user') {
      // Logged-in regular user pages and navigation
      pages = [
        const HomePage(),
        const HistoryPage(),
        const FavoritePage(),
        const ProfilePage(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorite',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
      // appBarTitle = "User Home";
    } else {
      // Guest (not logged in) pages and navigation
      pages = [
        const GuestHomePage(),
        // Dummy containers for non-accessible tabs for guests
        Container(),
        Container(),
        Container(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorite',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: navItems,
      ),
    );
  }
}
