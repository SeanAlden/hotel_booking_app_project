// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/services/check_auth.dart'; // Import CheckAuth

// class GetStartedScreen extends StatelessWidget {
//   const GetStartedScreen({super.key});

//   // Key untuk menyimpan status pertama kali buka aplikasi
//   // Ubah dari _firstLaunchKey menjadi firstLaunchKey (hapus garis bawah)
//   static const String firstLaunchKey = 'first_launch_done';

//   Future<void> _markFirstLaunchDone() async {
//     final Box<bool> appSettingsBox = await Hive.openBox<bool>('app_settings');
//     await appSettingsBox.put(firstLaunchKey, true); // Gunakan firstLaunchKey
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Tambahkan gambar, teks, atau elemen UI lainnya untuk halaman "Get Started" Anda
//             Image.asset(
//               'assets/images/hotelstartscreen.jpg', // Ganti dengan path gambar Anda
//               height: 200,
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'Selamat Datang di Aplikasi Pemesanan Hotel!',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 32.0),
//               child: Text(
//                 'Temukan dan pesan kamar hotel impian Anda dengan mudah.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 48),
//             ElevatedButton(
//               onPressed: () async {
//                 await _markFirstLaunchDone();
//                 // Setelah selesai, arahkan ke CheckAuth untuk menentukan rute selanjutnya
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(builder: (context) => const CheckAuth()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 'Mulai Sekarang',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/services/check_auth.dart';

// class GetStartedScreen extends StatelessWidget {
//   const GetStartedScreen({super.key});

//   static const String firstLaunchKey = 'first_launch_done';

//   Future<void> _markFirstLaunchDone() async {
//     final Box<bool> appSettingsBox = await Hive.openBox<bool>('app_settings');
//     await appSettingsBox.put(firstLaunchKey, true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], // Gradient biru
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Gambar di atas
//                 SizedBox(
//                   width: double.infinity,
//                   height: size.height * 0.45,
//                   child: Image.asset(
//                     'assets/images/hotelstartscreen.jpg',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Judul dan Deskripsi
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Selamat Datang!',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'Temukan dan pesan kamar hotel impian Anda dengan mudah dan cepat.',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 48),
//                 // Tombol
//                 ElevatedButton(
//                   onPressed: () async {
//                     await _markFirstLaunchDone();
//                     Navigator.of(context).pushReplacement(
//                       MaterialPageRoute(builder: (context) => const CheckAuth()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.blueAccent,
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     'Mulai Sekarang',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotel_booking_app/services/check_auth.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  static const String firstLaunchKey = 'first_launch_done';

  Future<void> _markFirstLaunchDone() async {
    final Box<bool> appSettingsBox = await Hive.openBox<bool>('app_settings');
    await appSettingsBox.put(firstLaunchKey, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/hotelstartscreen.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay gradient agar teks tetap terlihat
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Konten di atas gambar
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Selamat Datang!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Temukan dan pesan kamar hotel impian Anda dengan mudah dan cepat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () async {
                        await _markFirstLaunchDone();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const CheckAuth()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Mulai Sekarang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
