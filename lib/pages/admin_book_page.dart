// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/room.dart'; // Contains the Booking model
// import 'package:hotel_booking_app/model/user.dart'; // For AppUser model and fetchUserById
// import 'package:intl/intl.dart'; // For date formatting

// class AdminBookPage extends StatefulWidget {
//   const AdminBookPage({Key? key}) : super(key: key);

//   @override
//   State<AdminBookPage> createState() => _AdminBookPageState();
// }

// class _AdminBookPageState extends State<AdminBookPage> {
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
//       debugPrint('AdminBookPage: Search query changed to: $_searchQuery');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('All Bookings', style: TextStyle(color: Colors.white)),
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
//                 hintText: 'Search by hotel, room type, or user email...',
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
//               stream: FirebaseFirestore.instance
//                   .collection('book_history')
//                   .orderBy('created_at', descending: true) // Order by latest booking
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   debugPrint('AdminBookPage: StreamBuilder Error: ${snapshot.error}');
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No bookings found yet.'));
//                 }

//                 final allBookings = snapshot.data!.docs;
//                 final filteredBookings = allBookings.where((bookingDoc) {
//                   final booking = Booking.fromFirestore(bookingDoc);
//                   final hotelName = booking.hotelName.toLowerCase();
//                   final roomSummary = booking.roomSummary.toLowerCase();
//                   final userId = booking.userId.toLowerCase(); // For potential future filtering by UID

//                   // If _searchQuery is empty, all bookings pass the filter
//                   if (_searchQuery.isEmpty) return true;

//                   // Basic filtering logic
//                   return hotelName.contains(_searchQuery) ||
//                          roomSummary.contains(_searchQuery) ||
//                          userId.contains(_searchQuery); // Can add user email/name if fetched
//                 }).toList();

//                 if (filteredBookings.isEmpty && _searchQuery.isNotEmpty) {
//                   return Center(child: Text('No bookings found matching "${_searchQuery}"'));
//                 } else if (filteredBookings.isEmpty) {
//                   return const Center(child: Text('No bookings found yet.'));
//                 }
//                 debugPrint('AdminBookPage: Displaying ${filteredBookings.length} filtered bookings.');

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: filteredBookings.length,
//                   itemBuilder: (context, index) {
//                     final bookingDoc = filteredBookings[index];
//                     final booking = Booking.fromFirestore(bookingDoc);
//                     return _AdminBookListItem(booking: booking);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper Widget for individual booking list item
// class _AdminBookListItem extends StatelessWidget {
//   final Booking booking;

//   const _AdminBookListItem({
//     Key? key,
//     required this.booking,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.hotel, color: Colors.blue, size: 24),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     booking.hotelName,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'ID: ${booking.bookingId.substring(0, 6)}...', // Show shortened booking ID
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//             const Divider(height: 16),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(Icons.meeting_room, color: Colors.green, size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Room Type: ${booking.roomSummary}',
//                         style: const TextStyle(fontSize: 15),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Dates: ${DateFormat('MMM dd, yyyy').format(booking.startDate)} - ${DateFormat('MMM dd, yyyy').format(booking.endDate)}',
//                         style: const TextStyle(fontSize: 13, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Total Price: \$${booking.totalPrice.toStringAsFixed(2)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepOrange),
//                       ),
//                       const SizedBox(height: 4),
//                       // Display user details using FutureBuilder
//                       FutureBuilder<AppUser?>(
//                         future: AppUser.fetchUserById(booking.userId),
//                         builder: (context, userSnapshot) {
//                           if (userSnapshot.connectionState == ConnectionState.waiting) {
//                             return const Text('Booked by: Loading user...', style: TextStyle(fontSize: 13, color: Colors.grey));
//                           } else if (userSnapshot.hasError) {
//                             return const Text('Booked by: Error fetching user', style: TextStyle(fontSize: 13, color: Colors.red));
//                           } else if (userSnapshot.hasData && userSnapshot.data != null) {
//                             return Text('Booked by: ${userSnapshot.data!.name} (${userSnapshot.data!.email})',
//                                 style: const TextStyle(fontSize: 13, color: Colors.black87));
//                           } else {
//                             return Text('Booked by: Unknown User (ID: ${booking.userId})',
//                                 style: const TextStyle(fontSize: 13, color: Colors.grey));
//                           }
//                         },
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Booked On: ${DateFormat('MMM dd, yyyy HH:mm').format(booking.createdAt)}',
//                         style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/room.dart'; // Contains the Booking model
// import 'package:hotel_booking_app/model/user.dart'; // For AppUser model and fetchUserById
// import 'package:intl/intl.dart'; // For date formatting
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive for image access
// import 'dart:typed_data'; // For Uint8List

// class AdminBookPage extends StatefulWidget {
//   const AdminBookPage({Key? key}) : super(key: key);

//   @override
//   State<AdminBookPage> createState() => _AdminBookPageState();
// }

// class _AdminBookPageState extends State<AdminBookPage> {
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
//       debugPrint('AdminBookPage: Search query changed to: $_searchQuery');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('All Bookings', style: TextStyle(color: Colors.white)),
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
//                 hintText: 'Cari berdasarkan hotel, tipe kamar, atau email pengguna...', // Updated hint text
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
//               stream: FirebaseFirestore.instance
//                   .collection('book_history')
//                   .orderBy('created_at', descending: true) // Order by latest booking
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   debugPrint('AdminBookPage: StreamBuilder Error: ${snapshot.error}');
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('Belum ada booking ditemukan.')); // Updated text
//                 }

//                 final allBookings = snapshot.data!.docs;
//                 final filteredBookings = allBookings.where((bookingDoc) {
//                   final booking = Booking.fromFirestore(bookingDoc);
//                   final hotelName = booking.hotelName.toLowerCase();
//                   final roomSummary = booking.roomSummary.toLowerCase();
//                   final userId = booking.userId.toLowerCase(); // For potential future filtering by UID

//                   // For better search, we can fetch user email/name here if needed
//                   // but for simplicity, the current model for `_UserListItem` handles it.
//                   // For a real-time search on user email/name, you'd need to pre-fetch user data or
//                   // use a more complex Firestore query with additional collections (not simple here).

//                   // If _searchQuery is empty, all bookings pass the filter
//                   if (_searchQuery.isEmpty) return true;

//                   // Basic filtering logic: search in hotel name, room type, or user ID (if email/name search needed, fetch them first)
//                   return hotelName.contains(_searchQuery) ||
//                          roomSummary.contains(_searchQuery) ||
//                          userId.contains(_searchQuery);
//                 }).toList();

//                 if (filteredBookings.isEmpty && _searchQuery.isNotEmpty) {
//                   return Center(child: Text('Tidak ada booking yang cocok dengan "${_searchQuery}"')); // Updated text
//                 } else if (filteredBookings.isEmpty) {
//                   return const Center(child: Text('Belum ada booking ditemukan.')); // Updated text
//                 }
//                 debugPrint('AdminBookPage: Menampilkan ${filteredBookings.length} booking yang difilter.'); // Updated text

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: filteredBookings.length,
//                   itemBuilder: (context, index) {
//                     final bookingDoc = filteredBookings[index];
//                     final booking = Booking.fromFirestore(bookingDoc);
//                     return _AdminBookListItem(booking: booking);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper Widget for individual booking list item
// class _AdminBookListItem extends StatefulWidget {
//   final Booking booking;

//   const _AdminBookListItem({
//     Key? key,
//     required this.booking,
//   }) : super(key: key);

//   @override
//   State<_AdminBookListItem> createState() => _AdminBookListItemState();
// }

// class _AdminBookListItemState extends State<_AdminBookListItem> {
//   Uint8List? _hotelImageBytes;
//   Uint8List? _roomImageBytes;
//   String _userName = 'Memuat...';
//   String _userEmail = 'Memuat...';

//   @override
//   void initState() {
//     super.initState();
//     _loadImages();
//     _fetchUserDetails();
//   }

//   @override
//   void didUpdateWidget(covariant _AdminBookListItem oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Reload images and user details if the booking ID changes (meaning a different booking is now displayed)
//     if (widget.booking.id != oldWidget.booking.id) {
//       debugPrint('AdminBookPage: _AdminBookListItem: Booking ID changed, reloading images and user details.');
//       _loadImages();
//       _fetchUserDetails();
//     }
//   }

//   Future<void> _loadImages() async {
//     try {
//       final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//       final roomImagesBox = Hive.box<Uint8List>('room_images');

//       final Uint8List? hotelBytes = hotelImagesBox.get(widget.booking.hotelId);
//       final Uint8List? roomBytes = roomImagesBox.get(widget.booking.roomId);

//       setState(() {
//         _hotelImageBytes = hotelBytes;
//         _roomImageBytes = roomBytes;
//       });
//       debugPrint('AdminBookPage: _AdminBookListItem: Images loaded for booking ${widget.booking.id}. Hotel image: ${hotelBytes != null}, Room image: ${roomBytes != null}');
//     } catch (e) {
//       debugPrint('AdminBookPage: _AdminBookListItem: Error loading images for booking ${widget.booking.id}: $e');
//       setState(() {
//         _hotelImageBytes = null;
//         _roomImageBytes = null;
//       });
//     }
//   }

//   Future<void> _fetchUserDetails() async {
//     try {
//       final user = await AppUser.fetchUserById(widget.booking.userId);
//       if (user != null) {
//         setState(() {
//           _userName = user.name;
//           _userEmail = user.email;
//         });
//         debugPrint('AdminBookPage: _AdminBookListItem: Fetched user details for booking ${widget.booking.id}: ${user.name} (${user.email})');
//       } else {
//         setState(() {
//           _userName = 'Pengguna Tidak Dikenal';
//           _userEmail = 'ID: ${widget.booking.userId}';
//         });
//         debugPrint('AdminBookPage: _AdminBookListItem: User not found for booking ${widget.booking.id} (ID: ${widget.booking.userId})');
//       }
//     } catch (e) {
//       debugPrint('AdminBookPage: _AdminBookListItem: Error fetching user details for booking ${widget.booking.id}: $e');
//       setState(() {
//         _userName = 'Error Memuat Pengguna';
//         _userEmail = '';
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
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start, // Align top for images
//               children: [
//                 // Hotel Image
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     image: DecorationImage(
//                       image: _hotelImageBytes != null
//                           ? MemoryImage(_hotelImageBytes!) as ImageProvider
//                           : const AssetImage("assets/images/hotel.png"), // Default image
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Room Image
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     image: DecorationImage(
//                       image: _roomImageBytes != null
//                           ? MemoryImage(_roomImageBytes!) as ImageProvider
//                           : const AssetImage("assets/images/room.png"), // Default room image
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         booking.hotelName,
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Tipe Kamar: ${booking.roomSummary}',
//                         style: const TextStyle(fontSize: 15, color: Colors.grey),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'ID Booking: ${booking.bookingId.substring(0, 6)}...', // Show shortened booking ID
//                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.date_range, color: Colors.blueGrey, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Tanggal: ${DateFormat('MMM dd, yyyy').format(booking.startDate)} - ${DateFormat('MMM dd, yyyy').format(booking.endDate)}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(Icons.people, color: Colors.blueGrey, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Jumlah Tamu: ${booking.guestCount}', // Make sure guestCount is properly stored in Booking model
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(Icons.attach_money, color: Colors.green, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Total Harga: \$${booking.totalPrice.toStringAsFixed(2)}',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(Icons.person, color: Colors.purple, size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Dipesan oleh: $_userName ($_userEmail)',
//                         style: const TextStyle(fontSize: 13, color: Colors.black87),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(Icons.access_time, color: Colors.blueGrey, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Dipesan pada: ${DateFormat('MMM dd, yyyy HH:mm').format(booking.createdAt)}',
//                       style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/room.dart'; // Contains the Booking model
import 'package:hotel_booking_app/model/user.dart'; // For AppUser model and fetchUserById
import 'package:intl/intl.dart'; // For date formatting
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive for image access
import 'dart:typed_data'; // For Uint8List

class AdminBookPage extends StatefulWidget {
  const AdminBookPage({Key? key}) : super(key: key);

  @override
  State<AdminBookPage> createState() => _AdminBookPageState();
}

class _AdminBookPageState extends State<AdminBookPage> {
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
      debugPrint('AdminBookPage: Search query changed to: $_searchQuery');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bookings',
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
                hintText:
                    'Cari berdasarkan hotel, tipe kamar, atau email pengguna...',
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
              stream: FirebaseFirestore.instance
                  .collection('book_history')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint(
                      'AdminBookPage: StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Belum ada booking ditemukan.'));
                }

                final allBookings = snapshot.data!.docs;
                final filteredBookings = allBookings.where((bookingDoc) {
                  final booking = Booking.fromFirestore(bookingDoc);
                  final hotelName = booking.hotelName.toLowerCase();
                  final roomSummary = booking.roomSummary.toLowerCase();
                  // For searching by user email/name, you would need to fetch user data
                  // or store user email/name in the booking history itself.
                  // For now, we'll only search on pre-existing fields in booking.
                  // final userName = _fetchedUserNameForBooking(booking.userId).toLowerCase(); // Example if you pre-fetched
                  // final userEmail = _fetchedUserEmailForBooking(booking.userId).toLowerCase(); // Example if you pre-fetched

                  if (_searchQuery.isEmpty) return true;

                  // Perform search on relevant fields
                  return hotelName.contains(_searchQuery) ||
                      roomSummary.contains(_searchQuery);
                  // || userName.contains(_searchQuery) || userEmail.contains(_searchQuery);
                }).toList();

                if (filteredBookings.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                      child: Text(
                          'Tidak ada booking yang cocok dengan "${_searchQuery}"'));
                } else if (filteredBookings.isEmpty) {
                  return const Center(
                      child: Text('Belum ada booking ditemukan.'));
                }
                debugPrint(
                    'AdminBookPage: Menampilkan ${filteredBookings.length} booking yang difilter.');

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final bookingDoc = filteredBookings[index];
                    final booking = Booking.fromFirestore(bookingDoc);
                    return _AdminBookListItem(
                      key: ValueKey(booking
                          .id), // Add ValueKey for efficient list updates
                      booking: booking,
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

// Helper Widget for individual booking list item
class _AdminBookListItem extends StatefulWidget {
  final Booking booking;

  const _AdminBookListItem({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<_AdminBookListItem> createState() => _AdminBookListItemState();
}

class _AdminBookListItemState extends State<_AdminBookListItem> {
  Uint8List? _hotelImageBytes;
  Uint8List? _roomImageBytes;
  String _userName = 'Memuat...';
  String _userEmail = 'Memuat...';

  @override
  void initState() {
    super.initState();
    debugPrint(
        '[_AdminBookListItemState] InitState for booking ID: ${widget.booking.id}');
    _loadImages();
    _fetchUserDetails();
  }

  @override
  void didUpdateWidget(covariant _AdminBookListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.booking.id != oldWidget.booking.id) {
      debugPrint(
          '[_AdminBookListItemState] didUpdateWidget: Booking ID changed from ${oldWidget.booking.id} to ${widget.booking.id}, reloading images and user details.');
      _loadImages();
      _fetchUserDetails();
    }
  }

  Future<void> _loadImages() async {
    try {
      final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
      final roomImagesBox = Hive.box<Uint8List>('room_images');

      final Uint8List? hotelBytes = hotelImagesBox.get(widget.booking.hotelId);
      final Uint8List? roomBytes = roomImagesBox.get(widget.booking.roomId);

      setState(() {
        _hotelImageBytes = hotelBytes;
        _roomImageBytes = roomBytes;
      });
      debugPrint(
          '[_AdminBookListItemState] Images loaded for booking ${widget.booking.id}. Hotel image: ${hotelBytes != null ? 'Yes' : 'No'}, Room image: ${roomBytes != null ? 'Yes' : 'No'}');
    } catch (e) {
      debugPrint(
          '[_AdminBookListItemState] Error loading images for booking ${widget.booking.id}: $e');
      setState(() {
        _hotelImageBytes = null;
        _roomImageBytes = null;
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = await AppUser.fetchUserById(widget.booking.userId);
      if (user != null) {
        setState(() {
          _userName = user.name;
          _userEmail = user.email;
        });
        debugPrint(
            '[_AdminBookListItemState] Fetched user details for booking ${widget.booking.id}: ${user.name} (${user.email})');
      } else {
        setState(() {
          _userName = 'Pengguna Tidak Dikenal';
          _userEmail = 'ID: ${widget.booking.userId}';
        });
        debugPrint(
            '[_AdminBookListItemState] User not found for booking ${widget.booking.id} (ID: ${widget.booking.userId})');
      }
    } catch (e) {
      debugPrint(
          '[_AdminBookListItemState] Error fetching user details for booking ${widget.booking.id}: $e');
      if (!mounted) return;
      setState(() {
        _userName = 'Error Memuat Pengguna';
        _userEmail = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Card(
    //   margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   child: Padding(
    //     padding: const EdgeInsets.all(12.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
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
    //                       : const AssetImage(
    //                           "assets/images/hotel.png"), // Default image
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //             ),
    //             const SizedBox(width: 12),
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
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     widget.booking.hotelName, // Access via widget.booking
    //                     style: const TextStyle(
    //                         fontWeight: FontWeight.bold, fontSize: 18),
    //                     maxLines: 2,
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //                   const SizedBox(height: 4),
    //                   Text(
    //                     'Tipe Kamar: ${widget.booking.roomSummary}', // Access via widget.booking
    //                     style:
    //                         const TextStyle(fontSize: 15, color: Colors.grey),
    //                     maxLines: 1,
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //                   const SizedBox(height: 4),
    //                   Text(
    //                     'ID Booking: ${widget.booking.bookingId.substring(0, 6)}...', // Access via widget.booking
    //                     style:
    //                         const TextStyle(fontSize: 12, color: Colors.grey),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //         const Divider(height: 16),
    //         Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Row(
    //               children: [
    //                 const Icon(Icons.date_range,
    //                     color: Colors.blueGrey, size: 20),
    //                 const SizedBox(width: 8),
    //                 Text(
    //                   'Tanggal: ${DateFormat('MMM dd, yyyy').format(widget.booking.startDate)} - ${DateFormat('MMM dd, yyyy').format(widget.booking.endDate)}', // Access via widget.booking
    //                   style: const TextStyle(fontSize: 14)
    //                 ),

    //               ],
    //             ),
    //             const SizedBox(height: 4),
    //             Row(
    //               children: [
    //                 const Icon(Icons.people, color: Colors.blueGrey, size: 20),
    //                 const SizedBox(width: 8),
    //                 Text(
    //                   'Jumlah Tamu: ${widget.booking.guestCount}', // Access via widget.booking - THIS WAS THE ERROR LINE
    //                   style: const TextStyle(fontSize: 14),
    //                 ),
    //               ],
    //             ),
    //             const SizedBox(height: 4),
    //             Row(
    //               children: [
    //                 const Icon(Icons.attach_money,
    //                     color: Colors.green, size: 20),
    //                 const SizedBox(width: 8),
    //                 Text(
    //                   'Total Harga: \Rp${widget.booking.totalPrice.toStringAsFixed(2)}', // Access via widget.booking
    //                   style: const TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Colors.deepOrange, overflow: TextOverflow.ellipsis),
    //                 ),
    //               ],
    //             ),
    //             const SizedBox(height: 8),
    //             Row(
    //               children: [
    //                 const Icon(Icons.person, color: Colors.purple, size: 20),
    //                 const SizedBox(width: 8),
    //                 Expanded(
    //                   child: Text(
    //                     'Dipesan oleh: $_userName ($_userEmail)',
    //                     style: const TextStyle(
    //                         fontSize: 13, color: Colors.black87),
    //                     maxLines: 2,
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             const SizedBox(height: 4),
    //             Row(
    //               children: [
    //                 const Icon(Icons.access_time,
    //                     color: Colors.blueGrey, size: 20),
    //                 const SizedBox(width: 8),
    //                 Text(
    //                   'Dipesan pada: ${DateFormat('MMM dd, yyyy HH:mm').format(widget.booking.createdAt)}', // Access via widget.booking
    //                   style:
    //                       const TextStyle(fontSize: 12, color: Colors.blueGrey),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          : const AssetImage("assets/images/hotel.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Room Image
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
                // Hotel Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.hotelName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tipe Kamar: ${widget.booking.roomSummary}',
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID Booking: ${widget.booking.bookingId.substring(0, 6)}...',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.date_range,
                        color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tanggal: ${DateFormat('MMM dd, yyyy').format(widget.booking.startDate)} - ${DateFormat('MMM dd, yyyy').format(widget.booking.endDate)}',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jumlah Tamu: ${widget.booking.guestCount}',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.attach_money,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total Harga: \Rp${widget.booking.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepOrange),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dipesan oleh: $_userName ($_userEmail)',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dipesan pada: ${DateFormat('MMM dd, yyyy HH:mm').format(widget.booking.createdAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.blueGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
