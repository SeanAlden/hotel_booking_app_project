// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/location.dart';

// class LocationDetailPage extends StatelessWidget {
//   final String locationId;

//   const LocationDetailPage({Key? key, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: FutureBuilder<String>(
//           future: Location.fetchLocationName(locationId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Text(
//                 "Loading...",
//                 style: TextStyle(color: Colors.white),
//               );
//             }

//             if (snapshot.hasError) {
//               return const Text("Error fetching location",
//                   style: TextStyle(color: Colors.white));
//             }

//             return Text(snapshot.data ?? "Unknown Location",
//                 style: TextStyle(color: Colors.white));
//           },
//         ),
//         backgroundColor: Colors.blue,
//         iconTheme: IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('hotels')
//             .where('locationId', isEqualTo: locationId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final hotels = snapshot.data!.docs;

//           if (hotels.isEmpty) {
//             return const Center(
//                 child: Text("No hotels found in this location"));
//           }

//           return GridView.builder(
//             padding: const EdgeInsets.all(10),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 0.55,
//             ),
//             itemCount: hotels.length,
//             itemBuilder: (_, index) {
//               final hotel = hotels[index].data() as Map<String, dynamic>;
//               return _HotelCard(hotel: hotel);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class _HotelCard extends StatelessWidget {
//   final Map<String, dynamic> hotel;

//   const _HotelCard({Key? key, required this.hotel}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: AssetImage("assets/images/hotel.png"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               hotel['name'],
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               hotel['description'],
//               overflow: TextOverflow.ellipsis,
//               maxLines: 3,
//             ),
//             const SizedBox(height: 4),
//             // Row(
//             //   children: [
//             //     const Icon(Icons.star, color: Colors.orange),
//             //     Text("${hotel['rating']} / 5.0"),
//             //     IconButton(
//             //       icon: const Icon(Icons.favorite_border),
//             //       onPressed: () {
//             //         // Handle wishlist toggle
//             //       },
//             //     ),
//             //   ],
//             // ),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.orange),
//                     const SizedBox(
//                         width: 6), // Jarak kecil antara ikon dan teks
//                     Text("${hotel['rating']} / 5.0"),
//                   ],
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.favorite_border),
//                   onPressed: () {
//                     // Handle wishlist toggle
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/location.dart';

// class LocationDetailPage extends StatefulWidget {
//   final String locationId;

//   const LocationDetailPage({Key? key, required this.locationId})
//       : super(key: key);

//   @override
//   State<LocationDetailPage> createState() => _LocationDetailPageState();
// }

// class _LocationDetailPageState extends State<LocationDetailPage> {
//   TextEditingController searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = searchController.text.toLowerCase();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: FutureBuilder<String>(
//           future: Location.fetchLocationName(widget.locationId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Text(
//                 "Loading...",
//                 style: TextStyle(color: Colors.white),
//               );
//             }

//             if (snapshot.hasError) {
//               return const Text("Error fetching location",
//                   style: TextStyle(color: Colors.white));
//             }

//             return Text(snapshot.data ?? "Unknown Location",
//                 style: TextStyle(color: Colors.white));
//           },
//         ),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search hotels by name...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('hotels')
//                   .where('locationId', isEqualTo: widget.locationId)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final allHotels = snapshot.data!.docs;
//                 final filteredHotels = allHotels.where((hotelDoc) {
//                   final hotelData = hotelDoc.data() as Map<String, dynamic>;
//                   final hotelName = hotelData['name']?.toLowerCase() ?? '';
//                   return hotelName.contains(_searchQuery);
//                 }).toList();

//                 if (filteredHotels.isEmpty) {
//                   return Center(
//                     child: Text(_searchQuery.isEmpty
//                         ? "No hotels found in this location"
//                         : "No hotels found matching \"${searchController.text}\""),
//                   );
//                 }

//                 return GridView.builder(
//                   padding: const EdgeInsets.all(10),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.55,
//                   ),
//                   itemCount: filteredHotels.length,
//                   itemBuilder: (_, index) {
//                     final hotel =
//                         filteredHotels[index].data() as Map<String, dynamic>;
//                     return _HotelCard(hotel: hotel);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HotelCard extends StatelessWidget {
//   final Map<String, dynamic> hotel;

//   const _HotelCard({Key? key, required this.hotel}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: AssetImage("assets/images/hotel.png"), // Ensure this path is correct
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               hotel['name'],
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               hotel['description'],
//               overflow: TextOverflow.ellipsis,
//               maxLines: 3,
//             ),
//             const SizedBox(height: 4),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.orange),
//                     const SizedBox(width: 6),
//                     Text("${hotel['rating']} / 5.0"),
//                   ],
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.favorite_border),
//                   onPressed: () {
//                     // Handle wishlist toggle
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
// import 'package:hotel_booking_app/model/hotel.dart'; // Import Hotel model
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart'; // Import for navigation

// class LocationDetailPage extends StatefulWidget {
//   final String locationId;

//   const LocationDetailPage({Key? key, required this.locationId})
//       : super(key: key);

//   @override
//   State<LocationDetailPage> createState() => _LocationDetailPageState();
// }

// class _LocationDetailPageState extends State<LocationDetailPage> {
//   TextEditingController searchController = TextEditingController();
//   String _searchQuery = '';
//   User? _currentUser; // Current logged-in user
//   Set<String> _userWishlistHotelIds = {}; // Set to store favorited hotel IDs

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser; // Get current user
//     searchController.addListener(_onSearchChanged);
//     if (_currentUser != null) {
//       _fetchUserWishlist(); // Fetch user's wishlist if logged in
//     }
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = searchController.text.toLowerCase();
//     });
//   }

//   // --- Wishlist Management Logic ---
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

//     final favoritesCollection =
//         FirebaseFirestore.instance.collection('favorites');
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

//         transaction.set(
//             userFavoritesDocRef,
//             {
//               'hotelIds': currentFavoriteHotelIds,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             },
//             SetOptions(merge: true));
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: FutureBuilder<String>(
//           future: Location.fetchLocationName(widget.locationId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Text(
//                 "Loading...",
//                 style: TextStyle(color: Colors.white),
//               );
//             }

//             if (snapshot.hasError) {
//               return const Text("Error fetching location",
//                   style: TextStyle(color: Colors.white));
//             }

//             return Text(snapshot.data ?? "Unknown Location",
//                 style: const TextStyle(color: Colors.white));
//           },
//         ),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search hotels by name...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('hotels')
//                   .where('locationId', isEqualTo: widget.locationId)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final allHotels = snapshot.data!.docs;
//                 final filteredHotels = allHotels.where((hotelDoc) {
//                   // Use Hotel.fromFirestore to safely access data and ID
//                   final hotel = Hotel.fromFirestore(hotelDoc);
//                   final hotelName = hotel.name.toLowerCase();
//                   return hotelName.contains(_searchQuery);
//                 }).toList();

//                 if (filteredHotels.isEmpty) {
//                   return Center(
//                     child: Text(_searchQuery.isEmpty
//                         ? "No hotels found in this location"
//                         : "No hotels found matching \"${searchController.text}\""),
//                   );
//                 }

//                 return GridView.builder(
//                   padding: const EdgeInsets.all(10),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.55,
//                   ),
//                   itemCount: filteredHotels.length,
//                   itemBuilder: (_, index) {
//                     final hotelDoc = filteredHotels[index];
//                     final hotel = Hotel.fromFirestore(
//                         hotelDoc); // Convert DocumentSnapshot to Hotel object
//                     final isWishlisted =
//                         _userWishlistHotelIds.contains(hotel.id);

//                     return _HotelCard(
//                       hotel: hotel, // Pass the Hotel object directly
//                       isWishlisted: isWishlisted,
//                       onToggleWishlist: _toggleWishlist,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HotelCard extends StatelessWidget {
//   final Hotel hotel; // Changed type from Map<String, dynamic> to Hotel
//   final bool isWishlisted;
//   final Function(String) onToggleWishlist;

//   const _HotelCard({
//     Key? key,
//     required this.hotel,
//     required this.isWishlisted,
//     required this.onToggleWishlist,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       // Added GestureDetector for navigation
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HotelDetailPage(
//               hotelId: hotel.id,
//               rooms: const [], // You might need to fetch rooms separately
//             ),
//           ),
//         );
//       },
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: const DecorationImage(
//                     image: AssetImage(
//                         "assets/images/hotel.png"), // Ensure this path is correct
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 hotel.name, // Access directly from Hotel object
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//               Expanded(
//                 // Use Expanded for description to avoid overflow in GridView
//                 child: Text(
//                   hotel.description, // Access directly from Hotel object
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 3,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.star, color: Colors.orange),
//                       const SizedBox(width: 6),
//                       Text(
//                           "${hotel.rating.toStringAsFixed(1)} / 5.0"), // Access directly and format
//                     ],
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isWishlisted ? Icons.favorite : Icons.favorite_border,
//                       color: isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: () {
//                       onToggleWishlist(
//                           hotel.id); // Call the passed callback with hotel ID
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import 'package:hotel_booking_app/model/hotel.dart'; // Import Hotel model
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/hotel_detail_page.dart'; // Import for navigation
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

class LocationDetailPage extends StatefulWidget {
  final String locationId;

  const LocationDetailPage({Key? key, required this.locationId})
      : super(key: key);

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  User? _currentUser; // Current logged-in user
  Set<String> _userWishlistHotelIds = {}; // Set to store favorited hotel IDs

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get current user
    searchController.addListener(_onSearchChanged);
    if (_currentUser != null) {
      _fetchUserWishlist(); // Fetch user's wishlist if logged in
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
      debugPrint('Search query changed to: $_searchQuery');
    });
  }

  // --- Wishlist Management Logic ---
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
        debugPrint(
            'Fetched wishlist for user: ${_currentUser!.uid}. Hotels: $_userWishlistHotelIds');
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

    final favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');
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

        transaction.set(
            userFavoritesDocRef,
            {
              'hotelIds': currentFavoriteHotelIds,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        debugPrint(
            'Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: Location.fetchLocationName(widget.locationId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                "Loading...",
                style: TextStyle(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return const Text("Error fetching location",
                  style: TextStyle(color: Colors.white));
            }

            return Text(snapshot.data ?? "Unknown Location",
                style: const TextStyle(color: Colors.white));
          },
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search hotels by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hotels')
                  .where('locationId', isEqualTo: widget.locationId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allHotels = snapshot.data!.docs;
                final filteredHotels = allHotels.where((hotelDoc) {
                  // Use Hotel.fromFirestore to safely access data and ID
                  final hotel = Hotel.fromFirestore(hotelDoc);
                  final hotelName = hotel.name.toLowerCase();
                  return hotelName.contains(_searchQuery);
                }).toList();

                if (filteredHotels.isEmpty) {
                  return Center(
                    child: Text(_searchQuery.isEmpty
                        ? "No hotels found in this location"
                        : "No hotels found matching \"${searchController.text}\""),
                  );
                }
                debugPrint(
                    'Fetched ${filteredHotels.length} filtered hotels for location detail page.');

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.48, // Adjusted for image and text
                  ),
                  itemCount: filteredHotels.length,
                  itemBuilder: (_, index) {
                    final hotelDoc = filteredHotels[index];
                    final hotel = Hotel.fromFirestore(
                        hotelDoc); // Convert DocumentSnapshot to Hotel object
                    final isWishlisted =
                        _userWishlistHotelIds.contains(hotel.id);

                    return _LocationHotelCard(
                      // Use the new card widget
                      hotel: hotel,
                      isWishlisted: isWishlisted,
                      onToggleWishlist: _toggleWishlist,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// New StatefulWidget for individual hotel cards in LocationDetailPage's GridView
class _LocationHotelCard extends StatefulWidget {
  final Hotel hotel;
  final bool isWishlisted;
  final Function(String) onToggleWishlist;

  const _LocationHotelCard({
    Key? key,
    required this.hotel,
    required this.isWishlisted,
    required this.onToggleWishlist,
  }) : super(key: key);

  @override
  State<_LocationHotelCard> createState() => _LocationHotelCardState();
}

class _LocationHotelCardState extends State<_LocationHotelCard> {
  Uint8List? _hotelImageBytes;

  @override
  void initState() {
    super.initState();
    _loadHotelImage();
  }

  @override
  void didUpdateWidget(covariant _LocationHotelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hotel.id != oldWidget.hotel.id) {
      _loadHotelImage();
    }
  }

  Future<void> _loadHotelImage() async {
    final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
    final Uint8List? imageBytes = hotelImagesBox.get(widget.hotel.id);

    debugPrint(
        'Attempting to load location detail hotel image bytes for ID: ${widget.hotel.id} from Hive.');

    if (imageBytes != null) {
      setState(() {
        _hotelImageBytes = imageBytes;
      });
      debugPrint(
          'Location detail hotel image bytes found and loaded for ID: ${widget.hotel.id}.');
    } else {
      setState(() {
        _hotelImageBytes = null; // No image bytes found in Hive
      });
      debugPrint(
          'Location detail hotel image bytes not found for ID: ${widget.hotel.id} in Hive. Showing default.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child:
            // Card(
            //   elevation: 4,
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //   child: Padding(
            //     padding: const EdgeInsets.all(10),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Container(
            //           height: 100, // Fixed height for image in grid view
            //           decoration: BoxDecoration(
            //             color: Colors.grey[200],
            //             borderRadius: BorderRadius.circular(8),
            //             image: DecorationImage(
            //               image: _hotelImageBytes != null
            //                   ? MemoryImage(_hotelImageBytes!) as ImageProvider
            //                   : const AssetImage("assets/images/hotel.png"), // Default image
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //         ),
            //         const SizedBox(height: 8),
            //         Text(
            //           widget.hotel.name, // Access directly from Hotel object
            //           style: const TextStyle(fontWeight: FontWeight.bold),
            //           maxLines: 2,
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //         const SizedBox(height: 4),
            //         Expanded(
            //           // Use Expanded for description to avoid overflow in GridView
            //           child: Text(
            //             widget.hotel.description, // Access directly from Hotel object
            //             overflow: TextOverflow.ellipsis,
            //             maxLines: 3,
            //             style: const TextStyle(color: Colors.black54),
            //           ),
            //         ),
            //         const SizedBox(height: 4),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Row(
            //               children: [
            //                 const Icon(Icons.star, color: Colors.orange),
            //                 const SizedBox(width: 6),
            //                 Text(
            //                     "${widget.hotel.rating.toStringAsFixed(1)} / 5.0"), // Access directly and format
            //               ],
            //             ),
            //             IconButton(
            //               icon: Icon(
            //                 widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
            //                 color: widget.isWishlisted ? Colors.red : Colors.grey,
            //               ),
            //               onPressed: () {
            //                 widget.onToggleWishlist(
            //                     widget.hotel.id); // Call the passed callback with hotel ID
            //               },
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Penting agar Column tidak memaksa penuh
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: _hotelImageBytes != null
                          ? MemoryImage(_hotelImageBytes!) as ImageProvider
                          : const AssetImage("assets/images/hotel.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.hotel.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                /// Batasi tinggi teks deskripsi menggunakan SizedBox
                SizedBox(
                  height: 48, // Sesuaikan sesuai jumlah baris yang diinginkan
                  child: Text(
                    widget.hotel.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 18),
                          const SizedBox(width: 6),
                          Flexible(child: Text("${widget.hotel.rating.toStringAsFixed(1)} / 5.0", overflow: TextOverflow.ellipsis, maxLines: 2,)),
                        ],
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        widget.isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.isWishlisted ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        widget.onToggleWishlist(widget.hotel.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
