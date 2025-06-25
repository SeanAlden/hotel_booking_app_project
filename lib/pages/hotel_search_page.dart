// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart'; // Ganti dengan path yang sesuai

// class HotelSearchPage extends StatefulWidget {
//   const HotelSearchPage({super.key});

//   @override
//   State<HotelSearchPage> createState() => _HotelSearchPageState();
// }

// class _HotelSearchPageState extends State<HotelSearchPage> {
//   List<Hotel> hotels = []; // List untuk menyimpan data hotel

//   @override
//   void initState() {
//     super.initState();
//     _fetchHotels(); // Ambil data hotel saat halaman diinisialisasi
//   }

//   Future<void> _fetchHotels() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('hotels').get();
//     setState(() {
//       hotels = snapshot.docs.map((doc) {
//         return Hotel(
//           id: doc.id,
//           name: doc['name'],
//           locationId: doc['locationId'],
//           rating: (doc['rating'] as num).toDouble(),
//           description: doc['description'],
//           amenities: List<String>.from(doc['amenities'] ?? []),
//         );
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Search Hotel',
//           style: TextStyle(fontSize: 22, color: Colors.white),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.blue,
//       ),
//       body: Column(
//         children: [
//           // Hotel List View
//           Expanded(
//             child: ListView.builder(
//               itemCount: hotels.length,
//               itemBuilder: (context, index) {
//                 final hotel = hotels[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Card(
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         children: [
//                           // Placeholder for hotel image
//                           Expanded(
//                             flex: 2,
//                             child: Container(
//                               height: 80,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(8),
//                                 image: DecorationImage(
//                                   image:
//                                       // AssetImage(hotel.amenities.isNotEmpty ? hotel.amenities[0] : "assets/images/hotel.png"),
//                                       AssetImage("assets/images/hotel.png"),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           // Hotel details
//                           Expanded(
//                             flex: 5,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   hotel.name,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 // Hotel description
//                                 Text(
//                                   hotel.description,
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(color: Colors.black54),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.location_pin,
//                                         color: Colors.red, size: 16),
//                                     const SizedBox(width: 4),
//                                     FutureBuilder<String>(
//                                       future: Location.fetchLocationName(hotel
//                                           .locationId), // Ambil nama lokasi
//                                       builder: (context, snapshot) {
//                                         if (snapshot.connectionState ==
//                                             ConnectionState.waiting) {
//                                           return const CircularProgressIndicator(); // Tampilkan loading saat menunggu
//                                         } else if (snapshot.hasError) {
//                                           return const Text(
//                                               'Error fetching location'); // Tampilkan error jika ada
//                                         } else {
//                                           return Expanded(
//                                             child: Text(
//                                               snapshot.data ??
//                                                   'Unknown Location', // Tampilkan nama lokasi
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           );
//                                         }
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.star,
//                                         color: Colors.orange, size: 20),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       hotel.rating.toString(),
//                                       style:
//                                           const TextStyle(color: Colors.black),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                           // Wishlist button (Heart icon)
//                           IconButton(
//                             icon: const Icon(Icons.favorite_border),
//                             onPressed: () {
//                               // Handle wishlist toggle
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart'; // Ganti dengan path yang sesuai

// class HotelSearchPage extends StatefulWidget {
//   const HotelSearchPage({super.key});

//   @override
//   State<HotelSearchPage> createState() => _HotelSearchPageState();
// }

// class _HotelSearchPageState extends State<HotelSearchPage> {
//   List<Hotel> hotels = []; // List untuk menyimpan data hotel
//   String searchQuery = ""; // Untuk menyimpan query pencarian

//   @override
//   void initState() {
//     super.initState();
//     _fetchHotels(); // Ambil data hotel saat halaman diinisialisasi
//   }

//   Future<void> _fetchHotels() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('hotels').get();
//     setState(() {
//       hotels = snapshot.docs.map((doc) {
//         return Hotel(
//           id: doc.id,
//           name: doc['name'],
//           locationId: doc['locationId'],
//           rating: (doc['rating'] as num).toDouble(),
//           description: doc['description'],
//           amenities: List<String>.from(doc['amenities'] ?? []),
//         );
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Filter hotels based on search query
//     final filteredHotels = hotels.where((hotel) {
//       return hotel.name.toLowerCase().contains(searchQuery.toLowerCase());
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Search Hotel',
//           style: TextStyle(fontSize: 22, color: Colors.white),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.blue,
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value; // Update search query
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search by product name...',
//                 border: OutlineInputBorder(),
//                 prefixIcon: const Icon(Icons.search),
//               ),
//             ),
//           ),
//           // Hotel List View
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredHotels.length,
//               itemBuilder: (context, index) {
//                 final hotel = filteredHotels[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Card(
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         children: [
//                           // Placeholder for hotel image
//                           Expanded(
//                             flex: 2,
//                             child: Container(
//                               height: 80,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(8),
//                                 image: DecorationImage(
//                                   image:
//                                       // AssetImage(hotel.amenities.isNotEmpty ? hotel.amenities[0] : "assets/images/hotel.png"),
//                                       AssetImage("assets/images/hotel.png"),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           // Hotel details
//                           Expanded(
//                             flex: 5,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   hotel.name,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 // Hotel description
//                                 Text(
//                                   hotel.description,
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(color: Colors.black54),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.location_pin,
//                                         color: Colors.red, size: 16),
//                                     const SizedBox(width: 4),
//                                     FutureBuilder<String>(
//                                       future: Location.fetchLocationName(hotel
//                                           .locationId), // Ambil nama lokasi
//                                       builder: (context, snapshot) {
//                                         if (snapshot.connectionState ==
//                                             ConnectionState.waiting) {
//                                           return const CircularProgressIndicator(); // Tampilkan loading saat menunggu
//                                         } else if (snapshot.hasError) {
//                                           return const Text(
//                                               'Error fetching location'); // Tampilkan error jika ada
//                                         } else {
//                                           return Expanded(
//                                             child: Text(
//                                               snapshot.data ??
//                                                   'Unknown Location', // Tampilkan nama lokasi
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           );
//                                         }
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.star,
//                                         color: Colors.orange, size: 20),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       hotel.rating.toString(),
//                                       style:
//                                           const TextStyle(color: Colors.black),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                           // Wishlist button (Heart icon)
//                           IconButton(
//                             icon: const Icon(Icons.favorite_border),
//                             onPressed: () {
//                               // Handle wishlist toggle
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart'; // Import for navigation

// class HotelSearchPage extends StatefulWidget {
//   const HotelSearchPage({super.key});

//   @override
//   State<HotelSearchPage> createState() => _HotelSearchPageState();
// }

// class _HotelSearchPageState extends State<HotelSearchPage> {
//   List<Hotel> hotels = []; // List untuk menyimpan data hotel
//   String searchQuery = ""; // Untuk menyimpan query pencarian
//   User? _currentUser; // Current logged-in user
//   Set<String> _userWishlistHotelIds = {}; // Set to store favorited hotel IDs

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser; // Get current user
//     _fetchHotels(); // Ambil data hotel saat halaman diinisialisasi
//     if (_currentUser != null) {
//       _fetchUserWishlist(); // Fetch user's wishlist if logged in
//     }
//   }

//   // --- Wishlist Management Logic (Similar to HomePage) ---
//   Future<void> _fetchUserWishlist() async {
//     if (_currentUser == null) return;

//     try {
//       DocumentSnapshot favDoc = await FirebaseFirestore.instance
//           .collection('favorites')
//           .doc(_currentUser!.uid)
//           .get();

//       if (favDoc.exists) {
//         final data = favDoc.data() as Map<String, dynamic>;
//         List<dynamic> favoritedIds = data['hotelIds'] ?? [];
//         setState(() {
//           _userWishlistHotelIds.clear();
//           for (var id in favoritedIds) {
//             _userWishlistHotelIds.add(id.toString());
//           }
//         });
//       }
//     } catch (e) {
//       print('Error fetching user wishlist: $e');
//     }
//   }

//   Future<void> _toggleWishlist(String hotelId) async {
//     if (_currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to manage favorites.')),
//       );
//       return;
//     }

//     final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
//     final userFavoritesDocRef = favoritesCollection.doc(_currentUser!.uid);

//     // Optimistically update local state for immediate UI feedback
//     setState(() {
//       if (_userWishlistHotelIds.contains(hotelId)) {
//         _userWishlistHotelIds.remove(hotelId);
//       } else {
//         _userWishlistHotelIds.add(hotelId);
//       }
//     });

//     try {
//       await FirebaseFirestore.instance.runTransaction((transaction) async {
//         DocumentSnapshot snapshot = await transaction.get(userFavoritesDocRef);

//         List<String> currentFavoriteHotelIds = [];
//         if (snapshot.exists) {
//           final data = snapshot.data() as Map<String, dynamic>;
//           currentFavoriteHotelIds = List<String>.from(data['hotelIds'] ?? []);
//         }

//         if (_userWishlistHotelIds.contains(hotelId)) {
//           // Add to Firestore if it's in our local wishlist
//           if (!currentFavoriteHotelIds.contains(hotelId)) {
//             currentFavoriteHotelIds.add(hotelId);
//           }
//         } else {
//           // Remove from Firestore if it's not in our local wishlist
//           currentFavoriteHotelIds.remove(hotelId);
//         }

//         transaction.set(userFavoritesDocRef, {
//           'hotelIds': currentFavoriteHotelIds,
//           'lastUpdated': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       });
//     } catch (e) {
//       print('Error updating wishlist in Firestore: $e');
//       // If transaction fails, revert local state
//       setState(() {
//         if (_userWishlistHotelIds.contains(hotelId)) {
//           _userWishlistHotelIds.remove(hotelId);
//         } else {
//           _userWishlistHotelIds.add(hotelId);
//         }
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update favorites: $e')),
//       );
//     }
//   }
//   // --- End Wishlist Management Logic ---

//   Future<void> _fetchHotels() async {
//     // Use Hotel.fromFirestore to map docs directly
//     final snapshot = await FirebaseFirestore.instance.collection('hotels').get();
//     setState(() {
//       hotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Filter hotels based on search query
//     final filteredHotels = hotels.where((hotel) {
//       return hotel.name.toLowerCase().contains(searchQuery.toLowerCase());
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Search Hotel',
//           style: TextStyle(fontSize: 22, color: Colors.white),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.blue,
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value; // Update search query
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search by hotel name...', // Changed hint text
//                 border: const OutlineInputBorder(),
//                 prefixIcon: const Icon(Icons.search),
//               ),
//             ),
//           ),
//           // Hotel List View
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredHotels.length,
//               itemBuilder: (context, index) {
//                 final hotel = filteredHotels[index];
//                 // Determine if the current hotel is wishlisted
//                 final isWishlisted = _userWishlistHotelIds.contains(hotel.id);

//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: GestureDetector( // Wrap with GestureDetector to navigate to detail
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => HotelDetailPage(
//                             hotelId: hotel.id,
//                             rooms: const [], // You might need to fetch rooms separately
//                           ),
//                         ),
//                       );
//                     },
//                     child: Card(
//                       elevation: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           children: [
//                             // Hotel image
//                             Expanded(
//                               flex: 2,
//                               child: Container(
//                                 height: 80,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(8),
//                                   image: const DecorationImage(
//                                     image: AssetImage("assets/images/hotel.png"), // Placeholder image
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             // Hotel details
//                             Expanded(
//                               flex: 5,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     hotel.name,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   // Hotel description
//                                   Text(
//                                     hotel.description,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.location_pin,
//                                           color: Colors.red, size: 16),
//                                       const SizedBox(width: 4),
//                                       FutureBuilder<String>(
//                                         future: Location.fetchLocationName(
//                                             hotel.locationId), // Ambil nama lokasi
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState ==
//                                               ConnectionState.waiting) {
//                                             return const SizedBox(
//                                                 width: 20,
//                                                 height: 20,
//                                                 child: CircularProgressIndicator(strokeWidth: 2.0)); // Tampilkan loading saat menunggu
//                                           } else if (snapshot.hasError) {
//                                             return const Text(
//                                                 'Error fetching location'); // Tampilkan error jika ada
//                                           } else {
//                                             return Expanded(
//                                               child: Text(
//                                                 snapshot.data ??
//                                                     'Unknown Location', // Tampilkan nama lokasi
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             );
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.star,
//                                           color: Colors.orange, size: 20),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         hotel.rating.toStringAsFixed(1), // Format rating
//                                         style:
//                                             const TextStyle(color: Colors.black),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                             // Wishlist button (Heart icon)
//                             IconButton(
//                               icon: Icon(
//                                 isWishlisted ? Icons.favorite : Icons.favorite_border,
//                                 color: isWishlisted ? Colors.red : Colors.grey,
//                               ),
//                               onPressed: () {
//                                 _toggleWishlist(hotel.id); // Toggle wishlist using hotel ID
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/hotel_detail_page.dart'; // Import for navigation
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  List<Hotel> hotels = []; // List to store hotel data
  String searchQuery = ""; // To store search query
  User? _currentUser; // Current logged-in user
  Set<String> _userWishlistHotelIds = {}; // Set to store favorited hotel IDs

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get current user
    _fetchHotels(); // Fetch hotel data when page initializes
    if (_currentUser != null) {
      _fetchUserWishlist(); // Fetch user's wishlist if logged in
    }
  }

  // --- Wishlist Management Logic (Similar to HomePage) ---
  Future<void> _fetchUserWishlist() async {
    if (_currentUser == null) return;

    try {
      DocumentSnapshot favDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_currentUser!.uid)
          .get();

      if (favDoc.exists) {
        final data = favDoc.data() as Map<String, dynamic>;
        List<dynamic> favoritedIds = data['hotelIds'] ?? [];
        setState(() {
          _userWishlistHotelIds.clear();
          for (var id in favoritedIds) {
            _userWishlistHotelIds.add(id.toString());
          }
        });
        debugPrint('Fetched wishlist for user: ${_currentUser!.uid}. Hotels: $_userWishlistHotelIds');
      } else {
        debugPrint('No wishlist found for user: ${_currentUser!.uid}');
      }
    } catch (e) {
      debugPrint('Error fetching user wishlist: $e');
    }
  }

  Future<void> _toggleWishlist(String hotelId) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to manage favorites.')),
      );
      return;
    }

    final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
    final userFavoritesDocRef = favoritesCollection.doc(_currentUser!.uid);

    // Optimistically update local state for immediate UI feedback
    setState(() {
      if (_userWishlistHotelIds.contains(hotelId)) {
        _userWishlistHotelIds.remove(hotelId);
        debugPrint('Removed $hotelId from local wishlist');
      } else {
        _userWishlistHotelIds.add(hotelId);
        debugPrint('Added $hotelId to local wishlist');
      }
    });

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userFavoritesDocRef);

        List<String> currentFavoriteHotelIds = [];
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          currentFavoriteHotelIds = List<String>.from(data['hotelIds'] ?? []);
        }

        if (_userWishlistHotelIds.contains(hotelId)) {
          // Add to Firestore if it's in our local wishlist
          if (!currentFavoriteHotelIds.contains(hotelId)) {
            currentFavoriteHotelIds.add(hotelId);
          }
        } else {
          // Remove from Firestore if it's not in our local wishlist
          currentFavoriteHotelIds.remove(hotelId);
        }

        transaction.set(userFavoritesDocRef, {
          'hotelIds': currentFavoriteHotelIds,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds');
      });
    } catch (e) {
      debugPrint('Error updating wishlist in Firestore: $e');
      // If transaction fails, revert local state
      setState(() {
        if (_userWishlistHotelIds.contains(hotelId)) {
          _userWishlistHotelIds.remove(hotelId);
        } else {
          _userWishlistHotelIds.add(hotelId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorites: $e')),
      );
    }
  }
  // --- End Wishlist Management Logic ---

  Future<void> _fetchHotels() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('hotels').get();
      setState(() {
        hotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      });
      debugPrint('Fetched ${hotels.length} hotels for search page.');
    } catch (e) {
      debugPrint('Error fetching hotels for search page: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading hotels: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter hotels based on search query
    final filteredHotels = hotels.where((hotel) {
      return hotel.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Hotel',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update search query
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by hotel name...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Hotel List View
          Expanded(
            child: ListView.builder(
              itemCount: filteredHotels.length,
              itemBuilder: (context, index) {
                final hotel = filteredHotels[index];
                final isWishlisted = _userWishlistHotelIds.contains(hotel.id);

                return _HotelSearchCard(
                  hotel: hotel,
                  isWishlisted: isWishlisted,
                  onToggleWishlist: _toggleWishlist,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// New StatefulWidget for individual hotel cards in search results
class _HotelSearchCard extends StatefulWidget {
  final Hotel hotel;
  final bool isWishlisted;
  final Function(String) onToggleWishlist;

  const _HotelSearchCard({
    Key? key,
    required this.hotel,
    required this.isWishlisted,
    required this.onToggleWishlist,
  }) : super(key: key);

  @override
  State<_HotelSearchCard> createState() => _HotelSearchCardState();
}

class _HotelSearchCardState extends State<_HotelSearchCard> {
  Uint8List? _hotelImageBytes;

  @override
  void initState() {
    super.initState();
    _loadHotelImage();
  }

  @override
  void didUpdateWidget(covariant _HotelSearchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hotel.id != oldWidget.hotel.id) {
      _loadHotelImage();
    }
  }

  Future<void> _loadHotelImage() async {
    final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
    final Uint8List? imageBytes = hotelImagesBox.get(widget.hotel.id);

    debugPrint('Attempting to load search hotel image bytes for ID: ${widget.hotel.id} from Hive.');

    if (imageBytes != null) {
      setState(() {
        _hotelImageBytes = imageBytes;
      });
      debugPrint('Search hotel image bytes found and loaded for ID: ${widget.hotel.id}.');
    } else {
      setState(() {
        _hotelImageBytes = null; // No image bytes found in Hive
      });
      debugPrint('Search hotel image bytes not found for ID: ${widget.hotel.id} in Hive. Showing default.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailPage(
                hotelId: widget.hotel.id,
                rooms: const [], // You might need to fetch rooms separately
              ),
            ),
          );
        },
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Hotel image
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: _hotelImageBytes != null
                            ? MemoryImage(_hotelImageBytes!) as ImageProvider
                            : const AssetImage("assets/images/hotel.png"), // Placeholder image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Hotel details
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotel.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Hotel description
                      Text(
                        widget.hotel.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_pin,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          FutureBuilder<String>(
                            future: Location.fetchLocationName(
                                widget.hotel.locationId), // Fetch location name
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2.0)); // Show loading
                              } else if (snapshot.hasError) {
                                return const Text(
                                    'Error fetching location'); // Show error
                              } else {
                                return Expanded(
                                  child: Text(
                                    snapshot.data ??
                                        'Unknown Location', // Display location name
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.hotel.rating.toStringAsFixed(1), // Format rating
                            style:
                                const TextStyle(color: Colors.black),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // Wishlist button (Heart icon)
                IconButton(
                  icon: Icon(
                    widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: widget.isWishlisted ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    widget.onToggleWishlist(widget.hotel.id); // Toggle wishlist using hotel ID
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
