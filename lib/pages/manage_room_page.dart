import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/room.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/pages/add_room_page.dart';
import 'package:hotel_booking_app/pages/edit_room_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageRoomPage extends StatefulWidget {
  const ManageRoomPage({Key? key}) : super(key: key);

  @override
  State<ManageRoomPage> createState() => _ManageRoomPageState();
}

class _ManageRoomPageState extends State<ManageRoomPage> {
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
      debugPrint('ManageRoomPage: Search query changed to: $_searchQuery');
    });
  }

  Future<void> _deleteRoom(String roomId) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Room'),
            content: const Text(
                'Are you sure you want to delete this room? This action cannot be undone.'),
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
            .collection('rooms')
            .doc(roomId)
            .delete();
        debugPrint('ManageRoomPage: Room ID $roomId deleted from Firestore.');

        final roomImagesBox = Hive.box<Uint8List>('room_images');
        await roomImagesBox.delete(roomId);
        debugPrint(
            'ManageRoomPage: Image for room ID $roomId deleted from Hive.');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted successfully!')),
        );
      } catch (e) {
        debugPrint('ManageRoomPage: Error deleting room $roomId: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete room: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Manage Rooms', style: TextStyle(color: Colors.white)),
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
                hintText: 'Search rooms by type...',
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
                  FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint(
                      'ManageRoomPage: StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No rooms added yet.'));
                }

                final allRooms = snapshot.data!.docs;
                final filteredRooms = allRooms.where((roomDoc) {
                  final roomType =
                      (roomDoc.data() as Map<String, dynamic>)['type']
                              ?.toLowerCase() ??
                          '';
                  return roomType.contains(_searchQuery);
                }).toList();

                if (filteredRooms.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                      child: Text('No rooms found matching "${_searchQuery}"'));
                } else if (filteredRooms.isEmpty) {
                  return const Center(child: Text('No rooms added yet.'));
                }
                debugPrint(
                    'ManageRoomPage: Displaying ${filteredRooms.length} rooms.');

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    final roomDoc = filteredRooms[index];
                    final room = Room.fromFirestore(roomDoc);

                    return _ManageRoomListItem(
                      key: ValueKey(room.id),
                      room: room,
                      onEdit: () async {
                        debugPrint(
                            'Navigating to EditRoomPage for ID: ${room.id}');

                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRoomPage(roomId: room.id),
                          ),
                        );

                        if (result == true) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Room data updated and refreshed!')),
                          );
                        }
                      },
                      onDelete: () => _deleteRoom(room.id),
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
            MaterialPageRoute(builder: (context) => const AddRoomPage()),
          );
          if (result == true) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('New room added and list refreshed!')),
            );
          }
        },
        label: const Text('Add Room'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ManageRoomListItem extends StatefulWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageRoomListItem({
    Key? key,
    required this.room,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_ManageRoomListItem> createState() => _ManageRoomListItemState();
}

class _ManageRoomListItemState extends State<_ManageRoomListItem> {
  Uint8List? _roomImageBytes;
  String _hotelName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadRoomImage();
    _fetchHotelName();
  }

  @override
  void didUpdateWidget(covariant _ManageRoomListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.room.id != oldWidget.room.id) {
      debugPrint(
          'ManageRoomPage: _ManageRoomListItem: Room ID changed from ${oldWidget.room.id} to ${widget.room.id}, reloading image and hotel name.');
      _loadRoomImage();
      _fetchHotelName();
    }
  }

  Future<void> _loadRoomImage() async {
    try {
      final roomImagesBox = Hive.box<Uint8List>('room_images');
      final Uint8List? imageBytes = roomImagesBox.get(widget.room.id);

      debugPrint(
          'ManageRoomPage: _ManageRoomListItem: Attempting to load image for room ID: ${widget.room.id} from Hive.');

      if (imageBytes != null) {
        setState(() {
          _roomImageBytes = imageBytes;
        });
        debugPrint(
            'ManageRoomPage: _ManageRoomListItem: Image found and loaded for room ID: ${widget.room.id}. Size: ${imageBytes.lengthInBytes} bytes.');
      } else {
        setState(() {
          _roomImageBytes = null;
        });
        debugPrint(
            'ManageRoomPage: _ManageRoomListItem: Image not found for room ID: ${widget.room.id} in Hive. Showing default.');
      }
    } catch (e) {
      debugPrint(
          'ManageRoomPage: _ManageRoomListItem: Error loading image from Hive for ID ${widget.room.id}: $e');
      setState(() {
        _roomImageBytes = null;
      });
    }
  }

  Future<void> _fetchHotelName() async {
    try {
      final hotel = await Hotel.fetchHotelDetails(widget.room.hotelId);
      if (hotel != null) {
        setState(() {
          _hotelName = hotel.name;
        });
        debugPrint(
            'ManageRoomPage: _ManageRoomListItem: Fetched hotel name "${hotel.name}" for room ID: ${widget.room.id}');
      } else {
        setState(() {
          _hotelName = 'Unknown Hotel';
        });
        debugPrint(
            'ManageRoomPage: _ManageRoomListItem: Hotel not found for hotelId: ${widget.room.hotelId} for room ID: ${widget.room.id}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hotelName = 'Error';
      });
      debugPrint(
          'ManageRoomPage: _ManageRoomListItem: Error fetching hotel name for room ID ${widget.room.id}: $e');
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
                  image: _roomImageBytes != null
                      ? MemoryImage(_roomImageBytes!) as ImageProvider
                      : const AssetImage("assets/images/room.png"),
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
                    widget.room.type,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('Hotel: $_hotelName',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Price: \$${widget.room.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Guest Capacity: ${widget.room.guestCount ?? '-'}',
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
                  tooltip: 'Edit Room',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete Room',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
