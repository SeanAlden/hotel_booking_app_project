import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/login_page.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  List<Hotel> _hotels = []; // List to store hotel data

  @override
  void initState() {
    super.initState();
    _fetchHotels(); // Fetch hotels when the page is initialized
  }

  Future<void> _fetchHotels() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('hotels').get();
    setState(() {
      _hotels = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Hotel(
          id: doc.id,
          name: data['name'] ?? 'Unknown Hotel',
          locationId: data['locationId'] ?? 'Unknown Location',
          rating: data['rating']?.toDouble() ?? 0.0,
          description: data['description'] ?? 'No description available',
          amenities: List<String>.from(data['amenities'] ?? []),
        );
      }).toList();
    });
  }

  Future<String> _getLocationName(String locationId) async {
    return await Location.fetchLocationName(locationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _GreetingHeader(),
          const SizedBox(height: 20),
          _SectionHeader(
            title: "Hotels",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ),
          ),
          const SizedBox(height: 10),
          _HotelListView(
              hotels: _hotels,
              getLocationName: _getLocationName), // Pass the fetched hotels
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ----------------------------- COMPONENTS -----------------------------

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey,
          backgroundImage: AssetImage('assets/images/profile.png'),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Hi, Guest',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
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
  final List<Hotel> hotels; // Accept hotels as a parameter
  final Future<String> Function(String)
      getLocationName; // Function to get location name

  const _HotelListView({required this.hotels, required this.getLocationName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hotels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final hotel = hotels[index];

          return FutureBuilder<String>(
            future: getLocationName(hotel.locationId), // Fetch location name
            builder: (context, snapshot) {
              String city = snapshot.connectionState == ConnectionState.waiting
                  ? 'Loading...'
                  : snapshot.data ?? 'Unknown Location';

              return _HotelCard(
                name: hotel.name,
                image:
                    "assets/images/hotel.png", // Use a default image or fetch from hotel data if available
                city: city, // Use the fetched location name
                rate: hotel.rating
                    .toString(), // Assuming rating is used as price for display
                description: hotel.description,
              );
            },
          );
        },
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final String name;
  final String image;
  final String city;
  final String rate;
  final String description;

  const _HotelCard({
    required this.name,
    required this.image,
    required this.city,
    required this.rate,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
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
                    image: AssetImage(image),
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
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_pin,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.star, color: Colors.orange),
                const SizedBox(width: 5),
                Text(
                  rate,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ]),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Login to Book",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
