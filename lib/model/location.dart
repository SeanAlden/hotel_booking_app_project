import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  String id;
  String name;

  Location({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locationId': id, 
    };
  }

  static Future<String> fetchLocationName(String locationId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .doc(locationId)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data['name'] is String) {
        return data['name'] as String;
      }
    }
    return 'Unknown Location';
  }
}