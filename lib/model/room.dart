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
//       'roomId': id, // Tambahkan roomId
//     };
//   }

//   Future<Hotel?> fetchHotel() async {
//     return await Hotel.fetchHotelDetails(hotelId);
//   }
// }

// extension RoomBooking on Room {
//   Future<void> bookRoom() async {
//     // 1. Ambil detail hotel
//     final hotel = await fetchHotel();
//     if (hotel == null) {
//       throw Exception('Hotel not found');
//     }

//     // 2. Persiapkan data untuk disimpan
//     final docRef = FirebaseFirestore.instance
//         .collection('book_history')
//         .doc(); // auto-generate ID
//     final bookingData = {
//       'booking_id': docRef.id,
//       'created_at': FieldValue.serverTimestamp(),
//       'hotel_name': hotel.name,
//       'start_date': startDate?.toIso8601String(),
//       'end_date': endDate?.toIso8601String(),
//       'total_price': totalPrice,
//       'room_summary': type,
//     };

//     // 3. Simpan ke Firestore
//     await docRef.set(bookingData);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/hotel.dart';

class Room {
  String id;
  String hotelId;
  String type;
  double price;
  DateTime? startDate;
  DateTime? endDate;
  int? guestCount;
  double? totalPrice;
  List<Booking> bookings = []; // List to hold bookings

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    this.startDate,
    this.endDate,
    this.guestCount,
    this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'type': type,
      'price': price,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'guestCount': guestCount,
      'totalPrice': totalPrice,
      'roomId': id,
    };
  }

  Future<Hotel?> fetchHotel() async {
    return await Hotel.fetchHotelDetails(hotelId);
  }

  // Future<void> fetchBookings() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('book_history')
  //       .where('room_id', isEqualTo: id)
  //       .get();

  //   bookings = snapshot.docs.map((doc) {
  //     return Booking(
  //       startDate: DateTime.parse(doc['start_date']),
  //       endDate: DateTime.parse(doc['end_date']),
  //       totalPrice: doc['total_price'],
  //     );
  //   }).toList();
  // }

  // Future<void> fetchBookings() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('book_history')
  //       .where('room_id', isEqualTo: id)
  //       .get();

  //   bookings = snapshot.docs.map((doc) {
  //     return Booking(
  //       startDate: DateTime.parse(doc['start_date']),
  //       endDate: DateTime.parse(doc['end_date']),
  //       totalPrice: doc['total_price'],
  //     );
  //   }).toList();

  //   // Debugging: Print the bookings fetched
  //   print('Bookings for room $id: ${bookings.length} found');
  //   for (var booking in bookings) {
  //     print(
  //         'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
  //   }
  // }

  Future<void> fetchBookings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('book_history')
        .where('room_id', isEqualTo: id)
        .get();

    bookings = snapshot.docs.map((doc) {
      return Booking(
        startDate: DateTime.parse(doc['start_date']),
        endDate: DateTime.parse(doc['end_date']),
        totalPrice: doc['total_price'],
        userId: doc['user_id'], // Retrieve userId from the document
      );
    }).toList();

    // Debugging: Print the bookings fetched
    print('Bookings for room $id: ${bookings.length} found');
    for (var booking in bookings) {
      print(
          'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
    }
  }

  // Future<void> fetchBookings(String userId) async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('book_history')
  //       .where('room_id', isEqualTo: id)
  //       .where('user_id', isEqualTo: userId) // Filter by user_id
  //       .get();

  //   bookings = snapshot.docs.map((doc) {
  //     return Booking(
  //       startDate: DateTime.parse(doc['start_date']),
  //       endDate: DateTime.parse(doc['end_date']),
  //       totalPrice: doc['total_price'],
  //     );
  //   }).toList();

  //   // Debugging: Print the bookings fetched
  //   print('Bookings for room $id: ${bookings.length} found');
  //   for (var booking in bookings) {
  //     print(
  //         'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
  //   }
  // }
}

class Booking {
  DateTime startDate;
  DateTime endDate;
  double totalPrice;
  String userId;

  Booking({
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.userId,
  });
}

// extension RoomBooking on Room {
//   Future<void> bookRoom() async {
//     final hotel = await fetchHotel();
//     if (hotel == null) {
//       throw Exception('Hotel not found');
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
//       'room_id': id, // Add room_id to the booking
//     };

//     await docRef.set(bookingData);
//   }
// }

extension RoomBooking on Room {
  Future<void> bookRoom(String userId) async {
    final hotel = await fetchHotel();
    if (hotel == null) {
      throw Exception('Hotel not found');
    }

    // Check if the user already has an active booking for this room
    final existingBookings = await FirebaseFirestore.instance
        .collection('book_history')
        .where('room_id', isEqualTo: id)
        .where('user_id',
            isEqualTo: userId) // Assuming you have a user_id field
        .where('end_date', isGreaterThan: DateTime.now().toIso8601String())
        .get();

    if (existingBookings.docs.isNotEmpty) {
      throw Exception('You already have an active booking for this room.');
    }

    final docRef = FirebaseFirestore.instance.collection('book_history').doc();
    final bookingData = {
      'booking_id': docRef.id,
      'created_at': FieldValue.serverTimestamp(),
      'hotel_name': hotel.name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'total_price': totalPrice,
      'room_summary': type,
      'room_id': id,
      'user_id': userId, // Add user_id to the booking
    };

    await docRef.set(bookingData);
  }
}
