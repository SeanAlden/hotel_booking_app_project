// import 'package:cloud_firestore/cloud_firestore.dart';

// class Hotel {
//   String id;
//   String name;
//   String locationId;
//   double rating;
//   String description;
//   List<String> amenities;

//   Hotel({
//     required this.id,
//     required this.name,
//     required this.locationId,
//     required this.rating,
//     required this.description,
//     required this.amenities,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'locationId': locationId,
//       'rating': rating,
//       'description': description,
//       'amenities': amenities,
//       'hotelId': id,
//     };
//   }

//   static Future<Hotel?> fetchHotelDetails(String hotelId) async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('hotels')
//         .doc(hotelId)
//         .get();
//     if (snapshot.exists) {
//       var data = snapshot.data() as Map<String, dynamic>;
//       return Hotel(
//         id: snapshot.id,
//         name: data['name'] ?? 'Unknown Hotel',
//         locationId: data['locationId'] ?? 'Unknown Location',
//         rating: data['rating'] ?? 0.0,
//         description: data['description'] ?? 'No description available',
//         amenities: List<String>.from(data['amenities'] ?? []),
//       );
//     }
//     return null;
//   }
// }

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

  // Factory constructor to create a Hotel object from a Firestore DocumentSnapshot
  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Hotel(
      id: doc.id, // Use doc.id for the hotel's ID
      name: data['name'] ?? 'Unknown Hotel',
      locationId: data['locationId'] ?? 'Unknown Location',
      rating: (data['rating'] is int) ? (data['rating'] as int).toDouble() : data['rating'] ?? 0.0,
      description: data['description'] ?? 'No description available',
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locationId': locationId,
      'rating': rating,
      'description': description,
      'amenities': amenities,
      // 'hotelId': id, // You might not need to store the ID within the document if doc.id is used.
                      // But if your existing data uses 'hotelId', keep it for backward compatibility.
                      // For new data, relying on doc.id is more standard.
    };
  }

  static Future<Hotel?> fetchHotelDetails(String hotelId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('hotels')
        .doc(hotelId)
        .get();
    if (snapshot.exists) {
      return Hotel.fromFirestore(snapshot); // Use the factory constructor
    }
    return null;
  }
}
