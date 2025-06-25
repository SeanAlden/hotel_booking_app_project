import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  User? _currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      debugPrint('Favorite search query changed to: $_searchQuery');
    });
  }

  Future<void> _removeFromFavorites(String hotelId) async {
    if (_currentUser == null) return;

    final userFavoritesDocRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(_currentUser!.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userFavoritesDocRef);

        List<String> currentFavoriteHotelIds = [];
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          currentFavoriteHotelIds = List<String>.from(data['hotelIds'] ?? []);
        }

        currentFavoriteHotelIds.remove(hotelId);

        transaction.set(
            userFavoritesDocRef,
            {
              'hotelIds': currentFavoriteHotelIds,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        debugPrint('Hotel $hotelId removed from favorites in Firestore.');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel removed from favorites.')),
      );
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text('Please log in to view your favorites.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('favorites')
                  .doc(_currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('Favorite StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No favorite hotels yet.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                List<String> favoriteHotelIds =
                    List<String>.from(data['hotelIds'] ?? []);
                debugPrint(
                    'Fetched ${favoriteHotelIds.length} favorite hotel IDs.');

                if (favoriteHotelIds.isEmpty) {
                  return const Center(child: Text('No favorite hotels yet.'));
                }

                return FutureBuilder<List<Hotel>>(
                  future: _fetchFavoriteHotelsDetails(favoriteHotelIds),
                  builder: (context, hotelSnapshot) {
                    if (hotelSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (hotelSnapshot.hasError) {
                      debugPrint(
                          'Favorite Hotel Details FutureBuilder Error: ${hotelSnapshot.error}');
                      return Center(
                          child: Text(
                              'Error fetching hotels: ${hotelSnapshot.error}'));
                    }
                    if (!hotelSnapshot.hasData || hotelSnapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No favorite hotels found.'));
                    }

                    List<Hotel> hotels = hotelSnapshot.data!;
                    debugPrint(
                        'Fetched ${hotels.length} actual favorite hotel details.');

                    List<Hotel> filteredHotels = hotels.where((hotel) {
                      return hotel.name.toLowerCase().contains(_searchQuery) ||
                          hotel.description
                              .toLowerCase()
                              .contains(_searchQuery);
                    }).toList();
                    debugPrint(
                        'Filtered ${filteredHotels.length} favorite hotels with query: $_searchQuery');

                    if (filteredHotels.isEmpty) {
                      return Center(
                          child: Text('No hotels found for "${_searchQuery}"'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.53,
                      ),
                      itemCount: filteredHotels.length,
                      itemBuilder: (context, index) {
                        final hotel = filteredHotels[index];
                        return _FavoriteHotelCard(
                          hotel: hotel,
                          onRemoveFavorite: () =>
                              _removeFromFavorites(hotel.id),
                        );
                      },
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

  Future<List<Hotel>> _fetchFavoriteHotelsDetails(List<String> hotelIds) async {
    if (hotelIds.isEmpty) {
      return [];
    }
    List<Hotel> favoriteHotels = [];
    for (String id in hotelIds) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('hotels').doc(id).get();
      if (doc.exists) {
        favoriteHotels.add(Hotel.fromFirestore(doc));
      } else {
        debugPrint('Favorite hotel with ID $id not found in Firestore.');
      }
    }
    return favoriteHotels;
  }
}

class _FavoriteHotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onRemoveFavorite;

  const _FavoriteHotelCard({
    Key? key,
    required this.hotel,
    required this.onRemoveFavorite,
  }) : super(key: key);

  @override
  State<_FavoriteHotelCard> createState() => _FavoriteHotelCardState();
}

class _FavoriteHotelCardState extends State<_FavoriteHotelCard> {
  Uint8List? _hotelImageBytes;

  @override
  void initState() {
    super.initState();
    _loadHotelImage();
  }

  @override
  void didUpdateWidget(covariant _FavoriteHotelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hotel.id != oldWidget.hotel.id) {
      _loadHotelImage();
    }
  }

  Future<void> _loadHotelImage() async {
    final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
    final Uint8List? imageBytes = hotelImagesBox.get(widget.hotel.id);

    debugPrint(
        'Attempting to load favorite hotel image bytes for ID: ${widget.hotel.id} from Hive.');

    if (imageBytes != null) {
      setState(() {
        _hotelImageBytes = imageBytes;
      });
      debugPrint(
          'Favorite hotel image bytes found and loaded for ID: ${widget.hotel.id}.');
    } else {
      setState(() {
        _hotelImageBytes = null;
      });
      debugPrint(
          'Favorite hotel image bytes not found for ID: ${widget.hotel.id} in Hive. Showing default.');
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
              rooms: const [],
            ),
          ),
        );
      },
      child: Card(
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
                    image: _hotelImageBytes != null
                        ? MemoryImage(_hotelImageBytes!) as ImageProvider
                        : const AssetImage("assets/images/hotel.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.hotel.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onRemoveFavorite,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FutureBuilder<String>(
                future: Location.fetchLocationName(widget.hotel.locationId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading location...');
                  } else if (snapshot.hasError) {
                    return const Text('Error location');
                  } else {
                    return Row(
                      children: [
                        const Icon(Icons.location_pin,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            snapshot.data ?? 'Unknown City',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text("${widget.hotel.rating.toStringAsFixed(1)} / 5.0"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
