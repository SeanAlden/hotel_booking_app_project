import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/hotel_detail_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  User? _currentUser;
  Set<String> _userWishlistHotelIds = {};

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    searchController.addListener(_onSearchChanged);
    if (_currentUser != null) {
      _fetchUserWishlist();
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
                    childAspectRatio: 0.48,
                  ),
                  itemCount: filteredHotels.length,
                  itemBuilder: (_, index) {
                    final hotelDoc = filteredHotels[index];
                    final hotel = Hotel.fromFirestore(hotelDoc);
                    final isWishlisted =
                        _userWishlistHotelIds.contains(hotel.id);

                    return _LocationHotelCard(
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
        _hotelImageBytes = null;
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
                rooms: const [],
              ),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(
                  height: 48,
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
                          const Icon(Icons.star,
                              color: Colors.orange, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                              child: Text(
                            "${widget.hotel.rating.toStringAsFixed(1)} / 5.0",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          )),
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
