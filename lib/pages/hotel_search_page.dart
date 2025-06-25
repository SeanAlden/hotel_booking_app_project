import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  List<Hotel> hotels = [];
  String searchQuery = "";
  User? _currentUser;
  Set<String> _userWishlistHotelIds = {};

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchHotels();
    if (_currentUser != null) {
      _fetchUserWishlist();
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
        debugPrint(
            'Wishlist updated in Firestore for user: ${_currentUser!.uid}. New list: $currentFavoriteHotelIds');
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

  Future<void> _fetchHotels() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('hotels').get();
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by hotel name...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
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

    debugPrint(
        'Attempting to load search hotel image bytes for ID: ${widget.hotel.id} from Hive.');

    if (imageBytes != null) {
      setState(() {
        _hotelImageBytes = imageBytes;
      });
      debugPrint(
          'Search hotel image bytes found and loaded for ID: ${widget.hotel.id}.');
    } else {
      setState(() {
        _hotelImageBytes = null;
      });
      debugPrint(
          'Search hotel image bytes not found for ID: ${widget.hotel.id} in Hive. Showing default.');
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
                rooms: const [],
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
                            : const AssetImage("assets/images/hotel.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                                widget.hotel.locationId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0));
                              } else if (snapshot.hasError) {
                                return const Text('Error fetching location');
                              } else {
                                return Expanded(
                                  child: Text(
                                    snapshot.data ?? 'Unknown Location',
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
                            widget.hotel.rating.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      )
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
                  onPressed: () {
                    widget.onToggleWishlist(widget.hotel.id);
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
