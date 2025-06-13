// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hotel_booking_app/home_page.dart';
// import 'login_page.dart';

// class CheckAuth extends StatelessWidget {
//   const CheckAuth({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(), // realtime check
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Menampilkan loading saat sedang cek status login
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasData) {
//           // User sudah login
//           return const HomePage();
//         }

//         // User belum login
//         return const LoginPage();
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/widgets/main_nav.dart';
// import 'pages/home_page.dart';
// import 'guest_home_page.dart';
// import 'history_page.dart';
// import 'favorite_page.dart';
// import 'profile_page.dart';
// import 'pages/login_page.dart';

class CheckAuth extends StatelessWidget {
  const CheckAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.hasData;
        return MainNav(isLoggedIn: isLoggedIn);
      },
    );
  }
}
