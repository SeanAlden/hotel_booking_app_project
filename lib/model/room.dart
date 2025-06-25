import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';

class Room {
  String id;
  String hotelId;
  String type;
  double price;
  int? guestCount; 
  
  DateTime? startDate; 
  DateTime? endDate; 
  double? totalPrice; 

  List<Booking> bookings = [];

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    this.guestCount, 
    this.startDate,
    this.endDate,
    this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'type': type,
      'price': price,
      'guestCount': guestCount, 
      'roomId': id, 
    };
  }

  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      hotelId: data['hotelId'] ?? '', 
      type: data['type'] ?? 'Standard', 
      price: (data['price'] as num?)?.toDouble() ?? 0.0, 
      guestCount: (data['guestCount'] as num?)?.toInt(), 
    );
  }

  Future<Hotel?> fetchHotel() async {
    return await Hotel.fetchHotelDetails(hotelId);
  }

  Future<void> fetchBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('book_history')
          .where('room_id', isEqualTo: id)
          .get();

      bookings = snapshot.docs.map((doc) {
        return Booking.fromFirestore(doc); 
      }).toList();

      debugPrint('Bookings for room $id: ${bookings.length} found');
    } catch (e) {
      debugPrint('Error fetching bookings for room $id: $e');
    }
  }
}

class Booking {
  String id; 
  String userId;
  String hotelId;
  String hotelName;
  String roomId;
  String roomSummary;
  DateTime startDate;
  DateTime endDate;
  int guestCount; 
  double totalPrice;
  DateTime createdAt;
  String bookingId; 

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomSummary,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.totalPrice,
    required this.createdAt,
    required this.bookingId,
  });

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
      guestCount: (data['guest_count'] as num?)?.toInt() ?? 1,
      totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      bookingId: data['booking_id'] ?? '',
    );
  }
}

extension RoomBooking on Room {
  Future<void> bookRoom(String userId) async {
    final hotel = await fetchHotel();
    if (hotel == null) {
      throw Exception('Hotel not found for ID: $hotelId');
    }
    
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
