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

