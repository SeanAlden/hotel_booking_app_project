import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  String id;
  String name;
  String locationId;
  double rating;
  String description;
  List<String> amenities;

  Hotel({
    required this.id,
    required this.name,
    required this.locationId,
    required this.rating,
    required this.description,
    required this.amenities,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locationId': locationId,
      'rating': rating,
      'description': description,
      'amenities': amenities,
      'hotelId': id,
    };
  }

  static Future<Hotel?> fetchHotelDetails(String hotelId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('hotels')
        .doc(hotelId)
        .get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      return Hotel(
        id: snapshot.id,
        name: data['name'] ?? 'Unknown Hotel',
        locationId: data['locationId'] ?? 'Unknown Location',
        rating: data['rating'] ?? 0.0,
        description: data['description'] ?? 'No description available',
        amenities: List<String>.from(data['amenities'] ?? []),
      );
    }
    return null;
  }
}


