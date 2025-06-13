// import 'package:flutter/material.dart';

// class HotelSearchPage extends StatefulWidget {
//   const HotelSearchPage({super.key});

//   @override
//   State<HotelSearchPage> createState() => _HotelSearchPageState();
// }

// class _HotelSearchPageState extends State<HotelSearchPage> {
//   // Sample hotel data with descriptions
//   final List<Map<String, String>> hotels = [
//     {
//       "name": "Hotel A",
//       "location": "Surabaya",
//       "rating": "3.7",
//       "image": "assets/images/hotel.png", // Placeholder for the image URL
//       "description":
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.",
//     },
//     {
//       "name": "Hotel B",
//       "location": "Jakarta",
//       "rating": "4.2",
//       "image": "assets/images/hotel.png", // Placeholder for the image URL
//       "description":
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.",
//     },
//     {
//       "name": "Hotel C",
//       "location": "Malang",
//       "rating": "4.1",
//       "image": "assets/images/hotel.png", // Placeholder for the image URL
//       "description":
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.",
//     },
//     {
//       "name": "Hotel D",
//       "location": "Yogyakarta",
//       "rating": "3.4",
//       "image": "assets/images/hotel.png", // Placeholder for the image URL
//       "description":
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.",
//     },
//   ];

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
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search...',
//                 border: OutlineInputBorder(),
//                 prefixIcon: const Icon(Icons.search),
//               ),
//             ),
//           ),
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
//                                   image: AssetImage(hotel["image"]!),
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
//                                   hotel["name"]!,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 // Hotel description
//                                 Text(
//                                   hotel["description"]!,
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(color: Colors.black54),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 // Text(
//                                 //   hotel["location"]!,
//                                 //   style: const TextStyle(color: Colors.grey),
//                                 // ),

//                                 Row(
//                                   children: [
//                                     const Icon(Icons.location_pin,
//                                         color: Colors.red, size: 16),
//                                     const SizedBox(width: 4),
//                                     Expanded(
//                                       child: Text(
//                                         hotel["location"]!,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
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
//                                       hotel["rating"]!,
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
// import 'package:hotel_booking_app/model/hotel.dart'; // Ganti dengan path yang sesuai

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
//     final snapshot = await FirebaseFirestore.instance.collection('hotels').get();
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
//                 hintText: 'Search...',
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
//                                   image: AssetImage(hotel.amenities.isNotEmpty ? hotel.amenities[0] : "assets/images/hotel.png"), // Ganti dengan gambar hotel jika ada
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
//                                     const Icon(Icons.location_pin, color: Colors.red, size: 16),
//                                     const SizedBox(width: 4),
//                                     Expanded(
//                                       child: Text(
//                                         hotel.locationId, // Ganti dengan nama lokasi jika sudah diambil
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.star, color: Colors.orange, size: 20),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       hotel.rating.toString(),
//                                       style: const TextStyle(color: Colors.black),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/hotel.dart'; // Ganti dengan path yang sesuai

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  List<Hotel> hotels = []; // List untuk menyimpan data hotel

  @override
  void initState() {
    super.initState();
    _fetchHotels(); // Ambil data hotel saat halaman diinisialisasi
  }

  Future<void> _fetchHotels() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('hotels').get();
    setState(() {
      hotels = snapshot.docs.map((doc) {
        return Hotel(
          id: doc.id,
          name: doc['name'],
          locationId: doc['locationId'],
          rating: (doc['rating'] as num).toDouble(),
          description: doc['description'],
          amenities: List<String>.from(doc['amenities'] ?? []),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Hotel List View
          Expanded(
            child: ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Placeholder for hotel image
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image:
                                      // AssetImage(hotel.amenities.isNotEmpty ? hotel.amenities[0] : "assets/images/hotel.png"),
                                      AssetImage("assets/images/hotel.png"),
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
                                  hotel.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Hotel description
                                Text(
                                  hotel.description,
                                  maxLines: 3,
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
                                      future: Location.fetchLocationName(hotel
                                          .locationId), // Ambil nama lokasi
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator(); // Tampilkan loading saat menunggu
                                        } else if (snapshot.hasError) {
                                          return const Text(
                                              'Error fetching location'); // Tampilkan error jika ada
                                        } else {
                                          return Expanded(
                                            child: Text(
                                              snapshot.data ??
                                                  'Unknown Location', // Tampilkan nama lokasi
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
                                      hotel.rating.toString(),
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
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {
                              // Handle wishlist toggle
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
