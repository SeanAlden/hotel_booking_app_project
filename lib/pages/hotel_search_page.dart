import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart'; // Ganti dengan path yang sesuai

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
