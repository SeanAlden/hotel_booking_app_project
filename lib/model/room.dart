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
      'roomId': id, // Tambahkan roomId
    };
  }

  Future<Hotel?> fetchHotel() async {
    return await Hotel.fetchHotelDetails(hotelId);
  }
}

extension RoomBooking on Room {
  Future<void> bookRoom() async {
    // 1. Ambil detail hotel
    final hotel = await fetchHotel();
    if (hotel == null) {
      throw Exception('Hotel not found');
    }

    // 2. Persiapkan data untuk disimpan
    final docRef = FirebaseFirestore.instance
        .collection('book_history')
        .doc(); // auto-generate ID
    final bookingData = {
      'booking_id': docRef.id,
      'created_at': FieldValue.serverTimestamp(),
      'hotel_name': hotel.name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'total_price': totalPrice,
      'room_summary': type,
    };

    // 3. Simpan ke Firestore
    await docRef.set(bookingData);
  }
}
