import 'package:flutter/material.dart';
import 'package:hotel_booking_app/pages/favorite_page.dart';
import 'package:hotel_booking_app/pages/guest_home_page.dart';
import 'package:hotel_booking_app/pages/history_page.dart';
import 'package:hotel_booking_app/pages/home_page.dart';
import 'package:hotel_booking_app/pages/login_page.dart';
import 'package:hotel_booking_app/pages/profile_page.dart';

class MainNav extends StatefulWidget {
  final bool isLoggedIn;
  const MainNav({super.key, required this.isLoggedIn});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (!widget.isLoggedIn && index != 0) {
      // Jika guest, dan bukan index 0 (bukan Home/GuestHome), arahkan ke Login
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = widget.isLoggedIn
        ? [
            const HomePage(),
            const HistoryPage(),
            const FavoritePage(),
            const ProfilePage(),
          ]
        : [
            const GuestHomePage(),
            Container(), // dummy karena guest tidak boleh akses
            Container(),
            Container(),
          ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
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
        ],
      ),
    );
  }
}
