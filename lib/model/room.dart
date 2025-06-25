// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:hotel_booking_app/model/hotel.dart';

// // class Room {
// //   String id;
// //   String hotelId;
// //   String type;
// //   double price;
// //   DateTime? startDate;
// //   DateTime? endDate;
// //   int? guestCount;
// //   double? totalPrice;

// //   Room({
// //     required this.id,
// //     required this.hotelId,
// //     required this.type,
// //     required this.price,
// //     this.startDate,
// //     this.endDate,
// //     this.guestCount,
// //     this.totalPrice,
// //   });

// //   Map<String, dynamic> toMap() {
// //     return {
// //       'hotelId': hotelId,
// //       'type': type,
// //       'price': price,
// //       'startDate': startDate?.toIso8601String(),
// //       'endDate': endDate?.toIso8601String(),
// //       'guestCount': guestCount,
// //       'totalPrice': totalPrice,
// //       'roomId': id, // Tambahkan roomId
// //     };
// //   }

// //   Future<Hotel?> fetchHotel() async {
// //     return await Hotel.fetchHotelDetails(hotelId);
// //   }
// // }

// // extension RoomBooking on Room {
// //   Future<void> bookRoom() async {
// //     // 1. Ambil detail hotel
// //     final hotel = await fetchHotel();
// //     if (hotel == null) {
// //       throw Exception('Hotel not found');
// //     }

// //     // 2. Persiapkan data untuk disimpan
// //     final docRef = FirebaseFirestore.instance
// //         .collection('book_history')
// //         .doc(); // auto-generate ID
// //     final bookingData = {
// //       'booking_id': docRef.id,
// //       'created_at': FieldValue.serverTimestamp(),
// //       'hotel_name': hotel.name,
// //       'start_date': startDate?.toIso8601String(),
// //       'end_date': endDate?.toIso8601String(),
// //       'total_price': totalPrice,
// //       'room_summary': type,
// //     };

// //     // 3. Simpan ke Firestore
// //     await docRef.set(bookingData);
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/hotel.dart';

// class Room {
//   String id;
//   String hotelId;
//   String type;
//   double price;
//   DateTime? startDate;
//   DateTime? endDate;
//   int? guestCount;
//   double? totalPrice;
//   List<Booking> bookings = []; // List to hold bookings

//   Room({
//     required this.id,
//     required this.hotelId,
//     required this.type,
//     required this.price,
//     this.startDate,
//     this.endDate,
//     this.guestCount,
//     this.totalPrice,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'hotelId': hotelId,
//       'type': type,
//       'price': price,
//       'startDate': startDate?.toIso8601String(),
//       'endDate': endDate?.toIso8601String(),
//       'guestCount': guestCount,
//       'totalPrice': totalPrice,
//       'roomId': id,
//     };
//   }

//   Future<Hotel?> fetchHotel() async {
//     return await Hotel.fetchHotelDetails(hotelId);
//   }

//   // Future<void> fetchBookings() async {
//   //   final snapshot = await FirebaseFirestore.instance
//   //       .collection('book_history')
//   //       .where('room_id', isEqualTo: id)
//   //       .get();

//   //   bookings = snapshot.docs.map((doc) {
//   //     return Booking(
//   //       startDate: DateTime.parse(doc['start_date']),
//   //       endDate: DateTime.parse(doc['end_date']),
//   //       totalPrice: doc['total_price'],
//   //     );
//   //   }).toList();
//   // }

//   // Future<void> fetchBookings() async {
//   //   final snapshot = await FirebaseFirestore.instance
//   //       .collection('book_history')
//   //       .where('room_id', isEqualTo: id)
//   //       .get();

//   //   bookings = snapshot.docs.map((doc) {
//   //     return Booking(
//   //       startDate: DateTime.parse(doc['start_date']),
//   //       endDate: DateTime.parse(doc['end_date']),
//   //       totalPrice: doc['total_price'],
//   //     );
//   //   }).toList();

//   //   // Debugging: Print the bookings fetched
//   //   print('Bookings for room $id: ${bookings.length} found');
//   //   for (var booking in bookings) {
//   //     print(
//   //         'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
//   //   }
//   // }

//   Future<void> fetchBookings() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('book_history')
//         .where('room_id', isEqualTo: id)
//         .get();

//     bookings = snapshot.docs.map((doc) {
//       return Booking(
//         startDate: DateTime.parse(doc['start_date']),
//         endDate: DateTime.parse(doc['end_date']),
//         totalPrice: doc['total_price'],
//         userId: doc['user_id'], // Retrieve userId from the document
//       );
//     }).toList();

//     // Debugging: Print the bookings fetched
//     print('Bookings for room $id: ${bookings.length} found');
//     for (var booking in bookings) {
//       print(
//           'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
//     }
//   }

//   // Future<void> fetchBookings(String userId) async {
//   //   final snapshot = await FirebaseFirestore.instance
//   //       .collection('book_history')
//   //       .where('room_id', isEqualTo: id)
//   //       .where('user_id', isEqualTo: userId) // Filter by user_id
//   //       .get();

//   //   bookings = snapshot.docs.map((doc) {
//   //     return Booking(
//   //       startDate: DateTime.parse(doc['start_date']),
//   //       endDate: DateTime.parse(doc['end_date']),
//   //       totalPrice: doc['total_price'],
//   //     );
//   //   }).toList();

//   //   // Debugging: Print the bookings fetched
//   //   print('Bookings for room $id: ${bookings.length} found');
//   //   for (var booking in bookings) {
//   //     print(
//   //         'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
//   //   }
//   // }
// }

// class Booking {
//   DateTime startDate;
//   DateTime endDate;
//   double totalPrice;
//   String userId;

//   Booking({
//     required this.startDate,
//     required this.endDate,
//     required this.totalPrice,
//     required this.userId,
//   });
// }

// // extension RoomBooking on Room {
// //   Future<void> bookRoom() async {
// //     final hotel = await fetchHotel();
// //     if (hotel == null) {
// //       throw Exception('Hotel not found');
// //     }

// //     final docRef = FirebaseFirestore.instance.collection('book_history').doc();
// //     final bookingData = {
// //       'booking_id': docRef.id,
// //       'created_at': FieldValue.serverTimestamp(),
// //       'hotel_name': hotel.name,
// //       'start_date': startDate?.toIso8601String(),
// //       'end_date': endDate?.toIso8601String(),
// //       'total_price': totalPrice,
// //       'room_summary': type,
// //       'room_id': id, // Add room_id to the booking
// //     };

// //     await docRef.set(bookingData);
// //   }
// // }

// extension RoomBooking on Room {
//   Future<void> bookRoom(String userId) async {
//     final hotel = await fetchHotel();
//     if (hotel == null) {
//       throw Exception('Hotel not found');
//     }

//     // Check if the user already has an active booking for this room
//     final existingBookings = await FirebaseFirestore.instance
//         .collection('book_history')
//         .where('room_id', isEqualTo: id)
//         .where('user_id',
//             isEqualTo: userId) // Assuming you have a user_id field
//         .where('end_date', isGreaterThan: DateTime.now().toIso8601String())
//         .get();

//     if (existingBookings.docs.isNotEmpty) {
//       throw Exception('You already have an active booking for this room.');
//     }

//     final docRef = FirebaseFirestore.instance.collection('book_history').doc();
//     final bookingData = {
//       'booking_id': docRef.id,
//       'created_at': FieldValue.serverTimestamp(),
//       'hotel_name': hotel.name,
//       'start_date': startDate?.toIso8601String(),
//       'end_date': endDate?.toIso8601String(),
//       'total_price': totalPrice,
//       'room_summary': type,
//       'room_id': id,
//       'user_id': userId, // Add user_id to the booking
//     };

//     await docRef.set(bookingData);
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/hotel.dart'; // Pastikan Hotel model Anda diimpor

// class Room {
//   String id;
//   String hotelId;
//   String type;
//   double price;
//   DateTime? startDate; // Ini adalah data sementara untuk proses seleksi di UI
//   DateTime? endDate;   // Ini adalah data sementara untuk proses seleksi di UI
//   int? guestCount;     // Ini adalah data sementara untuk proses seleksi di UI
//   double? totalPrice;  // Ini adalah data sementara untuk proses seleksi di UI

//   List<Booking> bookings = []; // List to hold bookings fetched for this room

//   Room({
//     required this.id,
//     required this.hotelId,
//     required this.type,
//     required this.price,
//     this.startDate,
//     this.endDate,
//     this.guestCount,
//     this.totalPrice,
//   });

//   // Metode toMap() ini biasanya untuk menyimpan objek Room ke koleksi 'rooms'
//   Map<String, dynamic> toMap() {
//     return {
//       'hotelId': hotelId,
//       'type': type,
//       'price': price,
//       // startDate, endDate, guestCount, totalPrice tidak relevan untuk disimpan di dokumen Room itu sendiri,
//       // melainkan di dokumen booking history.
//       'roomId': id, // Menambahkan ID kamar sebagai field
//     };
//   }

//   // Factory constructor untuk membuat Room dari Firestore DocumentSnapshot
//   factory Room.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Room(
//       id: doc.id,
//       hotelId: data['hotelId'] ?? '', // Pastikan 'hotelId' ada di dokumen Room
//       type: data['type'] ?? 'Standard', // Default value jika null
//       price: (data['price'] as num?)?.toDouble() ?? 0.0, // Default value jika null
//     );
//   }

//   // Fungsi untuk mengambil detail Hotel terkait
//   Future<Hotel?> fetchHotel() async {
//     return await Hotel.fetchHotelDetails(hotelId);
//   }

//   // Fungsi untuk mengambil booking yang terkait dengan kamar ini
//   Future<void> fetchBookings() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('book_history')
//           .where('room_id', isEqualTo: id)
//           .get();

//       bookings = snapshot.docs.map((doc) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         return Booking(
//           id: doc.id, // ID dokumen booking dari Firestore
//           startDate: (data['start_date'] is String)
//               ? DateTime.parse(data['start_date'])
//               : (data['start_date'] as Timestamp).toDate(),
//           endDate: (data['end_date'] is String)
//               ? DateTime.parse(data['end_date'])
//               : (data['end_date'] as Timestamp).toDate(),
//           totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0.0,
//           userId: data['user_id'] ?? '',
//           hotelId: data['hotel_id'] ?? '', // <--- PENTING: Ambil hotelId
//           hotelName: data['hotel_name'] ?? 'Unknown Hotel', // <--- PENTING: Ambil hotelName
//           roomId: data['room_id'] ?? '',
//           roomSummary: data['room_summary'] ?? '',
//           createdAt: (data['created_at'] as Timestamp).toDate(),
//           bookingId: data['booking_id'] ?? '',
//         );
//       }).toList();

//       // debugPrint('Bookings for room $id: ${bookings.length} found');
//       for (var booking in bookings) {
//         // debugPrint(
//         //     'Booking: Hotel ID: ${booking.hotelId}, From ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
//       }
//     } catch (e) {
//       // debugPrint('Error fetching bookings for room $id: $e');
//     }
//   }
// }

// // DEFINISI KELAS BOOKING YANG BENAR
// class Booking {
//   String id; // ID dokumen booking di Firestore
//   String userId;
//   String hotelId; // <--- BARU: ID hotel yang dibooking
//   String hotelName; // <--- BARU: Nama hotel yang dibooking
//   String roomId; // <--- BARU: ID kamar yang dibooking
//   String roomSummary; // <--- BARU: Ringkasan tipe kamar
//   DateTime startDate;
//   DateTime endDate;
//   double totalPrice;
//   DateTime createdAt; // <--- BARU: Waktu pembuatan booking
//   String bookingId; // <--- BARU: ID booking yang unik

//   Booking({
//     required this.id,
//     required this.userId,
//     required this.hotelId,
//     required this.hotelName,
//     required this.roomId,
//     required this.roomSummary,
//     required this.startDate,
//     required this.endDate,
//     required this.totalPrice,
//     required this.createdAt,
//     required this.bookingId,
//   });

//   // Factory constructor untuk membuat Booking dari Firestore DocumentSnapshot
//   factory Booking.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Booking(
//       id: doc.id,
//       userId: data['user_id'] ?? '',
//       hotelId: data['hotel_id'] ?? '',
//       hotelName: data['hotel_name'] ?? 'Unknown Hotel',
//       roomId: data['room_id'] ?? '',
//       roomSummary: data['room_summary'] ?? 'Unknown Room Type',
//       startDate: (data['start_date'] is String)
//           ? DateTime.parse(data['start_date'])
//           : (data['start_date'] as Timestamp).toDate(),
//       endDate: (data['end_date'] is String)
//           ? DateTime.parse(data['end_date'])
//           : (data['end_date'] as Timestamp).toDate(),
//       totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0.0,
//       createdAt: (data['created_at'] as Timestamp).toDate(),
//       bookingId: data['booking_id'] ?? '',
//     );
//   }
// }


// // EXTENSION UNTUK FUNGSI BOOKING PADA ROOM
// extension RoomBooking on Room {
//   Future<void> bookRoom(String userId) async {
//     // Ambil detail hotel untuk mendapatkan nama hotel
//     final hotel = await fetchHotel();
//     if (hotel == null) {
//       throw Exception('Hotel not found for ID: $hotelId');
//     }
    
//     // Debugging: Cek apakah hotelId dan data lain valid
//     // debugPrint('Attempting to book room: Room ID: $id, Hotel ID: $hotelId, User ID: $userId');
//     // debugPrint('Booking dates: $startDate to $endDate, Guests: $guestCount, Total Price: $totalPrice');


//     // Periksa apakah ada booking aktif lainnya untuk kamar ini pada tanggal yang dipilih
//     final existingBookingsSnapshot = await FirebaseFirestore.instance
//         .collection('book_history')
//         .where('room_id', isEqualTo: id)
//         .get();

//     for (var doc in existingBookingsSnapshot.docs) {
//       final existingStartDate = DateTime.parse(doc['start_date']);
//       final existingEndDate = DateTime.parse(doc['end_date']);

//       // Periksa overlap tanggal
//       // Jika (startDate < existingEndDate) AND (endDate > existingStartDate)
//       bool isOverlapping = (startDate!.isBefore(existingEndDate) && endDate!.isAfter(existingStartDate));
//       if (isOverlapping) {
//         throw Exception('This room is already booked for a portion of the selected dates.');
//       }
//     }

//     final docRef = FirebaseFirestore.instance.collection('book_history').doc(); // Firestore will generate unique ID
//     final bookingData = {
//       'booking_id': docRef.id, // Menggunakan ID dokumen Firestore sebagai booking_id
//       'created_at': FieldValue.serverTimestamp(),
//       'hotel_id': hotelId,     // <--- INI ADALAH PERBAIKAN PENTING
//       'hotel_name': hotel.name, // Menyimpan nama hotel untuk kemudahan tampilan di history
//       'start_date': startDate?.toIso8601String(),
//       'end_date': endDate?.toIso8601String(),
//       'total_price': totalPrice,
//       'room_summary': type,
//       'room_id': id,
//       'user_id': userId,
//     };

//     await docRef.set(bookingData);
//     // debugPrint('Booking successfully recorded in Firestore with ID: ${docRef.id} for hotel ID: $hotelId');
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart'; // Pastikan Hotel model Anda diimpor

class Room {
  String id;
  String hotelId;
  String type;
  double price;
  int? guestCount; // Ini adalah kapasitas kamar
  
  // Ini adalah data sementara untuk proses seleksi di UI saat booking
  DateTime? startDate; 
  DateTime? endDate; 
  double? totalPrice; 

  List<Booking> bookings = []; // List to hold bookings fetched for this room

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    this.guestCount, // Tambahkan guestCount sebagai properti Room
    this.startDate,
    this.endDate,
    this.totalPrice,
  });

  // Metode toMap() ini biasanya untuk menyimpan objek Room ke koleksi 'rooms'
  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'type': type,
      'price': price,
      'guestCount': guestCount, // Simpan guestCount sebagai bagian dari data Room
      'roomId': id, // Menambahkan ID kamar sebagai field
    };
  }

  // Factory constructor untuk membuat Room dari Firestore DocumentSnapshot
  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      hotelId: data['hotelId'] ?? '', // Pastikan 'hotelId' ada di dokumen Room
      type: data['type'] ?? 'Standard', // Default value jika null
      price: (data['price'] as num?)?.toDouble() ?? 0.0, // Default value jika null
      guestCount: (data['guestCount'] as num?)?.toInt(), // Baca guestCount
    );
  }

  // Fungsi untuk mengambil detail Hotel terkait
  Future<Hotel?> fetchHotel() async {
    return await Hotel.fetchHotelDetails(hotelId);
  }

  // Fungsi untuk mengambil booking yang terkait dengan kamar ini
  Future<void> fetchBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('book_history')
          .where('room_id', isEqualTo: id)
          .get();

      bookings = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Booking.fromFirestore(doc); // Use the factory constructor for Booking
      }).toList();

      debugPrint('Bookings for room $id: ${bookings.length} found');
    } catch (e) {
      debugPrint('Error fetching bookings for room $id: $e');
    }
  }
}

// DEFINISI KELAS BOOKING YANG BENAR
class Booking {
  String id; // ID dokumen booking di Firestore
  String userId;
  String hotelId;
  String hotelName;
  String roomId;
  String roomSummary;
  DateTime startDate;
  DateTime endDate;
  int guestCount; // <--- PENTING: Tambahkan ini ke model Booking
  double totalPrice;
  DateTime createdAt;
  String bookingId; // Unique ID for the booking record

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomSummary,
    required this.startDate,
    required this.endDate,
    required this.guestCount, // <--- Required di constructor
    required this.totalPrice,
    required this.createdAt,
    required this.bookingId,
  });

  // Factory constructor untuk membuat Booking dari Firestore DocumentSnapshot
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['user_id'] ?? '',
      hotelId: data['hotel_id'] ?? '',
      hotelName: data['hotel_name'] ?? 'Unknown Hotel',
      roomId: data['room_id'] ?? '',
      roomSummary: data['room_summary'] ?? 'Unknown Room Type',
      startDate: (data['start_date'] is String)
          ? DateTime.parse(data['start_date'])
          : (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] is String)
          ? DateTime.parse(data['end_date'])
          : (data['end_date'] as Timestamp).toDate(),
      guestCount: (data['guest_count'] as num?)?.toInt() ?? 1, // <--- Baca guest_count dari Firestore
      totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      bookingId: data['booking_id'] ?? '',
    );
  }
}

// EXTENSION UNTUK FUNGSI BOOKING PADA ROOM
extension RoomBooking on Room {
  Future<void> bookRoom(String userId) async {
    final hotel = await fetchHotel();
    if (hotel == null) {
      throw Exception('Hotel not found for ID: $hotelId');
    }
    
    // Periksa apakah ada booking aktif lainnya untuk kamar ini pada tanggal yang dipilih
    final existingBookingsSnapshot = await FirebaseFirestore.instance
        .collection('book_history')
        .where('room_id', isEqualTo: id)
        .get();

    for (var doc in existingBookingsSnapshot.docs) {
      final existingStartDate = DateTime.parse(doc['start_date']);
      final existingEndDate = DateTime.parse(doc['end_date']);

      bool isOverlapping = (startDate!.isBefore(existingEndDate) && endDate!.isAfter(existingStartDate));
      if (isOverlapping) {
        throw Exception('This room is already booked for a portion of the selected dates.');
      }
    }

    final docRef = FirebaseFirestore.instance.collection('book_history').doc();
    final bookingData = {
      'booking_id': docRef.id,
      'created_at': FieldValue.serverTimestamp(),
      'hotel_id': hotelId,
      'hotel_name': hotel.name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'total_price': totalPrice,
      'room_summary': type,
      'room_id': id,
      'user_id': userId,
      'guest_count': guestCount, // <--- PENTING: Simpan guest_count di sini
    };

    await docRef.set(bookingData);
    debugPrint('Booking successfully recorded in Firestore with ID: ${docRef.id} for hotel ID: $hotelId');
  }
}
