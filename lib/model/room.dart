import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';

class Room {
  String id;
  String hotelId;
  String type;
  double price;
  int? guestCount; 
  
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
        // Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
      'guest_count': guestCount, 
    };

    await docRef.set(bookingData);
    debugPrint('Booking successfully recorded in Firestore with ID: ${docRef.id} for hotel ID: $hotelId');
  }
}
