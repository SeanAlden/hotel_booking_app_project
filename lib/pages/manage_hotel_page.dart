// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/pages/add_hotel_page.dart';

// class ManageHotelPage extends StatelessWidget {
//   const ManageHotelPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Hotel'),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 50), // beri ruang untuk tombol
//             child: const Center(
//               child: Text(
//                 'No hotels added yet.',
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
//                     MaterialPageRoute(builder: (context) => AddHotelPage()),
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
//                 child: const Text('Add Hotel'),
//               )),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:typed_data'; // For Uint8List
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/location.dart'; // To fetch location name
// import 'package:hotel_booking_app/pages/add_hotel_page.dart';
// import 'package:hotel_booking_app/pages/edit_hotel_page.dart'; // Import the new EditHotelPage
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// class ManageHotelPage extends StatefulWidget {
//   const ManageHotelPage({Key? key}) : super(key: key);

//   @override
//   State<ManageHotelPage> createState() => _ManageHotelPageState();
// }

// class _ManageHotelPageState extends State<ManageHotelPage> {
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
//       debugPrint('Search query changed to: $_searchQuery');
//     });
//   }

//   Future<void> _deleteHotel(String hotelId) async {
//     // Show confirmation dialog
//     bool confirmDelete = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Hotel'),
//         content: const Text('Are you sure you want to delete this hotel? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false), // No
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true), // Yes
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     ) ?? false; // Default to false if dialog is dismissed

//     if (confirmDelete) {
//       try {
//         // Delete hotel document from Firestore
//         await FirebaseFirestore.instance.collection('hotels').doc(hotelId).delete();
//         debugPrint('Hotel ID $hotelId deleted from Firestore.');

//         // Delete associated image from Hive
//         final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//         await hotelImagesBox.delete(hotelId);
//         debugPrint('Image for hotel ID $hotelId deleted from Hive.');

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Hotel deleted successfully!')),
//         );
//       } catch (e) {
//         debugPrint('Error deleting hotel $hotelId: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete hotel: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Hotels', style: TextStyle(color: Colors.white)),
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
//                 hintText: 'Search hotels by name...',
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
//               stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   debugPrint('ManageHotelPage: StreamBuilder Error: ${snapshot.error}');
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No hotels added yet.'));
//                 }

//                 final allHotels = snapshot.data!.docs;
//                 final filteredHotels = allHotels.where((hotelDoc) {
//                   final hotelName = (hotelDoc.data() as Map<String, dynamic>)['name']?.toLowerCase() ?? '';
//                   return hotelName.contains(_searchQuery);
//                 }).toList();

//                 if (filteredHotels.isEmpty && _searchQuery.isNotEmpty) {
//                   return Center(child: Text('No hotels found matching "${_searchQuery}"'));
//                 } else if (filteredHotels.isEmpty) {
//                   return const Center(child: Text('No hotels added yet.'));
//                 }
//                 debugPrint('ManageHotelPage: Displaying ${filteredHotels.length} hotels.');

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: filteredHotels.length,
//                   itemBuilder: (context, index) {
//                     final hotelDoc = filteredHotels[index];
//                     final hotel = Hotel.fromFirestore(hotelDoc); // Convert to Hotel model

//                     return _ManageHotelListItem(
//                       hotel: hotel,
//                       onEdit: () async {
//                         debugPrint('Navigating to EditHotelPage for ID: ${hotel.id}');
//                         final result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EditHotelPage(hotelId: hotel.id),
//                           ),
//                         );
//                         // Optional: Refresh data if needed after editing (StreamBuilder handles this automatically)
//                         if (result == true) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Hotel data refreshed!')),
//                           );
//                         }
//                       },
//                       onDelete: () => _deleteHotel(hotel.id),
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
//             MaterialPageRoute(builder: (context) => const AddHotelPage()),
//           );
//         },
//         label: const Text('Add Hotel'),
//         icon: const Icon(Icons.add),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }

// // Helper Widget for individual hotel list item
// class _ManageHotelListItem extends StatefulWidget {
//   final Hotel hotel;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _ManageHotelListItem({
//     Key? key,
//     required this.hotel,
//     required this.onEdit,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   State<_ManageHotelListItem> createState() => _ManageHotelListItemState();
// }

// class _ManageHotelListItemState extends State<_ManageHotelListItem> {
//   Uint8List? _hotelImageBytes;

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _ManageHotelListItem oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.hotel.id != oldWidget.hotel.id) {
//       debugPrint('ManageHotelPage: _ManageHotelListItem: Hotel ID changed from ${oldWidget.hotel.id} to ${widget.hotel.id}, reloading image.');
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     try {
//       final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//       final Uint8List? imageBytes = hotelImagesBox.get(widget.hotel.id);

//       debugPrint('ManageHotelPage: _ManageHotelListItem: Attempting to load image for hotel ID: ${widget.hotel.id} from Hive.');

//       if (imageBytes != null) {
//         setState(() {
//           _hotelImageBytes = imageBytes;
//         });
//         debugPrint('ManageHotelPage: _ManageHotelListItem: Image found and loaded for hotel ID: ${widget.hotel.id}. Size: ${imageBytes.lengthInBytes} bytes.');
//       } else {
//         setState(() {
//           _hotelImageBytes = null;
//         });
//         debugPrint('ManageHotelPage: _ManageHotelListItem: Image not found for hotel ID: ${widget.hotel.id} in Hive. Showing default.');
//       }
//     } catch (e) {
//       debugPrint('ManageHotelPage: _ManageHotelListItem: Error loading image from Hive for ID ${widget.hotel.id}: $e');
//       setState(() {
//         _hotelImageBytes = null;
//       });
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
//             // Hotel Image
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: _hotelImageBytes != null
//                       ? MemoryImage(_hotelImageBytes!) as ImageProvider
//                       : const AssetImage("assets/images/hotel.png"), // Default image
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Hotel Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.hotel.name,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   FutureBuilder<String>(
//                     future: Location.fetchLocationName(widget.hotel.locationId),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Text('Loading location...');
//                       } else if (snapshot.hasError) {
//                         return const Text('Error location');
//                       } else {
//                         return Text('Location: ${snapshot.data ?? 'Unknown'}',
//                             style: const TextStyle(fontSize: 14, color: Colors.grey));
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 4),
//                   Text('Rating: ${widget.hotel.rating.toStringAsFixed(1)} / 5.0',
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
//                   tooltip: 'Edit Hotel',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: widget.onDelete,
//                   tooltip: 'Delete Hotel',
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
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart'; // To fetch location name
import 'package:hotel_booking_app/pages/add_hotel_page.dart';
import 'package:hotel_booking_app/pages/edit_hotel_page.dart'; // Import the new EditHotelPage
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

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
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hotel'),
        content: const Text('Are you sure you want to delete this hotel? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // No
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Yes
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false; // Default to false if dialog is dismissed

    if (confirmDelete) {
      try {
        // Delete hotel document from Firestore
        await FirebaseFirestore.instance.collection('hotels').doc(hotelId).delete();
        debugPrint('Hotel ID $hotelId deleted from Firestore.');

        // Delete associated image from Hive
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
        title: const Text('Manage Hotels', style: TextStyle(color: Colors.white)),
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
              stream: FirebaseFirestore.instance.collection('hotels').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('ManageHotelPage: StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hotels added yet.'));
                }

                final allHotels = snapshot.data!.docs;
                final filteredHotels = allHotels.where((hotelDoc) {
                  final hotelName = (hotelDoc.data() as Map<String, dynamic>)['name']?.toLowerCase() ?? '';
                  return hotelName.contains(_searchQuery);
                }).toList();

                if (filteredHotels.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(child: Text('No hotels found matching "${_searchQuery}"'));
                } else if (filteredHotels.isEmpty) {
                  return const Center(child: Text('No hotels added yet.'));
                }
                debugPrint('ManageHotelPage: Displaying ${filteredHotels.length} hotels.');

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredHotels.length,
                  itemBuilder: (context, index) {
                    final hotelDoc = filteredHotels[index];
                    final hotel = Hotel.fromFirestore(hotelDoc); // Convert to Hotel model

                    return _ManageHotelListItem(
                      key: ValueKey(hotel.id), // IMPORTANT: Add a ValueKey here!
                      hotel: hotel,
                      onEdit: () async {
                        debugPrint('Navigating to EditHotelPage for ID: ${hotel.id}');
                        // Await the navigation result
                        final bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditHotelPage(hotelId: hotel.id),
                          ),
                        );
                        // If result is true, it means an update occurred, so force rebuild
                        if (result == true) {
                          // Trigger a rebuild of this entire ManageHotelPage
                          // This will cause the StreamBuilder to re-evaluate and thus
                          // rebuild all _ManageHotelListItem widgets, reloading images.
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hotel data updated and refreshed!')),
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
        onPressed: () async { // Make onPressed async
          final bool? result = await Navigator.push( // Await the navigation result
            context,
            MaterialPageRoute(builder: (context) => const AddHotelPage()),
          );
          if (result == true) {
            // Trigger a rebuild of this entire ManageHotelPage
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New hotel added and list refreshed!')),
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

// Helper Widget for individual hotel list item
class _ManageHotelListItem extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageHotelListItem({
    Key? key, // Key is now explicitly required for ValueKey
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
    // This check is still good to ensure image reloads if the underlying hotel object changes
    // (e.g., if Firestore replaces the whole document on update, or if list order changes)
    if (widget.hotel.id != oldWidget.hotel.id) {
      debugPrint('ManageHotelPage: _ManageHotelListItem: Hotel ID changed from ${oldWidget.hotel.id} to ${widget.hotel.id}, reloading image.');
      _loadHotelImage();
    }
  }

  Future<void> _loadHotelImage() async {
    try {
      final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
      final Uint8List? imageBytes = hotelImagesBox.get(widget.hotel.id);

      debugPrint('ManageHotelPage: _ManageHotelListItem: Attempting to load image for hotel ID: ${widget.hotel.id} from Hive.');

      if (imageBytes != null) {
        setState(() {
          _hotelImageBytes = imageBytes;
        });
        debugPrint('ManageHotelPage: _ManageHotelListItem: Image found and loaded for hotel ID: ${widget.hotel.id}. Size: ${imageBytes.lengthInBytes} bytes.');
      } else {
        setState(() {
          _hotelImageBytes = null;
        });
        debugPrint('ManageHotelPage: _ManageHotelListItem: Image not found for hotel ID: ${widget.hotel.id} in Hive. Showing default.');
      }
    } catch (e) {
      debugPrint('ManageHotelPage: _ManageHotelListItem: Error loading image from Hive for ID ${widget.hotel.id}: $e');
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
            // Hotel Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: _hotelImageBytes != null
                      ? MemoryImage(_hotelImageBytes!) as ImageProvider
                      : const AssetImage("assets/images/hotel.png"), // Default image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Hotel Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                            style: const TextStyle(fontSize: 14, color: Colors.grey));
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  Text('Rating: ${widget.hotel.rating.toStringAsFixed(1)} / 5.0',
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

