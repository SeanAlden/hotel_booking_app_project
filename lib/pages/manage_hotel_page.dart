import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/add_hotel_page.dart';
import 'package:hotel_booking_app/pages/edit_hotel_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageHotelPage extends StatefulWidget {
  const ManageHotelPage({Key? key}) : super(key: key);

  @override
  State<ManageHotelPage> createState() => _ManageHotelPageState();
}

class _ManageHotelPageState extends State<ManageHotelPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
      debugPrint('Search query changed to: $_searchQuery');
    });
  }

  Future<void> _deleteHotel(String hotelId) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Hotel'),
            content: const Text(
                'Are you sure you want to delete this hotel? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('hotels')
            .doc(hotelId)
            .delete();
        debugPrint('Hotel ID $hotelId deleted from Firestore.');

        final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
        await hotelImagesBox.delete(hotelId);
        debugPrint('Image for hotel ID $hotelId deleted from Hive.');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel deleted successfully!')),
        );
      } catch (e) {
        debugPrint('Error deleting hotel $hotelId: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete hotel: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Manage Hotels', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search hotels by name...',
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
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('hotels').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint(
                      'ManageHotelPage: StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hotels added yet.'));
                }

                final allHotels = snapshot.data!.docs;
                final filteredHotels = allHotels.where((hotelDoc) {
                  final hotelName =
                      (hotelDoc.data() as Map<String, dynamic>)['name']
                              ?.toLowerCase() ??
                          '';
                  return hotelName.contains(_searchQuery);
                }).toList();

                if (filteredHotels.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                      child:
                          Text('No hotels found matching "${_searchQuery}"'));
                } else if (filteredHotels.isEmpty) {
                  return const Center(child: Text('No hotels added yet.'));
                }
                debugPrint(
                    'ManageHotelPage: Displaying ${filteredHotels.length} hotels.');

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredHotels.length,
                  itemBuilder: (context, index) {
                    final hotelDoc = filteredHotels[index];
                    final hotel = Hotel.fromFirestore(hotelDoc);

                    return _ManageHotelListItem(
                      key: ValueKey(hotel.id),
                      hotel: hotel,
                      onEdit: () async {
                        debugPrint(
                            'Navigating to EditHotelPage for ID: ${hotel.id}');

                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditHotelPage(hotelId: hotel.id),
                          ),
                        );

                        if (result == true) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Hotel data updated and refreshed!')),
                          );
                        }
                      },
                      onDelete: () => _deleteHotel(hotel.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHotelPage()),
          );
          if (result == true) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('New hotel added and list refreshed!')),
            );
          }
        },
        label: const Text('Add Hotel'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ManageHotelListItem extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageHotelListItem({
    Key? key,
    required this.hotel,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_ManageHotelListItem> createState() => _ManageHotelListItemState();
}

class _ManageHotelListItemState extends State<_ManageHotelListItem> {
  Uint8List? _hotelImageBytes;

  @override
  void initState() {
    super.initState();
    _loadHotelImage();
  }

  @override
  void didUpdateWidget(covariant _ManageHotelListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hotel.id != oldWidget.hotel.id) {
      debugPrint(
          'ManageHotelPage: _ManageHotelListItem: Hotel ID changed from ${oldWidget.hotel.id} to ${widget.hotel.id}, reloading image.');
      _loadHotelImage();
    }
  }

  Future<void> _loadHotelImage() async {
    try {
      final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
      final Uint8List? imageBytes = hotelImagesBox.get(widget.hotel.id);

      debugPrint(
          'ManageHotelPage: _ManageHotelListItem: Attempting to load image for hotel ID: ${widget.hotel.id} from Hive.');

      if (imageBytes != null) {
        setState(() {
          _hotelImageBytes = imageBytes;
        });
        debugPrint(
            'ManageHotelPage: _ManageHotelListItem: Image found and loaded for hotel ID: ${widget.hotel.id}. Size: ${imageBytes.lengthInBytes} bytes.');
      } else {
        setState(() {
          _hotelImageBytes = null;
        });
        debugPrint(
            'ManageHotelPage: _ManageHotelListItem: Image not found for hotel ID: ${widget.hotel.id} in Hive. Showing default.');
      }
    } catch (e) {
      debugPrint(
          'ManageHotelPage: _ManageHotelListItem: Error loading image from Hive for ID ${widget.hotel.id}: $e');
      setState(() {
        _hotelImageBytes = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: _hotelImageBytes != null
                      ? MemoryImage(_hotelImageBytes!) as ImageProvider
                      : const AssetImage("assets/images/hotel.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                        return Text('Location: ${snapshot.data ?? 'Unknown'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey));
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                      'Rating: ${widget.hotel.rating.toStringAsFixed(1)} / 5.0',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: widget.onEdit,
                  tooltip: 'Edit Hotel',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete Hotel',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
