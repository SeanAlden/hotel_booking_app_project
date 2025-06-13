// class Location {
//   String id;
//   String name;

//   Location({required this.id, required this.name});

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//     };
//   }
// }

// class Hotel {
//   String id;
//   String name;
//   String locationId;
//   double rating;
//   String description;

//   Hotel({
//     required this.id,
//     required this.name,
//     required this.locationId,
//     required this.rating,
//     required this.description,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'locationId': locationId,
//       'rating': rating,
//       'description': description,
//     };
//   }
// }

// class Room {
//   String id;
//   String hotelId;
//   String type;
//   double price;

//   Room({
//     required this.id,
//     required this.hotelId,
//     required this.type,
//     required this.price,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'hotelId': hotelId,
//       'type': type,
//       'price': price,
//     };
//   }
// }

// // MODELS
// class Location {
//   String id;
//   String name;

//   Location({required this.id, required this.name});

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//     };
//   }
// }

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
//     };
//   }
// }

// // class Room {
// //   String id;
// //   String hotelId;
// //   String type;
// //   double price;
// //   DateTime? startDate;
// //   DateTime? endDate;
// //   int guestCount;

// //   Room({
// //     required this.id,
// //     required this.hotelId,
// //     required this.type,
// //     required this.price,
// //     this.startDate,
// //     this.endDate,
// //     required this.guestCount,
// //   });

// //   Map<String, dynamic> toMap() {
// //     return {
// //       'hotelId': hotelId,
// //       'type': type,
// //       'price': price,
// //       'startDate': startDate?.toIso8601String(),
// //       'endDate': endDate?.toIso8601String(),
// //       'guestCount': guestCount,
// //     };
// //   }
// // }

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
//     };
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';

// class Location {
//   String id;
//   String name;

//   Location({required this.id, required this.name});

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//     };
//   }

//   // Method to fetch location name from Firestore
//   // static Future<String> fetchLocationName(String locationId) async {
//   //   DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('locations').doc(locationId).get();
//   //   if (snapshot.exists) {
//   //     return snapshot.data()!['name'] as String;
//   //   }
//   //   return 'Unknown Location';
//   // }

//   static Future<String> fetchLocationName(String locationId) async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('locations')
//         .doc(locationId)
//         .get();
//     if (snapshot.exists) {
//       final data = snapshot.data() as Map<String, dynamic>?; // casting ke Map
//       if (data != null && data['name'] is String) {
//         return data['name'] as String;
//       }
//     }
//     return 'Unknown Location';
//   }
// }

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
//     };
//   }

//   // Method to fetch hotel details from Firestore
//   // static Future<Hotel?> fetchHotelDetails(String hotelId) async {
//   //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
//   //       .collection('hotels')
//   //       .doc(hotelId)
//   //       .get();
//   //   if (snapshot.exists) {
//   //     var data = snapshot.data() as Map<String, dynamic>;
//   //     return Hotel(
//   //       id: snapshot.id,
//   //       name: data['name'],
//   //       locationId: data['locationId'],
//   //       rating: data['rating'],
//   //       description: data['description'],
//   //       amenities: List<String>.from(data['amenities']),
//   //     );
//   //   }
//   //   return null;
//   // }

//   static Future<Hotel?> fetchHotelDetails(String hotelId) async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('hotels')
//         .doc(hotelId)
//         .get();
//     if (snapshot.exists) {
//       var data = snapshot.data() as Map<String, dynamic>;
//       print("Fetched hotel data: $data"); // Debug print
//       return Hotel( 
//         id: snapshot.id,
//         name: data['name'] ?? 'Unknown Hotel', // Provide a default value
//         locationId:
//             data['locationId'] ?? 'Unknown Location', // Provide a default value
//         rating: data['rating'] ?? 0.0, // Provide a default value
//         description: data['description'] ??
//             'No description available', // Provide a default value
//         amenities: List<String>.from(
//             data['amenities'] ?? []), // Provide a default value
//       );
//     }
//     return null;
//   }
// }

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
//     };
//   }

//   // Method to fetch hotel details based on hotelId
//   Future<Hotel?> fetchHotel() async {
//     return await Hotel.fetchHotelDetails(hotelId);
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  String id;
  String name;

  Location({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locationId': id, // Tambahkan locationId
    };
  }

  static Future<String> fetchLocationName(String locationId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .doc(locationId)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>?; // casting ke Map
      if (data != null && data['name'] is String) {
        return data['name'] as String;
      }
    }
    return 'Unknown Location';
  }
}

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
      'hotelId': id, // Tambahkan hotelId
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
