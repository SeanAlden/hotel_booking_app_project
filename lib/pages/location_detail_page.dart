import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';

class LocationDetailPage extends StatelessWidget {
  final String locationId;

  const LocationDetailPage({Key? key, required this.locationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: Location.fetchLocationName(locationId),
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
                style: TextStyle(color: Colors.white));
          },
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hotels')
            .where('locationId', isEqualTo: locationId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hotels = snapshot.data!.docs;

          if (hotels.isEmpty) {
            return const Center(
                child: Text("No hotels found in this location"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.55,
            ),
            itemCount: hotels.length,
            itemBuilder: (_, index) {
              final hotel = hotels[index].data() as Map<String, dynamic>;
              return _HotelCard(hotel: hotel);
            },
          );
        },
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Map<String, dynamic> hotel;

  const _HotelCard({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage("assets/images/hotel.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hotel['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              hotel['description'],
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            const SizedBox(height: 4),
            // Row(
            //   children: [
            //     const Icon(Icons.star, color: Colors.orange),
            //     Text("${hotel['rating']} / 5.0"),
            //     IconButton(
            //       icon: const Icon(Icons.favorite_border),
            //       onPressed: () {
            //         // Handle wishlist toggle
            //       },
            //     ),
            //   ],
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange),
                    const SizedBox(
                        width: 6), // Jarak kecil antara ikon dan teks
                    Text("${hotel['rating']} / 5.0"),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // Handle wishlist toggle
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
