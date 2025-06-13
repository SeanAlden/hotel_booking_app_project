import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
import 'package:hotel_booking_app/pages/hotel_search_page.dart';
import 'package:hotel_booking_app/pages/location_detail_page.dart';
import 'package:hotel_booking_app/pages/location_search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _wishlist = {};

  void _toggleWishlist(String hotelName) {
    setState(() {
      if (_wishlist.contains(hotelName)) {
        _wishlist.remove(hotelName);
      } else {
        _wishlist.add(hotelName);
      }
    });
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
              MaterialPageRoute(builder: (_) => HotelSearchPage()),
            ),
          ),
          const SizedBox(height: 10),
          _HotelListView(
            wishlist: _wishlist,
            onToggleWishlist: _toggleWishlist,
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: "Location",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => LocationSearchPage())),
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

  @override
  void initState() {
    super.initState();
    _loadLocalProfileImage();
  }

  Future<void> _loadLocalProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_image.png');
    if (await file.exists()) {
      setState(() {
        _localImage = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
            'Hi, ${user?.displayName ?? 'User '}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
             
            }),
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
  const _HotelListView({
    required this.wishlist,
    required this.onToggleWishlist,
  });

  final Set<String> wishlist;
  final Function(String) onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final hotels = snapshot.data!.docs;

        return SizedBox(
          height: 360,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hotels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final hotel = hotels[index].data() as Map<String, dynamic>;
              final isWishlisted = wishlist.contains(hotel["name"]);

              return _HotelCard(
                hotel: hotel,
                isWishlisted: isWishlisted,
                onWishlistToggle: () =>
                    onToggleWishlist(hotel["name"] as String),
              );
            },
          ),
        );
      },
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Map<String, dynamic> hotel;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  const _HotelCard({
    required this.hotel,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          Hotel? fetchedHotel = await Hotel.fetchHotelDetails(hotel['hotelId']);
          if (fetchedHotel != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailPage(
                  hotelId: fetchedHotel.id,
                  rooms: [], 
                ),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching hotel details: $e')),
          );
          print("Error fetching hotel details: $e");
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
                    image: AssetImage(
                        "assets/images/hotel.png"), // Assuming image URL is stored in Firestore
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
                          hotel['name'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future:
                              Location.fetchLocationName(hotel['locationId']),
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
                                          'Unknown City', // Handle null case
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
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.grey,
                    ),
                    onPressed: onWishlistToggle,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hotel['description'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${hotel['rating'].toString()} / 5.0",
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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final locations = snapshot.data!.docs;

        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final location = locations[index].data() as Map<String, dynamic>;
              return _LocationCard(
                  name: location['name'], locationId: location['locationId']);
            },
          ),
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String name;
  final String locationId; // New property for locationId

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
