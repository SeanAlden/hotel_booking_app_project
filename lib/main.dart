import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/services/check_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting(
      'id_ID', null); // Inisialisasi lokal bahasa Indonesia
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Hotel Booking App",
      debugShowCheckedModeBanner: false,
      home: CheckAuth(), // Ini akan redirect ke HomePage jika sudah login
    );
  }
}
