// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
// import 'package:hotel_booking_app/pages/hotel_search_page.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart';
// import 'package:hotel_booking_app/pages/location_search_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final Set<String> _wishlist = {};

//   void _toggleWishlist(String hotelName) {
//     setState(() {
//       if (_wishlist.contains(hotelName)) {
//         _wishlist.remove(hotelName);
//       } else {
//         _wishlist.add(hotelName);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Home",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const GreetingHeader(),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Hotels",
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => HotelSearchPage()),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _HotelListView(
//             wishlist: _wishlist,
//             onToggleWishlist: _toggleWishlist,
//           ),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Location",
//             onTap: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => LocationSearchPage())),
//           ),
//           const SizedBox(height: 10),
//           const _LocationListView(),
//         ],
//       ),
//     );
//   }
// }

// // ----------------------------- COMPONENTS -----------------------------

// class GreetingHeader extends StatefulWidget {
//   const GreetingHeader({super.key});

//   @override
//   State<GreetingHeader> createState() => _GreetingHeaderState();
// }

// class _GreetingHeaderState extends State<GreetingHeader> {
//   File? _localImage;

//   @override
//   void initState() {
//     super.initState();
//     _loadLocalProfileImage();
//   }

//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: Colors.grey,
//           backgroundImage: _localImage != null
//               ? FileImage(_localImage!) as ImageProvider
//               : const AssetImage('assets/images/profile.png'),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Hi, ${user?.displayName ?? 'User '}',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//         IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {

//             }),
//         IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;

//   const _SectionHeader({required this.title, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         GestureDetector(
//           onTap: onTap,
//           child: const Text("See All", style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }
// }

// class _HotelListView extends StatelessWidget {
//   const _HotelListView({
//     required this.wishlist,
//     required this.onToggleWishlist,
//   });

//   final Set<String> wishlist;
//   final Function(String) onToggleWishlist;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final hotels = snapshot.data!.docs;

//         return SizedBox(
//           height: 360,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: hotels.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final hotel = hotels[index].data() as Map<String, dynamic>;
//               final isWishlisted = wishlist.contains(hotel["name"]);

//               return _HotelCard(
//                 hotel: hotel,
//                 isWishlisted: isWishlisted,
//                 onWishlistToggle: () =>
//                     onToggleWishlist(hotel["name"] as String),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _HotelCard extends StatelessWidget {
//   final Map<String, dynamic> hotel;
//   final bool isWishlisted;
//   final VoidCallback onWishlistToggle;

//   const _HotelCard({
//     required this.hotel,
//     required this.isWishlisted,
//     required this.onWishlistToggle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         try {
//           Hotel? fetchedHotel = await Hotel.fetchHotelDetails(hotel['hotelId']);
//           if (fetchedHotel != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HotelDetailPage(
//                   hotelId: fetchedHotel.id,
//                   rooms: [],
//                 ),
//               ),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching hotel details: $e')),
//           );
//           print("Error fetching hotel details: $e");
//         }
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 220,
//           height: 320,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     image: AssetImage(
//                         "assets/images/hotel.png"), // Assuming image URL is stored in Firestore
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           hotel['name'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         FutureBuilder<String>(
//                           future:
//                               Location.fetchLocationName(hotel['locationId']),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Text('Loading...');
//                             } else if (snapshot.hasError) {
//                               return const Text('Error fetching location');
//                             } else {
//                               return Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       color: Colors.red, size: 16),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       snapshot.data ??
//                                           'Unknown City', // Handle null case
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isWishlisted ? Icons.favorite : Icons.favorite_border,
//                       color: isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: onWishlistToggle,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 hotel['description'],
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.orange, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     "${hotel['rating'].toString()} / 5.0",
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LocationListView extends StatelessWidget {
//   const _LocationListView();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('locations').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final locations = snapshot.data!.docs;

//         return SizedBox(
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: locations.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final location = locations[index].data() as Map<String, dynamic>;
//               return _LocationCard(
//                   name: location['name'], locationId: location['locationId']);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _LocationCard extends StatelessWidget {
//   final String name;
//   final String locationId; // New property for locationId

//   const _LocationCard({Key? key, required this.name, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LocationDetailPage(locationId: locationId),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 120,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_pin, color: Colors.red, size: 30),
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
// import 'package:hotel_booking_app/pages/hotel_search_page.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart';
// import 'package:hotel_booking_app/pages/location_search_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Use a Set to store hotel IDs that are favorited by the current user
//   final Set<String> _userWishlistHotelIds = {};
//   User? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     if (_currentUser != null) {
//       _fetchUserWishlist();
//     }
//   }

//   Future<void> _fetchUserWishlist() async {
//     if (_currentUser == null) return;

//     try {
//       // Get the favorite document for the current user
//       DocumentSnapshot favDoc = await FirebaseFirestore.instance
//           .collection('favorites')
//           .doc(_currentUser!.uid)
//           .get();

//       if (favDoc.exists) {
//         final data = favDoc.data() as Map<String, dynamic>;
//         // Assuming 'hotelIds' is a List<String> in your Firestore document
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

//   // Function to toggle a hotel in/out of favorites
//   Future<void> _toggleWishlist(String hotelId) async {
//     if (_currentUser == null) {
//       // Handle case where user is not logged in (e.g., show login prompt)
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to manage favorites.')),
//       );
//       return;
//     }

//     final favoritesCollection =
//         FirebaseFirestore.instance.collection('favorites');
//     final userFavoritesDocRef = favoritesCollection.doc(_currentUser!.uid);

//     // Update locally first for immediate UI feedback
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

//         // Set the updated list back to Firestore
//         transaction.set(
//             userFavoritesDocRef,
//             {
//               'hotelIds': currentFavoriteHotelIds,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             },
//             SetOptions(
//                 merge:
//                     true)); // Use merge to avoid overwriting other fields if any
//       });
//     } catch (e) {
//       print('Error updating wishlist in Firestore: $e');
//       // If transaction fails, revert local state
//       setState(() {
//         if (_userWishlistHotelIds.contains(hotelId)) {
//           _userWishlistHotelIds
//               .remove(hotelId); // Assuming it was added, remove it back
//         } else {
//           _userWishlistHotelIds
//               .add(hotelId); // Assuming it was removed, add it back
//         }
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update favorites: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Home",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const GreetingHeader(),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Hotels",
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => HotelSearchPage()),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _HotelListView(
//             // Pass the user's specific wishlist IDs
//             wishlistHotelIds: _userWishlistHotelIds,
//             onToggleWishlist: _toggleWishlist,
//           ),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Location",
//             onTap: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => LocationSearchPage())),
//           ),
//           const SizedBox(height: 10),
//           const _LocationListView(),
//         ],
//       ),
//     );
//   }
// }

// // ----------------------------- COMPONENTS -----------------------------

// class GreetingHeader extends StatefulWidget {
//   const GreetingHeader({super.key});

//   @override
//   State<GreetingHeader> createState() => _GreetingHeaderState();
// }

// class _GreetingHeaderState extends State<GreetingHeader> {
//   File? _localImage;
//   User? _currentUser;
//   String _displayName = 'User'; // Default display name

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadLocalProfileImage();
//     _loadUserData(); // Load user display name from Firebase
//   }

//   // Load user data (specifically displayName) from Firebase Auth
//   void _loadUserData() {
//     if (_currentUser != null) {
//       setState(() {
//         _displayName = _currentUser!.displayName ?? 'User';
//       });
//       // You can also fetch from Firestore if displayName is stored there
//       // FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get().then((doc) {
//       //   if (doc.exists && doc.data()!['name'] != null) {
//       //     setState(() {
//       //       _displayName = doc.data()!['name'];
//       //     });
//       //   }
//       // });
//     }
//   }

//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: Colors.grey,
//           backgroundImage: _localImage != null
//               ? FileImage(_localImage!) as ImageProvider
//               : const AssetImage('assets/images/profile.png'),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Hi, $_displayName', // Use the loaded display name
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//         IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // Navigate to HotelSearchPage or a general search page
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => HotelSearchPage()));
//             }),
//         IconButton(
//           icon: const Icon(Icons.notifications), // Change icon for favorites
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;

//   const _SectionHeader({required this.title, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         GestureDetector(
//           onTap: onTap,
//           child: const Text("See All", style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }
// }

// class _HotelListView extends StatelessWidget {
//   // Change name to be more descriptive
//   const _HotelListView({
//     required this.wishlistHotelIds,
//     required this.onToggleWishlist,
//   });

//   final Set<String> wishlistHotelIds; // Now stores IDs
//   final Function(String) onToggleWishlist; // Accepts hotelId

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final hotels = snapshot.data!.docs;

//         return SizedBox(
//           height: 360,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: hotels.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final hotelDoc = hotels[index];
//               final hotel = hotelDoc.data() as Map<String, dynamic>;
//               final hotelId = hotelDoc.id; // Get the Firestore document ID

//               // Check if the current hotel's ID is in the user's wishlist
//               final isWishlisted = wishlistHotelIds.contains(hotelId);

//               return _HotelCard(
//                 hotel: hotel,
//                 hotelId: hotelId, // Pass the hotel ID
//                 isWishlisted: isWishlisted,
//                 onWishlistToggle: () =>
//                     onToggleWishlist(hotelId), // Pass hotelId
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _HotelCard extends StatelessWidget {
//   final Map<String, dynamic> hotel;
//   final String hotelId; // Add hotelId
//   final bool isWishlisted;
//   final VoidCallback onWishlistToggle;

//   const _HotelCard({
//     required this.hotel,
//     required this.hotelId, // Required
//     required this.isWishlisted,
//     required this.onWishlistToggle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         try {
//           // Use hotelId directly for fetching details
//           Hotel? fetchedHotel = await Hotel.fetchHotelDetails(hotelId);
//           if (fetchedHotel != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HotelDetailPage(
//                   hotelId: fetchedHotel.id,
//                   rooms: const [], // You might need to fetch rooms separately in HotelDetailPage
//                 ),
//               ),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching hotel details: $e')),
//           );
//           print("Error fetching hotel details: $e");
//         }
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 220,
//           height: 320,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: const DecorationImage(
//                     image: AssetImage(
//                         "assets/images/hotel.png"), // Assuming image URL is stored in Firestore
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           hotel['name'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         FutureBuilder<String>(
//                           future:
//                               Location.fetchLocationName(hotel['locationId']),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Text('Loading...');
//                             } else if (snapshot.hasError) {
//                               return const Text('Error fetching location');
//                             } else {
//                               return Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       color: Colors.red, size: 16),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       snapshot.data ??
//                                           'Unknown City', // Handle null case
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isWishlisted ? Icons.favorite : Icons.favorite_border,
//                       color: isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: onWishlistToggle,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 hotel['description'],
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.orange, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     "${hotel['rating'].toString()} / 5.0",
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LocationListView extends StatelessWidget {
//   const _LocationListView();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('locations').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final locations = snapshot.data!.docs;

//         return SizedBox(
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: locations.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final location = locations[index].data() as Map<String, dynamic>;
//               final locationId = locations[index].id; // Get the ID
//               return _LocationCard(
//                   name: location['name'], locationId: locationId);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _LocationCard extends StatelessWidget {
//   final String name;
//   final String locationId; // New property for locationId

//   const _LocationCard({Key? key, required this.name, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LocationDetailPage(locationId: locationId),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 120,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_pin, color: Colors.red, size: 30),
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
// import 'package:hotel_booking_app/pages/hotel_search_page.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart';
// import 'package:hotel_booking_app/pages/location_search_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Use a Set to store hotel IDs that are favorited by the current user
//   final Set<String> _userWishlistHotelIds = {};
//   User? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     if (_currentUser != null) {
//       _fetchUserWishlist();
//     }
//   }

//   Future<void> _fetchUserWishlist() async {
//     if (_currentUser == null) return;

//     try {
//       // Get the favorite document for the current user
//       DocumentSnapshot favDoc = await FirebaseFirestore.instance
//           .collection('favorites')
//           .doc(_currentUser!.uid)
//           .get();

//       if (favDoc.exists) {
//         final data = favDoc.data() as Map<String, dynamic>;
//         // Assuming 'hotelIds' is a List<String> in your Firestore document
//         List<dynamic> favoritedIds = data['hotelIds'] ?? [];
//         setState(() {
//           _userWishlistHotelIds.clear();
//           for (var id in favoritedIds) {
//             _userWishlistHotelIds.add(id.toString());
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching user wishlist: $e');
//     }
//   }

//   // Function to toggle a hotel in/out of favorites
//   Future<void> _toggleWishlist(String hotelId) async {
//     if (_currentUser == null) {
//       // Handle case where user is not logged in (e.g., show login prompt)
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to manage favorites.')),
//       );
//       return;
//     }

//     final favoritesCollection =
//         FirebaseFirestore.instance.collection('favorites');
//     final userFavoritesDocRef = favoritesCollection.doc(_currentUser!.uid);

//     // Update locally first for immediate UI feedback
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

//         // Set the updated list back to Firestore
//         transaction.set(
//             userFavoritesDocRef,
//             {
//               'hotelIds': currentFavoriteHotelIds,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             },
//             SetOptions(
//                 merge:
//                     true)); // Use merge to avoid overwriting other fields if any
//       });
//     } catch (e) {
//       debugPrint('Error updating wishlist in Firestore: $e');
//       // If transaction fails, revert local state
//       setState(() {
//         if (_userWishlistHotelIds.contains(hotelId)) {
//           _userWishlistHotelIds
//               .remove(hotelId); // Assuming it was added, remove it back
//         } else {
//           _userWishlistHotelIds
//               .add(hotelId); // Assuming it was removed, add it back
//         }
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update favorites: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Home",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const GreetingHeader(),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Hotels",
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const HotelSearchPage()),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _HotelListView(
//             // Pass the user's specific wishlist IDs
//             wishlistHotelIds: _userWishlistHotelIds,
//             onToggleWishlist: _toggleWishlist,
//           ),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Location",
//             onTap: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const LocationSearchPage())),
//           ),
//           const SizedBox(height: 10),
//           const _LocationListView(),
//         ],
//       ),
//     );
//   }
// }

// // ----------------------------- COMPONENTS -----------------------------

// class GreetingHeader extends StatefulWidget {
//   const GreetingHeader({super.key});

//   @override
//   State<GreetingHeader> createState() => _GreetingHeaderState();
// }

// class _GreetingHeaderState extends State<GreetingHeader> {
//   File? _localImage;
//   User? _currentUser;
//   String _displayName = 'User'; // Default display name

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadLocalProfileImage();
//     _loadUserData(); // Load user display name from Firebase
//   }

//   // Load user data (specifically displayName) from Firebase Auth
//   void _loadUserData() {
//     if (_currentUser != null) {
//       setState(() {
//         _displayName = _currentUser!.displayName ?? 'User';
//       });
//     }
//   }

//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: Colors.grey,
//           backgroundImage: _localImage != null
//               ? FileImage(_localImage!) as ImageProvider
//               : const AssetImage('assets/images/profile.png'),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Hi, $_displayName', // Use the loaded display name
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//         IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // Navigate to HotelSearchPage or a general search page
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const HotelSearchPage()));
//             }),
//         IconButton(
//           icon: const Icon(Icons.notifications), // Change icon for favorites
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;

//   const _SectionHeader({required this.title, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         GestureDetector(
//           onTap: onTap,
//           child: const Text("See All", style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }
// }

// class _HotelListView extends StatelessWidget {
//   // Change name to be more descriptive
//   const _HotelListView({
//     required this.wishlistHotelIds,
//     required this.onToggleWishlist,
//   });

//   final Set<String> wishlistHotelIds; // Now stores IDs
//   final Function(String) onToggleWishlist; // Accepts hotelId

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No hotels available.'));
//         }

//         final hotels = snapshot.data!.docs;

//         return SizedBox(
//           height: 360,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: hotels.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final hotelDoc = hotels[index];
//               final hotelData = hotelDoc.data() as Map<String, dynamic>;
//               final hotelId = hotelDoc.id; // Get the Firestore document ID

//               // Check if the current hotel's ID is in the user's wishlist
//               final isWishlisted = wishlistHotelIds.contains(hotelId);

//               return _HotelCard(
//                 hotel: hotelData,
//                 hotelId: hotelId, // Pass the hotel ID
//                 isWishlisted: isWishlisted,
//                 onWishlistToggle: () =>
//                     onToggleWishlist(hotelId), // Pass hotelId
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _HotelCard extends StatefulWidget {
//   final Map<String, dynamic> hotel;
//   final String hotelId; // Add hotelId
//   final bool isWishlisted;
//   final VoidCallback onWishlistToggle;

//   const _HotelCard({
//     required this.hotel,
//     required this.hotelId, // Required
//     required this.isWishlisted,
//     required this.onWishlistToggle,
//     super.key, // Added key
//   });

//   @override
//   State<_HotelCard> createState() => _HotelCardState();
// }

// class _HotelCardState extends State<_HotelCard> {
//   File? _hotelImage;

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _HotelCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Reload image if hotelId changes
//     if (widget.hotelId != oldWidget.hotelId) {
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final imagePath = '${directory.path}/${widget.hotelId}.png';
//     final file = File(imagePath);

//     if (await file.exists()) {
//       setState(() {
//         _hotelImage = file;
//       });
//     } else {
//       setState(() {
//         _hotelImage = null; // No local image found
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         try {
//           // Use hotelId directly for fetching details
//           Hotel? fetchedHotel = await Hotel.fetchHotelDetails(widget.hotelId);
//           if (fetchedHotel != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HotelDetailPage(
//                   hotelId: fetchedHotel.id,
//                   rooms: const [], // You might need to fetch rooms separately in HotelDetailPage
//                 ),
//               ),
//             );
//           } else {
//              ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Hotel details not found.')),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching hotel details: $e')),
//           );
//           debugPrint("Error fetching hotel details: $e");
//         }
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 220,
//           height: 320,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     // Use the local image if available, otherwise fallback to asset
//                     image: _hotelImage != null
//                         ? FileImage(_hotelImage!) as ImageProvider
//                         : const AssetImage("assets/images/hotel.png"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.hotel['name'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         FutureBuilder<String>(
//                           future: Location.fetchLocationName(
//                               widget.hotel['locationId']),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Text('Loading...');
//                             } else if (snapshot.hasError) {
//                               return const Text('Error fetching location');
//                             } else {
//                               return Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       color: Colors.red, size: 16),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       snapshot.data ??
//                                           'Unknown City', // Handle null case
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       widget.isWishlisted
//                           ? Icons.favorite
//                           : Icons.favorite_border,
//                       color: widget.isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: widget.onWishlistToggle,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.hotel['description'],
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.orange, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     "${widget.hotel['rating'].toString()} / 5.0",
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LocationListView extends StatelessWidget {
//   const _LocationListView();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('locations').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No locations available.'));
//         }

//         final locations = snapshot.data!.docs;

//         return SizedBox(
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: locations.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final location = locations[index].data() as Map<String, dynamic>;
//               final locationId = locations[index].id; // Get the ID
//               return _LocationCard(name: location['name'], locationId: locationId);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _LocationCard extends StatelessWidget {
//   final String name;
//   final String locationId; // New property for locationId

//   const _LocationCard({Key? key, required this.name, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LocationDetailPage(locationId: locationId),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 120,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_pin, color: Colors.red, size: 30),
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
// import 'package:hotel_booking_app/pages/hotel_search_page.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart';
// import 'package:hotel_booking_app/pages/location_search_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Use a Set to store hotel IDs that are favorited by the current user
//   final Set<String> _userWishlistHotelIds = {};
//   User? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     if (_currentUser != null) {
//       _fetchUserWishlist();
//     }
//   }

//   Future<void> _fetchUserWishlist() async {
//     if (_currentUser == null) return;

//     try {
//       // Get the favorite document for the current user
//       DocumentSnapshot favDoc = await FirebaseFirestore.instance
//           .collection('favorites')
//           .doc(_currentUser!.uid)
//           .get();

//       if (favDoc.exists) {
//         final data = favDoc.data() as Map<String, dynamic>;
//         // Assuming 'hotelIds' is a List<String> in your Firestore document
//         List<dynamic> favoritedIds = data['hotelIds'] ?? [];
//         setState(() {
//           _userWishlistHotelIds.clear();
//           for (var id in favoritedIds) {
//             _userWishlistHotelIds.add(id.toString());
//           }
//         });
//         debugPrint('Fetched wishlist for user: ${_currentUser!.uid}. Hotels: $_userWishlistHotelIds'); // Debug print
//       } else {
//         debugPrint('No wishlist found for user: ${_currentUser!.uid}'); // Debug print
//       }
//     } catch (e) {
//       debugPrint('Error fetching user wishlist: $e'); // Use debugPrint
//     }
//   }

//   // Function to toggle a hotel in/out of favorites
//   Future<void> _toggleWishlist(String hotelId) async {
//     if (_currentUser == null) {
//       // Handle case where user is not logged in (e.g., show login prompt)
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to manage favorites.')),
//       );
//       return;
//     }

//     final favoritesCollection =
//         FirebaseFirestore.instance.collection('favorites');
//     final userFavoritesDocRef = favoritesCollection.doc(_currentUser!.uid);

//     // Update locally first for immediate UI feedback
//     setState(() {
//       if (_userWishlistHotelIds.contains(hotelId)) {
//         _userWishlistHotelIds.remove(hotelId);
//         debugPrint('Removed $hotelId from local wishlist'); // Debug print
//       } else {
//         _userWishlistHotelIds.add(hotelId);
//         debugPrint('Added $hotelId to local wishlist'); // Debug print
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

//         // Set the updated list back to Firestore
//         transaction.set(
//             userFavoritesDocRef,
//             {
//               'hotelIds': currentFavoriteHotelIds,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             },
//             SetOptions(
//                 merge:
//                     true)); // Use merge to avoid overwriting other fields if any
//         debugPrint('Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds'); // Debug print
//       });
//     } catch (e) {
//       debugPrint('Error updating wishlist in Firestore: $e'); // Use debugPrint
//       // If transaction fails, revert local state
//       setState(() {
//         if (_userWishlistHotelIds.contains(hotelId)) {
//           _userWishlistHotelIds
//               .remove(hotelId); // Assuming it was added, remove it back
//         } else {
//           _userWishlistHotelIds
//               .add(hotelId); // Assuming it was removed, add it back
//         }
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update favorites: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Home",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const GreetingHeader(),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Hotels",
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const HotelSearchPage()),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _HotelListView(
//             // Pass the user's specific wishlist IDs
//             wishlistHotelIds: _userWishlistHotelIds,
//             onToggleWishlist: _toggleWishlist,
//           ),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Location",
//             onTap: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const LocationSearchPage())),
//           ),
//           const SizedBox(height: 10),
//           const _LocationListView(),
//         ],
//       ),
//     );
//   }
// }

// // ----------------------------- COMPONENTS -----------------------------

// class GreetingHeader extends StatefulWidget {
//   const GreetingHeader({super.key});

//   @override
//   State<GreetingHeader> createState() => _GreetingHeaderState();
// }

// class _GreetingHeaderState extends State<GreetingHeader> {
//   File? _localImage;
//   User? _currentUser;
//   String _displayName = 'User'; // Default display name

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadLocalProfileImage();
//     _loadUserData(); // Load user display name from Firebase
//   }

//   // Load user data (specifically displayName) from Firebase Auth
//   void _loadUserData() {
//     if (_currentUser != null) {
//       setState(() {
//         _displayName = _currentUser!.displayName ?? 'User';
//       });
//       debugPrint('Loaded user display name: $_displayName'); // Debug print
//     }
//   }

//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     debugPrint('Attempting to load profile image from: ${file.path}'); // Debug print
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//       debugPrint('Profile image found and loaded.'); // Debug print
//     } else {
//       debugPrint('Profile image not found at: ${file.path}'); // Debug print
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: Colors.grey,
//           backgroundImage: _localImage != null
//               ? FileImage(_localImage!) as ImageProvider
//               : const AssetImage('assets/images/profile.png'),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Hi, $_displayName', // Use the loaded display name
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//         IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // Navigate to HotelSearchPage or a general search page
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const HotelSearchPage()));
//             }),
//         IconButton(
//           icon: const Icon(Icons.notifications), // Change icon for favorites
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;

//   const _SectionHeader({required this.title, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         GestureDetector(
//           onTap: onTap,
//           child: const Text("See All", style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }
// }

// class _HotelListView extends StatelessWidget {
//   const _HotelListView({
//     required this.wishlistHotelIds,
//     required this.onToggleWishlist,
//   });

//   final Set<String> wishlistHotelIds; // Now stores IDs
//   final Function(String) onToggleWishlist; // Accepts hotelId

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('StreamBuilder Error: ${snapshot.error}'); // Debug print
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No hotels available.'));
//         }

//         final hotels = snapshot.data!.docs;
//         debugPrint('Fetched ${hotels.length} hotels from Firestore.'); // Debug print

//         return SizedBox(
//           height: 360,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: hotels.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final hotelDoc = hotels[index];
//               final hotelData = hotelDoc.data() as Map<String, dynamic>;
//               final hotelId = hotelDoc.id; // Get the Firestore document ID
//               debugPrint('Building _HotelCard for hotel ID: $hotelId, Name: ${hotelData['name']}'); // Debug print

//               // Check if the current hotel's ID is in the user's wishlist
//               final isWishlisted = wishlistHotelIds.contains(hotelId);

//               return _HotelCard(
//                 hotel: hotelData,
//                 hotelId: hotelId, // Pass the hotel ID
//                 isWishlisted: isWishlisted,
//                 onWishlistToggle: () =>
//                     onToggleWishlist(hotelId), // Pass hotelId
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _HotelCard extends StatefulWidget {
//   final Map<String, dynamic> hotel;
//   final String hotelId; // Add hotelId
//   final bool isWishlisted;
//   final VoidCallback onWishlistToggle;

//   const _HotelCard({
//     required this.hotel,
//     required this.hotelId, // Required
//     required this.isWishlisted,
//     required this.onWishlistToggle,
//     super.key, // Added key
//   });

//   @override
//   State<_HotelCard> createState() => _HotelCardState();
// }

// class _HotelCardState extends State<_HotelCard> {
//   File? _hotelImage;

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _HotelCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Reload image if hotelId changes
//     if (widget.hotelId != oldWidget.hotelId) {
//       debugPrint('Hotel ID changed, reloading image for ${widget.hotelId}'); // Debug print
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final imagePath = '${directory.path}/${widget.hotelId}.png';
//     final file = File(imagePath);

//     debugPrint('Attempting to load image for hotel ID: ${widget.hotelId} from: $imagePath'); // Debug print

//     if (await file.exists()) {
//       setState(() {
//         _hotelImage = file;
//       });
//       debugPrint('Image found and loaded for hotel ID: ${widget.hotelId}'); // Debug print
//     } else {
//       setState(() {
//         _hotelImage = null; // No local image found
//       });
//       debugPrint('Image not found for hotel ID: ${widget.hotelId} at: $imagePath. Showing default.'); // Debug print
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         try {
//           // Use hotelId directly for fetching details
//           Hotel? fetchedHotel = await Hotel.fetchHotelDetails(widget.hotelId);
//           if (fetchedHotel != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HotelDetailPage(
//                   hotelId: fetchedHotel.id,
//                   rooms: const [], // You might need to fetch rooms separately in HotelDetailPage
//                 ),
//               ),
//             );
//           } else {
//              ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Hotel details not found.')),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching hotel details: $e')),
//           );
//           debugPrint("Error fetching hotel details: $e");
//         }
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 220,
//           height: 320,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     // Use the local image if available, otherwise fallback to asset
//                     image: _hotelImage != null
//                         ? FileImage(_hotelImage!) as ImageProvider
//                         : const AssetImage("assets/images/hotel.png"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.hotel['name'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         FutureBuilder<String>(
//                           future: Location.fetchLocationName(
//                               widget.hotel['locationId']),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Text('Loading...');
//                             } else if (snapshot.hasError) {
//                               return const Text('Error fetching location');
//                             } else {
//                               return Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       color: Colors.red, size: 16),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       snapshot.data ??
//                                           'Unknown City', // Handle null case
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       widget.isWishlisted
//                           ? Icons.favorite
//                           : Icons.favorite_border,
//                       color: widget.isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: widget.onWishlistToggle,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.hotel['description'],
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.orange, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     "${widget.hotel['rating'].toString()} / 5.0",
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LocationListView extends StatelessWidget {
//   const _LocationListView();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('locations').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('Location StreamBuilder Error: ${snapshot.error}'); // Debug print
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No locations available.'));
//         }

//         final locations = snapshot.data!.docs;
//         debugPrint('Fetched ${locations.length} locations from Firestore.'); // Debug print

//         return SizedBox(
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: locations.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final location = locations[index].data() as Map<String, dynamic>;
//               final locationId = locations[index].id; // Get the ID
//               return _LocationCard(name: location['name'], locationId: locationId);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _LocationCard extends StatelessWidget {
//   final String name;
//   final String locationId; // New property for locationId

//   const _LocationCard({Key? key, required this.name, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LocationDetailPage(locationId: locationId),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 120,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_pin, color: Colors.red, size: 30),
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io'; // Still needed for GreetingHeader local image
// import 'dart:typed_data'; // For Uint8List
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
// import 'package:hotel_booking_app/pages/hotel_search_page.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart';
// import 'package:hotel_booking_app/pages/location_search_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart'; // Still needed for GreetingHeader local image
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final Set<String> _userWishlistHotelIds = {};
//   User? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     if (_currentUser != null) {
//       _fetchUserWishlist();
//     }
//   }

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
//         debugPrint('Fetched wishlist for user: ${_currentUser!.uid}. Hotels: $_userWishlistHotelIds');
//       } else {
//         debugPrint('No wishlist found for user: ${_currentUser!.uid}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching user wishlist: $e');
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

//     setState(() {
//       if (_userWishlistHotelIds.contains(hotelId)) {
//         _userWishlistHotelIds.remove(hotelId);
//         debugPrint('Removed $hotelId from local wishlist');
//       } else {
//         _userWishlistHotelIds.add(hotelId);
//         debugPrint('Added $hotelId to local wishlist');
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
//           if (!currentFavoriteHotelIds.contains(hotelId)) {
//             currentFavoriteHotelIds.add(hotelId);
//           }
//         } else {
//           currentFavoriteHotelIds.remove(hotelId);
//         }

//         transaction.set(
//             userFavoritesDocRef,
//             {
//               'hotelIds': currentFavoriteHotelIds,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             },
//             SetOptions(
//                 merge: true));
//         debugPrint('Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds');
//       });
//     } catch (e) {
//       debugPrint('Error updating wishlist in Firestore: $e');
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Home",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const GreetingHeader(),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Hotels",
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const HotelSearchPage()),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _HotelListView(
//             wishlistHotelIds: _userWishlistHotelIds,
//             onToggleWishlist: _toggleWishlist,
//           ),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Location",
//             onTap: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const LocationSearchPage())),
//           ),
//           const SizedBox(height: 10),
//           const _LocationListView(),
//         ],
//       ),
//     );
//   }
// }

// // ----------------------------- COMPONENTS -----------------------------

// class GreetingHeader extends StatefulWidget {
//   const GreetingHeader({super.key});

//   @override
//   State<GreetingHeader> createState() => _GreetingHeaderState();
// }

// class _GreetingHeaderState extends State<GreetingHeader> {
//   File? _localImage; // This still uses File for profile image
//   User? _currentUser;
//   String _displayName = 'User';

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadLocalProfileImage();
//     _loadUserData();
//   }

//   void _loadUserData() {
//     if (_currentUser != null) {
//       setState(() {
//         _displayName = _currentUser!.displayName ?? 'User';
//       });
//       debugPrint('Loaded user display name: $_displayName');
//     }
//   }

//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     debugPrint('Attempting to load profile image from: ${file.path}');
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//       debugPrint('Profile image found and loaded.');
//     } else {
//       debugPrint('Profile image not found at: ${file.path}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: Colors.grey,
//           backgroundImage: _localImage != null
//               ? FileImage(_localImage!) as ImageProvider
//               : const AssetImage('assets/images/profile.png'),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Hi, $_displayName',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//         IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const HotelSearchPage()));
//             }),
//         IconButton(
//           icon: const Icon(Icons.notifications),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;

//   const _SectionHeader({required this.title, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         GestureDetector(
//           onTap: onTap,
//           child: const Text("See All", style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }
// }

// class _HotelListView extends StatelessWidget {
//   const _HotelListView({
//     required this.wishlistHotelIds,
//     required this.onToggleWishlist,
//   });

//   final Set<String> wishlistHotelIds;
//   final Function(String) onToggleWishlist;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('StreamBuilder Error: ${snapshot.error}');
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No hotels available.'));
//         }

//         final hotels = snapshot.data!.docs;
//         debugPrint('Fetched ${hotels.length} hotels from Firestore.');

//         return SizedBox(
//           height: 360,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: hotels.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final hotelDoc = hotels[index];
//               final hotelData = hotelDoc.data() as Map<String, dynamic>;
//               final hotelId = hotelDoc.id;

//               final isWishlisted = wishlistHotelIds.contains(hotelId);

//               return _HotelCard(
//                 hotel: hotelData,
//                 hotelId: hotelId,
//                 isWishlisted: isWishlisted,
//                 onWishlistToggle: () => onToggleWishlist(hotelId),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _HotelCard extends StatefulWidget {
//   final Map<String, dynamic> hotel;
//   final String hotelId;
//   final bool isWishlisted;
//   final VoidCallback onWishlistToggle;

//   const _HotelCard({
//     required this.hotel,
//     required this.hotelId,
//     required this.isWishlisted,
//     required this.onWishlistToggle,
//     super.key,
//   });

//   @override
//   State<_HotelCard> createState() => _HotelCardState();
// }

// class _HotelCardState extends State<_HotelCard> {
//   Uint8List? _hotelImageBytes; // Now stores image as bytes

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _HotelCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.hotelId != oldWidget.hotelId) {
//       debugPrint('Hotel ID changed, reloading image for ${widget.hotelId}');
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//     final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId);

//     debugPrint('Attempting to load image bytes for hotel ID: ${widget.hotelId} from Hive.');

//     if (imageBytes != null) {
//       setState(() {
//         _hotelImageBytes = imageBytes;
//       });
//       debugPrint('Image bytes found and loaded for hotel ID: ${widget.hotelId}');
//     } else {
//       setState(() {
//         _hotelImageBytes = null; // No image bytes found in Hive
//       });
//       debugPrint('Image bytes not found for hotel ID: ${widget.hotelId} in Hive. Showing default.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         try {
//           Hotel? fetchedHotel = await Hotel.fetchHotelDetails(widget.hotelId);
//           if (fetchedHotel != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HotelDetailPage(
//                   hotelId: fetchedHotel.id,
//                   rooms: const [],
//                 ),
//               ),
//             );
//           } else {
//              ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Hotel details not found.')),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching hotel details: $e')),
//           );
//           debugPrint("Error fetching hotel details: $e");
//         }
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 220,
//           height: 320,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     // Use MemoryImage for Uint8List, otherwise fallback to AssetImage
//                     image: _hotelImageBytes != null
//                         ? MemoryImage(_hotelImageBytes!) as ImageProvider
//                         : const AssetImage("assets/images/hotel.png"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.hotel['name'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         FutureBuilder<String>(
//                           future: Location.fetchLocationName(
//                               widget.hotel['locationId']),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Text('Loading...');
//                             } else if (snapshot.hasError) {
//                               return const Text('Error fetching location');
//                             } else {
//                               return Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       color: Colors.red, size: 16),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       snapshot.data ??
//                                           'Unknown City',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       widget.isWishlisted
//                           ? Icons.favorite
//                           : Icons.favorite_border,
//                       color: widget.isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: widget.onWishlistToggle,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.hotel['description'],
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.orange, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     "${widget.hotel['rating'].toString()} / 5.0",
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LocationListView extends StatelessWidget {
//   const _LocationListView();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('locations').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('Location StreamBuilder Error: ${snapshot.error}');
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No locations available.'));
//         }

//         final locations = snapshot.data!.docs;
//         debugPrint('Fetched ${locations.length} locations from Firestore.');

//         return SizedBox(
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: locations.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final location = locations[index].data() as Map<String, dynamic>;
//               final locationId = locations[index].id;
//               return _LocationCard(name: location['name'], locationId: locationId);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _LocationCard extends StatelessWidget {
//   final String name;
//   final String locationId;

//   const _LocationCard({Key? key, required this.name, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LocationDetailPage(locationId: locationId),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 120,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_pin, color: Colors.red, size: 30),
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
// import 'package:hotel_booking_app/pages/hotel_search_page.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart';
// import 'package:hotel_booking_app/pages/location_search_page.dart';
// import 'package:hotel_booking_app/pages/notification_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; // Import FirebaseMessaging
// import 'package:hotel_booking_app/model/user.dart'; // Import AppUser

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final Set<String> _userWishlistHotelIds = {};
//   User? _currentUser;
//   late StreamSubscription<User?> _authStateSubscription; // To manage auth state listener

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     if (_currentUser != null) {
//       _fetchUserWishlist();
//       _updateFcmTokenForCurrentUser(); // Call to update FCM token
//     }

//     _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (user != null && _currentUser?.uid != user.uid) {
//         // User logged in or switched
//         setState(() {
//           _currentUser = user;
//         });
//         _fetchUserWishlist();
//         _updateFcmTokenForCurrentUser(); // Update FCM token on login/switch
//       } else if (user == null && _currentUser != null) {
//         // User logged out
//         setState(() {
//           _currentUser = null;
//           _userWishlistHotelIds.clear();
//         });
//         _updateFcmTokenForCurrentUser(); // Clear FCM token on logout
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _authStateSubscription.cancel(); // Cancel the subscription
//     super.dispose();
//   }

//   Future<void> _updateFcmTokenForCurrentUser() async {
//     if (_currentUser != null) {
//       String? fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken != null) {
//         debugPrint('HomePage: Updating FCM Token for user ${_currentUser!.uid}: $fcmToken');
//         AppUser? currentUserModel = await AppUser.fetchUserById(_currentUser!.uid);
//         if (currentUserModel != null && currentUserModel.fcmToken != fcmToken) {
//           await currentUserModel.updateFcmToken(fcmToken);
//         } else if (currentUserModel == null) {
//           debugPrint('HomePage: User document not found for ${_currentUser!.uid}. FCM token not saved.');
//           // Handle case where user profile might not exist yet (e.g., new registration)
//           // You might create a new AppUser document here if it's expected at this point.
//         }
//       }
//     } else {
//       // If user logs out, you might want to remove their FCM token from Firestore
//       // (or set it to null) to avoid sending notifications to inactive devices.
//       debugPrint('HomePage: User logged out, considering removing FCM token from Firestore.');
//       // This would require a way to know the previous user's UID to update their document.
//       // A more robust solution might involve Firebase Functions or a server to clean up old tokens.
//     }
//   }

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
//         debugPrint('Fetched wishlist for user: ${_currentUser!.uid}. Hotels: $_userWishlistHotelIds');
//       } else {
//         debugPrint('No wishlist found for user: ${_currentUser!.uid}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching user wishlist: $e');
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

//     setState(() {
//       if (_userWishlistHotelIds.contains(hotelId)) {
//         _userWishlistHotelIds.remove(hotelId);
//         debugPrint('Removed $hotelId from local wishlist');
//       } else {
//         _userWishlistHotelIds.add(hotelId);
//         debugPrint('Added $hotelId to local wishlist');
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
//           if (!currentFavoriteHotelIds.contains(hotelId)) {
//             currentFavoriteHotelIds.add(hotelId);
//           }
//         } else {
//           currentFavoriteHotelIds.remove(hotelId);
//         }

//         transaction.set(
//             userFavoritesDocRef,
//             {
//               'hotelIds': currentFavoriteHotelIds,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             },
//             SetOptions(merge: true));
//         debugPrint('Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds');
//       });
//     } catch (e) {
//       debugPrint('Error updating wishlist in Firestore: $e');
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Home",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const GreetingHeader(),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Hotels",
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const HotelSearchPage()),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _HotelListView(
//             wishlistHotelIds: _userWishlistHotelIds,
//             onToggleWishlist: _toggleWishlist,
//           ),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Location",
//             onTap: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const LocationSearchPage())),
//           ),
//           const SizedBox(height: 10),
//           const _LocationListView(),
//         ],
//       ),
//     );
//   }
// }

// // ----------------------------- COMPONENTS -----------------------------

// class GreetingHeader extends StatefulWidget {
//   const GreetingHeader({super.key});

//   @override
//   State<GreetingHeader> createState() => _GreetingHeaderState();
// }

// class _GreetingHeaderState extends State<GreetingHeader> {
//   File? _localImage;
//   User? _currentUser;
//   String _displayName = 'User';
//   late StreamSubscription<User?> _authStateSubscription; // Manage auth state listener

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadLocalProfileImage();
//     _loadUserData();
//     _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (user != null) {
//         setState(() {
//           _currentUser = user;
//           _displayName = user.displayName ?? 'User';
//         });
//         _loadLocalProfileImage();
//       } else {
//         setState(() {
//           _currentUser = null;
//           _displayName = 'User';
//           _localImage = null;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _authStateSubscription.cancel(); // Cancel the subscription
//     super.dispose();
//   }

//   void _loadUserData() {
//     if (_currentUser != null) {
//       setState(() {
//         _displayName = _currentUser!.displayName ?? 'User';
//       });
//       debugPrint('Loaded user display name: $_displayName');
//     }
//   }

//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     debugPrint('Attempting to load profile image from: ${file.path}');
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//       debugPrint('Profile image found and loaded.');
//     } else {
//       setState(() {
//         _localImage = null;
//       });
//       debugPrint('Profile image not found at: ${file.path}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: Colors.grey,
//           backgroundImage: _localImage != null
//               ? FileImage(_localImage!) as ImageProvider
//               : const AssetImage('assets/images/profile.png'),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Hi, $_displayName',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//         IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const HotelSearchPage()));
//             }),
//         IconButton(
//           icon: const Icon(Icons.notifications),
//           onPressed: () {
//             Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
//           },
//         ),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;

//   const _SectionHeader({required this.title, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         GestureDetector(
//           onTap: onTap,
//           child: const Text("See All", style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }
//   }

// class _HotelListView extends StatelessWidget {
//   const _HotelListView({
//     required this.wishlistHotelIds,
//     required this.onToggleWishlist,
//   });

//   final Set<String> wishlistHotelIds;
//   final Function(String) onToggleWishlist;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('StreamBuilder Error: ${snapshot.error}');
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No hotels available.'));
//         }

//         final hotels = snapshot.data!.docs;
//         debugPrint('Fetched ${hotels.length} hotels from Firestore.');

//         return SizedBox(
//           height: 360,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: hotels.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final hotelDoc = hotels[index];
//               final hotelData = hotelDoc.data() as Map<String, dynamic>;
//               final hotelId = hotelDoc.id;

//               final isWishlisted = wishlistHotelIds.contains(hotelId);

//               return _HotelCard(
//                 hotel: hotelData,
//                 hotelId: hotelId,
//                 isWishlisted: isWishlisted,
//                 onWishlistToggle: () => onToggleWishlist(hotelId),
//                 key: ValueKey(hotelId),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _HotelCard extends StatefulWidget {
//   final Map<String, dynamic> hotel;
//   final String hotelId;
//   final bool isWishlisted;
//   final VoidCallback onWishlistToggle;

//   const _HotelCard({
//     required this.hotel,
//     required this.hotelId,
//     required this.isWishlisted,
//     required this.onWishlistToggle,
//     super.key,
//   });

//   @override
//   State<_HotelCard> createState() => _HotelCardState();
// }

// class _HotelCardState extends State<_HotelCard> {
//   Uint8List? _hotelImageBytes;

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _HotelCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.hotelId != oldWidget.hotelId) {
//       debugPrint('Hotel ID changed, reloading image for ${widget.hotelId}');
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//     final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId);

//     debugPrint('Attempting to load image bytes for hotel ID: ${widget.hotelId} from Hive.');

//     if (imageBytes != null) {
//       setState(() {
//         _hotelImageBytes = imageBytes;
//       });
//       debugPrint('Image bytes found and loaded for hotel ID: ${widget.hotelId}');
//     } else {
//       setState(() {
//         _hotelImageBytes = null;
//       });
//       debugPrint('Image bytes not found for hotel ID: ${widget.hotelId} in Hive. Showing default.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         try {
//           Hotel? fetchedHotel = await Hotel.fetchHotelDetails(widget.hotelId);
//           if (fetchedHotel != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HotelDetailPage(
//                   hotelId: fetchedHotel.id,
//                   rooms: const [],
//                 ),
//               ),
//             );
//           } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Hotel details not found.')),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching hotel details: $e')),
//           );
//           debugPrint("Error fetching hotel details: $e");
//         }
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 220,
//           height: 320,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     image: _hotelImageBytes != null
//                         ? MemoryImage(_hotelImageBytes!) as ImageProvider
//                         : const AssetImage("assets/images/hotel.png"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.hotel['name'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         FutureBuilder<String>(
//                           future: Location.fetchLocationName(
//                               widget.hotel['locationId']),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Text('Loading...');
//                             } else if (snapshot.hasError) {
//                               return const Text('Error fetching location');
//                             } else {
//                               return Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       color: Colors.red, size: 16),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       snapshot.data ??
//                                           'Unknown City',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       widget.isWishlisted
//                           ? Icons.favorite
//                           : Icons.favorite_border,
//                       color: widget.isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: widget.onWishlistToggle,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.hotel['description'],
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.orange, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     "${widget.hotel['rating'].toString()} / 5.0",
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LocationListView extends StatelessWidget {
//   const _LocationListView();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('locations').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('Location StreamBuilder Error: ${snapshot.error}');
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No locations available.'));
//         }

//         final locations = snapshot.data!.docs;
//         debugPrint('Fetched ${locations.length} locations from Firestore.');

//         return SizedBox(
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: locations.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final location = locations[index].data() as Map<String, dynamic>;
//               final locationId = locations[index].id;
//               return _LocationCard(name: location['name'], locationId: locationId);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _LocationCard extends StatelessWidget {
//   final String name;
//   final String locationId;

//   const _LocationCard({Key? key, required this.name, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LocationDetailPage(locationId: locationId),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 120,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_pin, color: Colors.red, size: 30),
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
// import 'package:hotel_booking_app/pages/hotel_search_page.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart';
// import 'package:hotel_booking_app/pages/location_search_page.dart';
// import 'package:hotel_booking_app/pages/notification_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:hotel_booking_app/model/user.dart';
// import 'package:badges/badges.dart' as badges; // Import the badges package

// // Define the same constants as in main.dart
// const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
// const String NEW_NOTIFICATION_KEY = 'new_notification_count';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final Set<String> _userWishlistHotelIds = {};
//   User? _currentUser;
//   late StreamSubscription<User?> _authStateSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     if (_currentUser != null) {
//       _fetchUserWishlist();
//       _updateFcmTokenForCurrentUser();
//     }

//     _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (user != null && _currentUser?.uid != user.uid) {
//         setState(() {
//           _currentUser = user;
//         });
//         _fetchUserWishlist();
//         _updateFcmTokenForCurrentUser();
//       } else if (user == null && _currentUser != null) {
//         setState(() {
//           _currentUser = null;
//           _userWishlistHotelIds.clear();
//         });
//         _updateFcmTokenForCurrentUser();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _authStateSubscription.cancel();
//     super.dispose();
//   }

//   Future<void> _updateFcmTokenForCurrentUser() async {
//     if (_currentUser != null) {
//       String? fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken != null) {
//         debugPrint('HomePage: Updating FCM Token for user ${_currentUser!.uid}: $fcmToken');
//         AppUser? currentUserModel = await AppUser.fetchUserById(_currentUser!.uid);
//         if (currentUserModel != null && currentUserModel.fcmToken != fcmToken) {
//           await currentUserModel.updateFcmToken(fcmToken);
//         } else if (currentUserModel == null) {
//           debugPrint('HomePage: User document not found for ${_currentUser!.uid}. FCM token not saved.');
//         }
//       }
//     } else {
//       debugPrint('HomePage: User logged out, considering removing FCM token from Firestore.');
//     }
//   }

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
//         debugPrint('Fetched wishlist for user: ${_currentUser!.uid}. Hotels: $_userWishlistHotelIds');
//       } else {
//         debugPrint('No wishlist found for user: ${_currentUser!.uid}');
//       }
//     } catch (e) {
//       debugPrint('Error fetching user wishlist: $e');
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

//     setState(() {
//       if (_userWishlistHotelIds.contains(hotelId)) {
//         _userWishlistHotelIds.remove(hotelId);
//         debugPrint('Removed $hotelId from local wishlist');
//       } else {
//         _userWishlistHotelIds.add(hotelId);
//         debugPrint('Added $hotelId to local wishlist');
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
//           if (!currentFavoriteHotelIds.contains(hotelId)) {
//             currentFavoriteHotelIds.add(hotelId);
//           }
//         } else {
//           currentFavoriteHotelIds.remove(hotelId);
//         }

//         transaction.set(
//             userFavoritesDocRef,
//             {
//               'hotelIds': currentFavoriteHotelIds,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             },
//             SetOptions(merge: true));
//         debugPrint('Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds');
//       });
//     } catch (e) {
//       debugPrint('Error updating wishlist in Firestore: $e');
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Home",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const GreetingHeader(),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Hotels",
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const HotelSearchPage()),
//             ),
//           ),
//           const SizedBox(height: 10),
//           _HotelListView(
//             wishlistHotelIds: _userWishlistHotelIds,
//             onToggleWishlist: _toggleWishlist,
//           ),
//           const SizedBox(height: 20),
//           _SectionHeader(
//             title: "Location",
//             onTap: () => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const LocationSearchPage())),
//           ),
//           const SizedBox(height: 10),
//           const _LocationListView(),
//         ],
//       ),
//     );
//   }
// }

// // ----------------------------- COMPONENTS -----------------------------

// class GreetingHeader extends StatefulWidget {
//   const GreetingHeader({super.key});

//   @override
//   State<GreetingHeader> createState() => _GreetingHeaderState();
// }

// class _GreetingHeaderState extends State<GreetingHeader> {
//   File? _localImage;
//   User? _currentUser;
//   String _displayName = 'User';
//   late StreamSubscription<User?> _authStateSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     _loadLocalProfileImage();
//     _loadUserData();
//     _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (user != null) {
//         setState(() {
//           _currentUser = user;
//           _displayName = user.displayName ?? 'User';
//         });
//         _loadLocalProfileImage();
//       } else {
//         setState(() {
//           _currentUser = null;
//           _displayName = 'User';
//           _localImage = null;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _authStateSubscription.cancel();
//     super.dispose();
//   }

//   void _loadUserData() {
//     if (_currentUser != null) {
//       setState(() {
//         _displayName = _currentUser!.displayName ?? 'User';
//       });
//       debugPrint('Loaded user display name: $_displayName');
//     }
//   }

//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     debugPrint('Attempting to load profile image from: ${file.path}');
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//       debugPrint('Profile image found and loaded.');
//     } else {
//       setState(() {
//         _localImage = null;
//       });
//       debugPrint('Profile image not found at: ${file.path}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 24,
//           backgroundColor: Colors.grey,
//           backgroundImage: _localImage != null
//               ? FileImage(_localImage!) as ImageProvider
//               : const AssetImage('assets/images/profile.png'),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Hi, $_displayName',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//         IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const HotelSearchPage()));
//             }),
//         // Notification Icon with Badge
//         ValueListenableBuilder<Box<int>>(
//           valueListenable: Hive.box<int>(NOTIFICATION_COUNT_BOX).listenable(),
//           builder: (context, box, _) {
//             final int newNotificationCount = box.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//             return badges.Badge( // Use badges.Badge
//               showBadge: newNotificationCount > 0,
//               badgeContent: Text(
//                 '$newNotificationCount',
//                 style: const TextStyle(color: Colors.white, fontSize: 10),
//               ),
//               badgeStyle: badges.BadgeStyle( // Use badges.BadgeStyle
//                 shape: badges.BadgeShape.circle,
//                 badgeColor: Colors.red,
//                 padding: const EdgeInsets.all(5),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               position: badges.BadgePosition.topEnd(top: 0, end: 3), // Position the badge
//               child: IconButton(
//                 icon: const Icon(Icons.notifications),
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
//                 },
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;

//   const _SectionHeader({required this.title, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         GestureDetector(
//           onTap: onTap,
//           child: const Text("See All", style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }
//   }

// class _HotelListView extends StatelessWidget {
//   const _HotelListView({
//     required this.wishlistHotelIds,
//     required this.onToggleWishlist,
//   });

//   final Set<String> wishlistHotelIds;
//   final Function(String) onToggleWishlist;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('StreamBuilder Error: ${snapshot.error}');
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No hotels available.'));
//         }

//         final hotels = snapshot.data!.docs;
//         debugPrint('Fetched ${hotels.length} hotels from Firestore.');

//         return SizedBox(
//           height: 360,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: hotels.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final hotelDoc = hotels[index];
//               final hotelData = hotelDoc.data() as Map<String, dynamic>;
//               final hotelId = hotelDoc.id;

//               final isWishlisted = wishlistHotelIds.contains(hotelId);

//               return _HotelCard(
//                 hotel: hotelData,
//                 hotelId: hotelId,
//                 isWishlisted: isWishlisted,
//                 onWishlistToggle: () => onToggleWishlist(hotelId),
//                 key: ValueKey(hotelId),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _HotelCard extends StatefulWidget {
//   final Map<String, dynamic> hotel;
//   final String hotelId;
//   final bool isWishlisted;
//   final VoidCallback onWishlistToggle;

//   const _HotelCard({
//     required this.hotel,
//     required this.hotelId,
//     required this.isWishlisted,
//     required this.onWishlistToggle,
//     super.key,
//   });

//   @override
//   State<_HotelCard> createState() => _HotelCardState();
// }

// class _HotelCardState extends State<_HotelCard> {
//   Uint8List? _hotelImageBytes;

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _HotelCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.hotelId != oldWidget.hotelId) {
//       debugPrint('Hotel ID changed, reloading image for ${widget.hotelId}');
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//     final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId);

//     debugPrint('Attempting to load image bytes for hotel ID: ${widget.hotelId} from Hive.');

//     if (imageBytes != null) {
//       setState(() {
//         _hotelImageBytes = imageBytes;
//       });
//       debugPrint('Image bytes found and loaded for hotel ID: ${widget.hotelId}');
//     } else {
//       setState(() {
//         _hotelImageBytes = null;
//       });
//       debugPrint('Image bytes not found for hotel ID: ${widget.hotelId} in Hive. Showing default.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         try {
//           Hotel? fetchedHotel = await Hotel.fetchHotelDetails(widget.hotelId);
//           if (fetchedHotel != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HotelDetailPage(
//                   hotelId: fetchedHotel.id,
//                   rooms: const [],
//                 ),
//               ),
//             );
//           } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Hotel details not found.')),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error fetching hotel details: $e')),
//           );
//           debugPrint("Error fetching hotel details: $e");
//         }
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 220,
//           height: 320,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     image: _hotelImageBytes != null
//                         ? MemoryImage(_hotelImageBytes!) as ImageProvider
//                         : const AssetImage("assets/images/hotel.png"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.hotel['name'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         FutureBuilder<String>(
//                           future: Location.fetchLocationName(
//                               widget.hotel['locationId']),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Text('Loading...');
//                             } else if (snapshot.hasError) {
//                               return const Text('Error fetching location');
//                             } else {
//                               return Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       color: Colors.red, size: 16),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       snapshot.data ??
//                                           'Unknown City',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       widget.isWishlisted
//                           ? Icons.favorite
//                           : Icons.favorite_border,
//                       color: widget.isWishlisted ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: widget.onWishlistToggle,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.hotel['description'],
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.orange, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     "${widget.hotel['rating'].toString()} / 5.0",
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LocationListView extends StatelessWidget {
//   const _LocationListView();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('locations').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           debugPrint('Location StreamBuilder Error: ${snapshot.error}');
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No locations available.'));
//         }

//         final locations = snapshot.data!.docs;
//         debugPrint('Fetched ${locations.length} locations from Firestore.');

//         return SizedBox(
//           height: 120,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: locations.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final location = locations[index].data() as Map<String, dynamic>;
//               final locationId = locations[index].id;
//               return _LocationCard(name: location['name'], locationId: locationId);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _LocationCard extends StatelessWidget {
//   final String name;
//   final String locationId;

//   const _LocationCard({Key? key, required this.name, required this.locationId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LocationDetailPage(locationId: locationId),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 120,
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.location_pin, color: Colors.red, size: 30),
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
import 'package:hotel_booking_app/pages/hotel_search_page.dart';
import 'package:hotel_booking_app/pages/location_detail_page.dart';
import 'package:hotel_booking_app/pages/location_search_page.dart';
import 'package:hotel_booking_app/pages/notification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hotel_booking_app/model/user.dart';
import 'package:badges/badges.dart' as badges;

// Define the same constants as in main.dart
const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
const String NEW_NOTIFICATION_KEY = 'new_notification_count';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _userWishlistHotelIds = {};
  User? _currentUser;
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _fetchUserWishlist();
      _updateFcmTokenForCurrentUser();
    }

    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && _currentUser?.uid != user.uid) {
        setState(() {
          _currentUser = user;
        });
        _fetchUserWishlist();
        _updateFcmTokenForCurrentUser();
      } else if (user == null && _currentUser != null) {
        setState(() {
          _currentUser = null;
          _userWishlistHotelIds.clear();
        });
        _updateFcmTokenForCurrentUser();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _updateFcmTokenForCurrentUser() async {
    if (_currentUser != null) {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        debugPrint('HomePage: Updating FCM Token for user ${_currentUser!.uid}: $fcmToken');
        AppUser? currentUserModel = await AppUser.fetchUserById(_currentUser!.uid);
        if (currentUserModel != null && currentUserModel.fcmToken != fcmToken) {
          await currentUserModel.updateFcmToken(fcmToken);
        } else if (currentUserModel == null) {
          debugPrint('HomePage: User document not found for ${_currentUser!.uid}. FCM token not saved.');
        }
      }
    } else {
      debugPrint('HomePage: User logged out, considering removing FCM token from Firestore.');
    }
  }

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

    final favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');
    final userFavoritesDocRef = favoritesCollection.doc(_currentUser!.uid);

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
          if (!currentFavoriteHotelIds.contains(hotelId)) {
            currentFavoriteHotelIds.add(hotelId);
          }
        } else {
          currentFavoriteHotelIds.remove(hotelId);
        }

        transaction.set(
            userFavoritesDocRef,
            {
              'hotelIds': currentFavoriteHotelIds,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        debugPrint('Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds');
      });
    } catch (e) {
      debugPrint('Error updating wishlist in Firestore: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const GreetingHeader(),
          const SizedBox(height: 20),
          _SectionHeader(
            title: "Hotels",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HotelSearchPage()),
            ),
          ),
          const SizedBox(height: 10),
          _HotelListView(
            wishlistHotelIds: _userWishlistHotelIds,
            onToggleWishlist: _toggleWishlist,
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: "Location",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LocationSearchPage())),
          ),
          const SizedBox(height: 10),
          const _LocationListView(),
        ],
      ),
    );
  }
}

// ----------------------------- COMPONENTS -----------------------------

class GreetingHeader extends StatefulWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader> {
  File? _localImage;
  User? _currentUser;
  String _displayName = 'User';
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadLocalProfileImage();
    _loadUserData();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          _currentUser = user;
          _displayName = user.displayName ?? 'User';
        });
        _loadLocalProfileImage();
      } else {
        setState(() {
          _currentUser = null;
          _displayName = 'User';
          _localImage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _loadUserData() {
    if (_currentUser != null) {
      setState(() {
        _displayName = _currentUser!.displayName ?? 'User';
      });
      debugPrint('Loaded user display name: $_displayName');
    }
  }

  Future<void> _loadLocalProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_image.png');
    debugPrint('Attempting to load profile image from: ${file.path}');
    if (await file.exists()) {
      setState(() {
        _localImage = file;
      });
      debugPrint('Profile image found and loaded.');
    } else {
      setState(() {
        _localImage = null;
      });
      debugPrint('Profile image not found at: ${file.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey,
          backgroundImage: _localImage != null
              ? FileImage(_localImage!) as ImageProvider
              : const AssetImage('assets/images/profile.png'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Hi, $_displayName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HotelSearchPage()));
            }),
        // Notification Icon with Badge
        ValueListenableBuilder<Box<int>>(
          valueListenable: Hive.box<int>(NOTIFICATION_COUNT_BOX).listenable(),
          builder: (context, box, _) {
            final int newNotificationCount = box.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
            debugPrint('HomePage: Current new notification count from Hive: $newNotificationCount'); // Debug print
            return badges.Badge(
              showBadge: newNotificationCount > 0,
              badgeContent: Text(
                '$newNotificationCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.circle,
                badgeColor: Colors.red,
                padding: const EdgeInsets.all(5),
                borderRadius: BorderRadius.circular(20),
              ),
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: onTap,
          child: const Text("See All", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
  }

class _HotelListView extends StatelessWidget {
  const _HotelListView({
    required this.wishlistHotelIds,
    required this.onToggleWishlist,
  });

  final Set<String> wishlistHotelIds;
  final Function(String) onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('StreamBuilder Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hotels available.'));
        }

        final hotels = snapshot.data!.docs;
        debugPrint('Fetched ${hotels.length} hotels from Firestore.');

        return SizedBox(
          height: 400,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hotels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final hotelDoc = hotels[index];
              final hotelData = hotelDoc.data() as Map<String, dynamic>;
              final hotelId = hotelDoc.id;

              final isWishlisted = wishlistHotelIds.contains(hotelId);

              return _HotelCard(
                hotel: hotelData,
                hotelId: hotelId,
                isWishlisted: isWishlisted,
                onWishlistToggle: () => onToggleWishlist(hotelId),
                key: ValueKey(hotelId),
              );
            },
          ),
        );
      },
    );
  }
}

class _HotelCard extends StatefulWidget {
  final Map<String, dynamic> hotel;
  final String hotelId;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  const _HotelCard({
    required this.hotel,
    required this.hotelId,
    required this.isWishlisted,
    required this.onWishlistToggle,
    super.key,
  });

  @override
  State<_HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<_HotelCard> {
  Uint8List? _hotelImageBytes;

  @override
  void initState() {
    super.initState();
    _loadHotelImage();
  }

  @override
  void didUpdateWidget(covariant _HotelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hotelId != oldWidget.hotelId) {
      debugPrint('Hotel ID changed, reloading image for ${widget.hotelId}');
      _loadHotelImage();
    }
  }

  Future<void> _loadHotelImage() async {
    final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
    final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId);

    debugPrint('Attempting to load image bytes for hotel ID: ${widget.hotelId} from Hive.');

    if (imageBytes != null) {
      setState(() {
        _hotelImageBytes = imageBytes;
      });
      debugPrint('Image bytes found and loaded for hotel ID: ${widget.hotelId}');
    } else {
      setState(() {
        _hotelImageBytes = null;
      });
      debugPrint('Image bytes not found for hotel ID: ${widget.hotelId} in Hive. Showing default.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          Hotel? fetchedHotel = await Hotel.fetchHotelDetails(widget.hotelId);
          if (fetchedHotel != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailPage(
                  hotelId: fetchedHotel.id,
                  rooms: const [],
                ),
              ),
            );
          } else {
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hotel details not found.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching hotel details: $e')),
          );
          debugPrint("Error fetching hotel details: $e");
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 220,
          height: 320,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hotel['name'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: Location.fetchLocationName(
                              widget.hotel['locationId']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading...');
                            } else if (snapshot.hasError) {
                              return const Text('Error fetching location');
                            } else {
                              return Row(
                                children: [
                                  const Icon(Icons.location_pin,
                                      color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      snapshot.data ??
                                          'Unknown City',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isWishlisted
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.isWishlisted ? Colors.red : Colors.grey,
                    ),
                    onPressed: widget.onWishlistToggle,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.hotel['description'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.hotel['rating'].toString()} / 5.0",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationListView extends StatelessWidget {
  const _LocationListView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('locations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('Location StreamBuilder Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No locations available.'));
        }

        final locations = snapshot.data!.docs;
        debugPrint('Fetched ${locations.length} locations from Firestore.');

        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final location = locations[index].data() as Map<String, dynamic>;
              final locationId = locations[index].id;
              return _LocationCard(name: location['name'], locationId: locationId);
            },
          ),
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String name;
  final String locationId;

  const _LocationCard({Key? key, required this.name, required this.locationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationDetailPage(locationId: locationId),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_pin, color: Colors.red, size: 30),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}




