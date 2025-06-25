// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/pages/add_room_page.dart';
// import 'add_location_page.dart';

// class ManageRoomPage extends StatelessWidget {
//   const ManageRoomPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Room'),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 50), // beri ruang untuk tombol
//             child: const Center(
//               child: Text(
//                 'No rooms added yet.',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//           Positioned(
//               top: 16,
//               right: 16,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => AddRoomPage()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent, // Warna latar tombol
//                   foregroundColor: Colors.white, // Warna teks
//                   elevation: 5, // Efek bayangan
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12), // Sudut melengkung
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 child: const Text('Add Room'),
//               )),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:typed_data'; // For Uint8List
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/room.dart'; // Import Room model
// import 'package:hotel_booking_app/model/hotel.dart'; // Import Hotel model (to get hotel name)
// import 'package:hotel_booking_app/pages/add_room_page.dart';
// import 'package:hotel_booking_app/pages/edit_room_page.dart'; // Import the new EditRoomPage
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// class ManageRoomPage extends StatefulWidget {
//   const ManageRoomPage({Key? key}) : super(key: key);

//   @override
//   State<ManageRoomPage> createState() => _ManageRoomPageState();
// }

// class _ManageRoomPageState extends State<ManageRoomPage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase();
//       debugPrint('ManageRoomPage: Search query changed to: $_searchQuery');
//     });
//   }

//   Future<void> _deleteRoom(String roomId) async {
//     // Show confirmation dialog
//     bool confirmDelete = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Delete Room'),
//             content: const Text(
//                 'Are you sure you want to delete this room? This action cannot be undone.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false), // No
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true), // Yes
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child:
//                     const Text('Delete', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ) ??
//         false; // Default to false if dialog is dismissed

//     if (confirmDelete) {
//       try {
//         // Delete room document from Firestore
//         await FirebaseFirestore.instance
//             .collection('rooms')
//             .doc(roomId)
//             .delete();
//         debugPrint('ManageRoomPage: Room ID $roomId deleted from Firestore.');

//         // Delete associated image from Hive
//         final roomImagesBox = Hive.box<Uint8List>('room_images');
//         await roomImagesBox.delete(roomId);
//         debugPrint(
//             'ManageRoomPage: Image for room ID $roomId deleted from Hive.');

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Room deleted successfully!')),
//         );
//       } catch (e) {
//         debugPrint('ManageRoomPage: Error deleting room $roomId: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete room: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             const Text('Manage Rooms', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search rooms by type...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance.collection('rooms').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   debugPrint(
//                       'ManageRoomPage: StreamBuilder Error: ${snapshot.error}');
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No rooms added yet.'));
//                 }

//                 final allRooms = snapshot.data!.docs;
//                 final filteredRooms = allRooms.where((roomDoc) {
//                   final roomType =
//                       (roomDoc.data() as Map<String, dynamic>)['type']
//                               ?.toLowerCase() ??
//                           '';
//                   return roomType.contains(_searchQuery);
//                 }).toList();

//                 if (filteredRooms.isEmpty && _searchQuery.isNotEmpty) {
//                   return Center(
//                       child: Text('No rooms found matching "${_searchQuery}"'));
//                 } else if (filteredRooms.isEmpty) {
//                   return const Center(child: Text('No rooms added yet.'));
//                 }
//                 debugPrint(
//                     'ManageRoomPage: Displaying ${filteredRooms.length} rooms.');

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: filteredRooms.length,
//                   itemBuilder: (context, index) {
//                     final roomDoc = filteredRooms[index];
//                     final room =
//                         Room.fromFirestore(roomDoc); // Convert to Room model

//                     return _ManageRoomListItem(
//                       room: room,
//                       onEdit: () async {
//                         debugPrint(
//                             'Navigating to EditRoomPage for ID: ${room.id}');
//                         final result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EditRoomPage(roomId: room.id),
//                           ),
//                         );
//                         // Optional: Refresh data if needed after editing (StreamBuilder handles this automatically)
//                         if (result == true) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Room data refreshed!')),
//                           );
//                         }
//                       },
//                       onDelete: () => _deleteRoom(room.id),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddRoomPage()),
//           );
//         },
//         label: const Text('Add Room'),
//         icon: const Icon(Icons.add),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }

// // Helper Widget for individual room list item
// class _ManageRoomListItem extends StatefulWidget {
//   final Room room;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _ManageRoomListItem({
//     Key? key,
//     required this.room,
//     required this.onEdit,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   State<_ManageRoomListItem> createState() => _ManageRoomListItemState();
// }

// class _ManageRoomListItemState extends State<_ManageRoomListItem> {
//   Uint8List? _roomImageBytes;
//   String _hotelName = 'Loading...'; // To display associated hotel name

//   @override
//   void initState() {
//     super.initState();
//     _loadRoomImage();
//     _fetchHotelName();
//   }

//   @override
//   void didUpdateWidget(covariant _ManageRoomListItem oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.room.id != oldWidget.room.id) {
//       debugPrint(
//           'ManageRoomPage: _ManageRoomListItem: Room ID changed from ${oldWidget.room.id} to ${widget.room.id}, reloading image and hotel name.');
//       _loadRoomImage();
//       _fetchHotelName();
//     }
//   }

//   Future<void> _loadRoomImage() async {
//     try {
//       final roomImagesBox = Hive.box<Uint8List>('room_images');
//       final Uint8List? imageBytes = roomImagesBox.get(widget.room.id);

//       debugPrint(
//           'ManageRoomPage: _ManageRoomListItem: Attempting to load image for room ID: ${widget.room.id} from Hive.');

//       if (imageBytes != null) {
//         setState(() {
//           _roomImageBytes = imageBytes;
//         });
//         debugPrint(
//             'ManageRoomPage: _ManageRoomListItem: Image found and loaded for room ID: ${widget.room.id}. Size: ${imageBytes.lengthInBytes} bytes.');
//       } else {
//         setState(() {
//           _roomImageBytes = null;
//         });
//         debugPrint(
//             'ManageRoomPage: _ManageRoomListItem: Image not found for room ID: ${widget.room.id} in Hive. Showing default.');
//       }
//     } catch (e) {
//       debugPrint(
//           'ManageRoomPage: _ManageRoomListItem: Error loading image from Hive for ID ${widget.room.id}: $e');
//       setState(() {
//         _roomImageBytes = null;
//       });
//     }
//   }

//   Future<void> _fetchHotelName() async {
//     try {
//       final hotel = await Hotel.fetchHotelDetails(widget.room.hotelId);
//       if (hotel != null) {
//         setState(() {
//           _hotelName = hotel.name;
//         });
//         debugPrint(
//             'ManageRoomPage: _ManageRoomListItem: Fetched hotel name "${hotel.name}" for room ID: ${widget.room.id}');
//       } else {
//         setState(() {
//           _hotelName = 'Unknown Hotel';
//         });
//         debugPrint(
//             'ManageRoomPage: _ManageRoomListItem: Hotel not found for hotelId: ${widget.room.hotelId} for room ID: ${widget.room.id}');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _hotelName = 'Error';
//       });
//       debugPrint(
//           'ManageRoomPage: _ManageRoomListItem: Error fetching hotel name for room ID ${widget.room.id}: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           children: [
//             // Room Image
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: _roomImageBytes != null
//                       ? MemoryImage(_roomImageBytes!) as ImageProvider
//                       : const AssetImage(
//                           "assets/images/room.png"), // Default room image
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Room Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.room.type,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 18),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text('Hotel: $_hotelName',
//                       style: const TextStyle(fontSize: 14, color: Colors.grey)),
//                   const SizedBox(height: 4),
//                   Text('Price: \$${widget.room.price.toStringAsFixed(2)}',
//                       style: const TextStyle(fontSize: 14)),
//                   const SizedBox(height: 4),
//                   Text(
//                       'Guests: ${widget.room.guestCount ?? '-'}', // Display guestCount
//                       style: const TextStyle(fontSize: 14)),
//                 ],
//               ),
//             ),
//             // Action Buttons
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: widget.onEdit,
//                   tooltip: 'Edit Room',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: widget.onDelete,
//                   tooltip: 'Delete Room',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/room.dart'; // Import Room model
import 'package:hotel_booking_app/model/hotel.dart'; // Import Hotel model (to get hotel name)
import 'package:hotel_booking_app/pages/add_room_page.dart';
import 'package:hotel_booking_app/pages/edit_room_page.dart'; // Import the new EditRoomPage
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

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
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Room'),
            content: const Text(
                'Are you sure you want to delete this room? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // No
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Yes
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed

    if (confirmDelete) {
      try {
        // Delete room document from Firestore
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .delete();
        debugPrint('ManageRoomPage: Room ID $roomId deleted from Firestore.');

        // Delete associated image from Hive
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
                    final room =
                        Room.fromFirestore(roomDoc); // Convert to Room model

                    return _ManageRoomListItem(
                      key: ValueKey(room.id), // IMPORTANT: Add a ValueKey here!
                      room: room,
                      onEdit: () async {
                        debugPrint(
                            'Navigating to EditRoomPage for ID: ${room.id}');
                        // Await the navigation result
                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRoomPage(roomId: room.id),
                          ),
                        );
                        // If result is true, it means an update occurred, so force rebuild
                        if (result == true) {
                          // Trigger a rebuild of this entire ManageRoomPage
                          // This will cause the StreamBuilder to re-evaluate and thus
                          // rebuild all _ManageRoomListItem widgets, reloading images.
                          // setState(() {});
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //       content:
                          //           Text('Room data updated and refreshed!')),
                          // );

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
          // Make onPressed async
          final bool? result = await Navigator.push(
            // Await the navigation result
            context,
            MaterialPageRoute(builder: (context) => const AddRoomPage()),
          );
          if (result == true) {
            // Trigger a rebuild of this entire ManageRoomPage
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

// Helper Widget for individual room list item
class _ManageRoomListItem extends StatefulWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageRoomListItem({
    Key? key, // Key is now explicitly required for ValueKey
    required this.room,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_ManageRoomListItem> createState() => _ManageRoomListItemState();
}

class _ManageRoomListItemState extends State<_ManageRoomListItem> {
  Uint8List? _roomImageBytes;
  String _hotelName = 'Loading...'; // To display associated hotel name

  @override
  void initState() {
    super.initState();
    _loadRoomImage();
    _fetchHotelName();
  }

  @override
  void didUpdateWidget(covariant _ManageRoomListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This check is still good to ensure image reloads if the underlying room object changes
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
            // Room Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: _roomImageBytes != null
                      ? MemoryImage(_roomImageBytes!) as ImageProvider
                      : const AssetImage(
                          "assets/images/room.png"), // Default room image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Room Details
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
                  Text(
                      'Guest Capacity: ${widget.room.guestCount ?? '-'}', // Display guestCount
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            // Action Buttons
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
