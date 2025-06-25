// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/model/room.dart';
// import 'package:hotel_booking_app/pages/history_page.dart';
// import 'package:intl/intl.dart';

// class HotelDetailPage extends StatefulWidget {
//   final String hotelId; // Ganti hotelName dengan hotelId
//   final List<Map<String, dynamic>> rooms;

//   const HotelDetailPage({
//     Key? key,
//     required this.hotelId,
//     required this.rooms,
//   }) : super(key: key);

//   @override
//   _HotelDetailPageState createState() => _HotelDetailPageState();
// }

// class _HotelDetailPageState extends State<HotelDetailPage> {
//   List<Room> _rooms = []; // Tambahkan list untuk menyimpan data kamar
//   List<DateTime?> startDates = []; // List untuk menyimpan start date per room
//   List<DateTime?> endDates = []; // List untuk menyimpan end date per room
//   List<int> guestCounts = []; // List untuk menyimpan guest count per room
//   List<double> roomTotalPrices =
//       []; // List untuk menyimpan total price per room
//   double totalPrice = 0; // Total price calculation
//   List<int> selectedRoomIndices =
//       []; // List untuk menyimpan indeks ruangan yang dipilih
//   String? userId; // Define userId variable

//   // Fungsi untuk memformat harga
//   String formatCurrency(double amount) {
//     final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
//     return formatCurrency.format(amount);
//   }

//   // Fungsi format tanggal Indonesia
//   String formatDate(DateTime? date) {
//     if (date == null) return '-';
//     final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
//     return dateFormat.format(date);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchRooms(); // Ambil data kamar saat halaman diinisialisasi
//     userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
//   }

//   Future<void> _fetchRooms() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('rooms')
//         .where('hotelId', isEqualTo: widget.hotelId)
//         .get();

//     setState(() {
//       _rooms = snapshot.docs.map((doc) {
//         return Room(
//           id: doc.id,
//           hotelId: doc['hotelId'],
//           type: doc['type'],
//           price: (doc['price'] as num).toDouble(),
//           startDate: doc['startDate'] != null
//               ? DateTime.parse(doc['startDate'])
//               : null,
//           endDate:
//               doc['endDate'] != null ? DateTime.parse(doc['endDate']) : null,
//           guestCount: doc['guestCount'],
//           totalPrice: doc['totalPrice'],
//         );
//       }).toList();

//       // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
//       startDates = List<DateTime?>.filled(_rooms.length, null);
//       endDates = List<DateTime?>.filled(_rooms.length, null);
//       guestCounts = List<int>.filled(_rooms.length, 1);
//       roomTotalPrices = List<double>.filled(_rooms.length, 0);
//     });

//     for (var room in _rooms) {
//       await room.fetchBookings();
//       print('Bookings for room ${room.id}: ${room.bookings.length}');
//       for (var booking in room.bookings) {
//         print(
//             'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
//       }
//     }

//     // After fetching bookings, call setState to update the UI
//     setState(() {});
//   }

//   bool _isBookingConflict(int index) {
//     final selectedStartDate = startDates[index];
//     final selectedEndDate = endDates[index];

//     if (selectedStartDate == null || selectedEndDate == null) {
//       return false; // No dates selected
//     }

//     for (var booking in _rooms[index].bookings) {
//       // Check if the selected dates overlap with existing bookings
//       bool isOverlapping = (selectedStartDate.isBefore(booking.endDate) &&
//               selectedEndDate.isAfter(booking.startDate)) ||
//           (selectedStartDate.isAtSameMomentAs(booking.startDate) ||
//               selectedEndDate.isAtSameMomentAs(booking.endDate)) ||
//           (selectedStartDate.isAtSameMomentAs(booking.endDate) ||
//               selectedEndDate.isAtSameMomentAs(booking.startDate)) ||
//           (selectedStartDate.isAfter(booking.startDate) &&
//               selectedEndDate.isBefore(booking.endDate)) ||
//           (selectedStartDate.isBefore(booking.startDate) &&
//               selectedEndDate.isAfter(booking.endDate));

//       if (isOverlapping) {
//         return true; // Conflict found
//       }
//     }
//     return false; // No conflict
//   }

//   String _getRoomStatus(int index) {
//     // Check if the room is booked or in use
//     for (var booking in _rooms[index].bookings) {
//       if (booking.startDate.isBefore(DateTime.now()) &&
//           booking.endDate.isAfter(DateTime.now())) {
//         return "In Use"; // Room is currently in use
//       } else if (booking.startDate.isAfter(DateTime.now()) &&
//           booking.endDate.isAfter(DateTime.now()) &&
//           booking.userId == userId) {
//         return "Booked"; // Room is booked by the current user
//       }
//     }
//     return ""; // Room is available
//   }

//   void _calculateTotalPrice() {
//     totalPrice = 0;
//     for (var index in selectedRoomIndices) {
//       if (startDates[index] != null && endDates[index] != null) {
//         final nights = endDates[index]!.difference(startDates[index]!).inDays;
//         if (nights > 0) {
//           roomTotalPrices[index] =
//               nights * _rooms[index].price * guestCounts[index];
//           totalPrice += roomTotalPrices[index]; // Add to total price
//         } else {
//           roomTotalPrices[index] = 0; // Reset if dates are invalid
//         }
//       } else {
//         roomTotalPrices[index] = 0; // Reset if dates are not set
//       }
//     }
//     setState(() {});
//   }

//   Future<void> _pickStartDate(int index) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: startDates[index] ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != startDates[index]) {
//       setState(() {
//         startDates[index] = picked;

//         // Check if the end date is set and if the start date is after or equal to the end date
//         if (endDates[index] != null &&
//             startDates[index]!.isAfter(endDates[index]!)) {
//           endDates[index] = null; // Reset end date if invalid
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content:
//                     Text('Start date cannot be after or equal to end date.')),
//           );
//         }

//         _calculateTotalPrice(); // Recalculate total price
//       });
//     }
//   }

//   Future<void> _pickEndDate(int index) async {
//     if (startDates[index] == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please pick start date first')));
//       return;
//     }
//     final picked = await showDatePicker(
//       context: context,
//       initialDate:
//           endDates[index] ?? startDates[index]!.add(const Duration(days: 1)),
//       firstDate: startDates[index]!
//           .add(const Duration(days: 1)), // Ensure end date is after start date
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != endDates[index]) {
//       setState(() {
//         endDates[index] = picked;

//         // Check if the start date is set and if the end date is before or equal to the start date
//         if (endDates[index]!.isBefore(startDates[index]!) ||
//             endDates[index]!.isAtSameMomentAs(startDates[index]!)) {
//           startDates[index] = null; // Reset start date if invalid
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content:
//                     Text('End date cannot be before or equal to start date.')),
//           );
//         }

//         _calculateTotalPrice(); // Recalculate total price
//       });
//     }
//   }

//   Future<void> _toggleRoomSelection(int index) async {
//     setState(() {
//       if (selectedRoomIndices.contains(index)) {
//         selectedRoomIndices.remove(index);
//         startDates[index] = null;
//         endDates[index] = null;
//         guestCounts[index] = 1;
//         roomTotalPrices[index] = 0;
//       } else {
//         if (_isBookingConflict(index)) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('Room is already booked for the selected dates')),
//           );
//           return; // Prevent selection if there's a conflict
//         }
//         selectedRoomIndices.add(index);
//       }
//       _calculateTotalPrice();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Hotel?>(
//       future: Hotel.fetchHotelDetails(widget.hotelId), // Ambil detail hotel
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData) {
//           return const Center(child: Text('Hotel not found'));
//         }

//         final hotel = snapshot.data!; // Ambil data hotel

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Hotel Details",
//                 style: TextStyle(color: Colors.white)),
//             backgroundColor: Colors.blue,
//             centerTitle: true,
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//           bottomNavigationBar: selectedRoomIndices.isNotEmpty
//               ? Container(
//                   padding: const EdgeInsets.all(16),
//                   color: Colors.white,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Total Price: ${formatCurrency(totalPrice)}',
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ElevatedButton(
//                         onPressed: () async {
//                           try {
//                             // Check for booking conflicts before proceeding
//                             for (var index in selectedRoomIndices) {
//                               if (_isBookingConflict(index)) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                         'Room is already booked for the selected dates'),
//                                   ),
//                                 );
//                                 return; // Prevent booking if there's a conflict
//                               }
//                             }

//                             // Proceed with booking if no conflicts are found
//                             for (var index in selectedRoomIndices) {
//                               final room = _rooms[index];

//                               // Set tanggal, guest, dan total harga ke object
//                               room.startDate = startDates[index];
//                               room.endDate = endDates[index];
//                               room.guestCount = guestCounts[index];
//                               room.totalPrice = roomTotalPrices[index];

//                               // Panggil bookRoom dari instance
//                               await room.bookRoom(userId!); // Pass userId here
//                             }

//                             // Navigasi ke halaman history booking
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const HistoryPage()),
//                             );
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Booking gagal: $e')),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepPurple),
//                         child: const Text("Book Now",
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 )
//               : null,
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 100),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Hotel Banner
//                 SizedBox(
//                   height: 240,
//                   width: double.infinity,
//                   child: Image.asset(
//                     'assets/images/hotel.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 // Hotel Info
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(hotel.name,
//                           style: const TextStyle(
//                               fontSize: 26, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               color: Colors.orange, size: 20),
//                           const SizedBox(width: 4),
//                           Text("${hotel.rating} / 5.0"),
//                           const Spacer(),
//                           const Icon(Icons.location_on,
//                               color: Colors.red, size: 20),
//                           const SizedBox(width: 4),
//                           FutureBuilder<String>(
//                             future:
//                                 Location.fetchLocationName(hotel.locationId),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Text("Loading...");
//                               } else if (snapshot.hasError) {
//                                 return const Text("Error");
//                               } else {
//                                 return Text(
//                                     snapshot.data ?? "Unknown Location");
//                               }
//                             },
//                           )
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(hotel.description),
//                       const SizedBox(height: 20),

//                       // Amenities
//                       const Text("Amenities",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.w600)),
//                       const SizedBox(height: 10),
//                       ...hotel.amenities.map((item) => Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.check_circle_outline,
//                                     color: Colors.green),
//                                 const SizedBox(width: 10),
//                                 Text(item),
//                               ],
//                             ),
//                           )),

//                       const SizedBox(height: 30),

//                       // Room Options
//                       const Text("Available Rooms",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 16),
//                       Column(
//                         children: _rooms.asMap().entries.map((entry) {
//                           int index = entry.key;
//                           var room = entry.value;
//                           bool isSelected = selectedRoomIndices.contains(index);
//                           String roomStatus = _getRoomStatus(index);

//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 16),
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: isSelected
//                                     ? Colors.deepPurple
//                                     : Colors.grey.shade300,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 4,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: const BorderRadius.vertical(
//                                       top: Radius.circular(12)),
//                                   child: Image.asset(
//                                     "assets/images/room.png",
//                                     height: 160,
//                                     width: double.infinity,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(room.type,
//                                           style: const TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w700,
//                                           )),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                           "${formatCurrency(room.price)} / night",
//                                           style: const TextStyle(fontSize: 16)),
//                                       const SizedBox(height: 12),

//                                       const Text("Existing Bookings:",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold)),
//                                       ...room.bookings.map((booking) {
//                                         return Text(
//                                           '> From ${formatDate(booking.startDate)} To ${formatDate(booking.endDate)} - Total: ${formatCurrency(booking.totalPrice)}',
//                                           style: TextStyle(
//                                             color: booking.userId == userId
//                                                 ? Colors.orange[800]
//                                                 : Colors.black,
//                                           ),
//                                         );
//                                       }).toList(),

//                                       const SizedBox(height: 16),

//                                       /// Start Date Picker
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: TextButton.icon(
//                                               onPressed: isSelected
//                                                   ? () => _pickStartDate(index)
//                                                   : null,
//                                               icon: const Icon(Icons.date_range),
//                                               label: Text(startDates[index] ==
//                                                       null
//                                                   ? 'Pick Start Date'
//                                                   : 'Start: ${formatDate(startDates[index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Expanded(
//                                             child: TextButton.icon(
//                                               onPressed: isSelected
//                                                   ? () => _pickEndDate(index)
//                                                   : null,
//                                               icon: const Icon(
//                                                   Icons.date_range_outlined),
//                                               label: Text(endDates[index] == null
//                                                   ? 'Pick End Date'
//                                                   : 'End: ${formatDate(endDates[index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
//                                             ),
//                                           ),
//                                         ],
//                                       ),

//                                       const SizedBox(height: 16),

//                                       /// Guest Count
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           OutlinedButton(
//                                             onPressed: isSelected &&
//                                                     guestCounts[index] > 1
//                                                 ? () {
//                                                     setState(() {
//                                                       guestCounts[index]--;
//                                                       _calculateTotalPrice();
//                                                     });
//                                                   }
//                                                 : null,
//                                             style: OutlinedButton.styleFrom(
//                                               shape: const CircleBorder(),
//                                               padding: const EdgeInsets.all(10),
//                                             ),
//                                             child: const Icon(Icons.remove),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 24, vertical: 10),
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               color: Colors.grey.shade200,
//                                             ),
//                                             child: Text(
//                                               '${guestCounts[index]} Guest${guestCounts[index] > 1 ? 's' : ''}',
//                                               style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w500),
//                                             ),
//                                           ),
//                                           OutlinedButton(
//                                             onPressed: isSelected
//                                                 ? () {
//                                                     setState(() {
//                                                       guestCounts[index]++;
//                                                       _calculateTotalPrice();
//                                                     });
//                                                   }
//                                                 : null,
//                                             style: OutlinedButton.styleFrom(
//                                               shape: const CircleBorder(),
//                                               padding: const EdgeInsets.all(10),
//                                             ),
//                                             child: const Icon(Icons.add),
//                                           ),
//                                         ],
//                                       ),

//                                       const SizedBox(height: 16),

//                                       /// Total Price
//                                       if (roomTotalPrices[index] > 0)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 10, horizontal: 12),
//                                           margin:
//                                               const EdgeInsets.only(bottom: 10),
//                                           decoration: BoxDecoration(
//                                             color: Colors.green.shade50,
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                           child: Text(
//                                             'Room Total Price: ${formatCurrency(roomTotalPrices[index])}',
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16,
//                                                 color: Colors.green),
//                                           ),
//                                         ),

//                                       /// Room Status
//                                       if (roomStatus.isNotEmpty)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 8, horizontal: 12),
//                                           decoration: BoxDecoration(
//                                             color: roomStatus == "In Use"
//                                                 ? Colors.red.shade50
//                                                 : Colors.orange.shade50,
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                           child: Text(
//                                             roomStatus,
//                                             style: TextStyle(
//                                               color: roomStatus == "In Use"
//                                                   ? Colors.red
//                                                   : Colors.orange,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),

//                                       const SizedBox(height: 16),

//                                       /// Choose Button
//                                       SizedBox(
//                                         width: double.infinity,
//                                         child: ElevatedButton(
//                                           onPressed: roomStatus == "Booked"
//                                               ? null
//                                               : () {
//                                                   _toggleRoomSelection(index);
//                                                 },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: isSelected
//                                                 ? Colors.blue
//                                                 : Colors.grey[500],
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 14),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             isSelected ? "Selected" : "Choose",
//                                             style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'dart:typed_data'; // For Uint8List
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/model/room.dart';
// import 'package:hotel_booking_app/pages/history_page.dart';
// import 'package:intl/intl.dart';
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// class HotelDetailPage extends StatefulWidget {
//   final String hotelId; // Ganti hotelName dengan hotelId
//   final List<Map<String, dynamic>> rooms; // This 'rooms' parameter might be redundant if you always fetch rooms from Firestore

//   const HotelDetailPage({
//     Key? key,
//     required this.hotelId,
//     required this.rooms, // Consider removing this if rooms are always fetched
//   }) : super(key: key);

//   @override
//   _HotelDetailPageState createState() => _HotelDetailPageState();
// }

// class _HotelDetailPageState extends State<HotelDetailPage> {
//   List<Room> _rooms = []; // Tambahkan list untuk menyimpan data kamar
//   List<DateTime?> startDates = []; // List untuk menyimpan start date per room
//   List<DateTime?> endDates = []; // List untuk menyimpan end date per room
//   List<int> guestCounts = []; // List untuk menyimpan guest count per room
//   List<double> roomTotalPrices =
//       []; // List untuk menyimpan total price per room
//   double totalPrice = 0; // Total price calculation
//   List<int> selectedRoomIndices =
//       []; // List untuk menyimpan indeks ruangan yang dipilih
//   String? userId; // Define userId variable

//   Uint8List? _hotelImageBytes; // To store hotel image from Hive

//   // Fungsi untuk memformat harga
//   String formatCurrency(double amount) {
//     final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
//     return formatCurrency.format(amount);
//   }

//   // Fungsi format tanggal Indonesia
//   String formatDate(DateTime? date) {
//     if (date == null) return '-';
//     // Ensure 'id_ID' locale is supported in your app (add flutter_localizations)
//     // If not, just use 'dd MMMM yyyy'
//     final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
//     return dateFormat.format(date);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchRooms(); // Ambil data kamar saat halaman diinisialisasi
//     userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
//     _loadHotelImage(); // Load hotel image from Hive
//   }

//   Future<void> _loadHotelImage() async {
//     final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//     final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId);

//     debugPrint('Attempting to load hotel image bytes for ID: ${widget.hotelId} from Hive.');

//     if (imageBytes != null) {
//       setState(() {
//         _hotelImageBytes = imageBytes;
//       });
//       debugPrint('Hotel image bytes found and loaded for ID: ${widget.hotelId}.');
//     } else {
//       setState(() {
//         _hotelImageBytes = null; // No image bytes found in Hive
//       });
//       debugPrint('Hotel image bytes not found for ID: ${widget.hotelId} in Hive. Showing default.');
//     }
//   }

//   Future<void> _fetchRooms() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('rooms')
//         .where('hotelId', isEqualTo: widget.hotelId)
//         .get();

//     setState(() {
//       _rooms = snapshot.docs.map((doc) {
//         return Room(
//           id: doc.id,
//           hotelId: doc['hotelId'],
//           type: doc['type'],
//           price: (doc['price'] as num).toDouble(),
//           // startDate, endDate, guestCount, totalPrice are not directly from room document initially
//           // They are dynamic values based on user selection in this page
//           startDate: null, // Reset or ensure they are null here
//           endDate: null,
//           guestCount: 1,
//           totalPrice: 0,
//         );
//       }).toList();

//       // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
//       startDates = List<DateTime?>.filled(_rooms.length, null);
//       endDates = List<DateTime?>.filled(_rooms.length, null);
//       guestCounts = List<int>.filled(_rooms.length, 1);
//       roomTotalPrices = List<double>.filled(_rooms.length, 0);
//     });

//     // Fetch bookings for each room
//     for (var room in _rooms) {
//       await room.fetchBookings();
//       debugPrint('Bookings for room ${room.id}: ${room.bookings.length}');
//       for (var booking in room.bookings) {
//         debugPrint(
//             'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
//       }
//     }

//     // After fetching bookings, call setState to update the UI
//     setState(() {}); // This will re-trigger the build method to show booking statuses
//   }

//   bool _isBookingConflict(int index) {
//     final selectedStartDate = startDates[index];
//     final selectedEndDate = endDates[index];

//     if (selectedStartDate == null || selectedEndDate == null) {
//       return false; // No dates selected, so no conflict yet for these dates
//     }

//     // Normalize selected dates to start of day for comparison
//     final normalizedSelectedStart = DateTime(selectedStartDate.year, selectedStartDate.month, selectedStartDate.day);
//     final normalizedSelectedEnd = DateTime(selectedEndDate.year, selectedEndDate.month, selectedEndDate.day);

//     for (var booking in _rooms[index].bookings) {
//       // Normalize existing booking dates to start of day for comparison
//       final normalizedBookingStart = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);
//       final normalizedBookingEnd = DateTime(booking.endDate.year, booking.endDate.month, booking.endDate.day);

//       // Check for overlap. A conflict occurs if:
//       // (StartA < EndB) AND (EndA > StartB)
//       bool isOverlapping = (normalizedSelectedStart.isBefore(normalizedBookingEnd) &&
//           normalizedSelectedEnd.isAfter(normalizedBookingStart));

//       if (isOverlapping) {
//         return true; // Conflict found
//       }
//     }
//     return false; // No conflict
//   }

//   String _getRoomStatus(int index) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);

//     for (var booking in _rooms[index].bookings) {
//       final bookingStart = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);
//       final bookingEnd = DateTime(booking.endDate.year, booking.endDate.month, booking.endDate.day);

//       // Check if room is currently in use
//       if (today.isAfter(bookingStart.subtract(const Duration(days: 1))) &&
//           today.isBefore(bookingEnd)) {
//         return "In Use"; // Room is currently in use based on today's date
//       }

//       // Check if room is booked by the current user for future dates
//       if (booking.userId == userId && today.isBefore(bookingStart)) {
//         return "Booked by You"; // Room is booked by the current user for a future date
//       }
//     }
//     return ""; // Room is available
//   }

//   void _calculateTotalPrice() {
//     totalPrice = 0;
//     for (var index in selectedRoomIndices) {
//       if (startDates[index] != null && endDates[index] != null) {
//         final nights = endDates[index]!.difference(startDates[index]!).inDays;
//         if (nights > 0) {
//           roomTotalPrices[index] =
//               nights * _rooms[index].price * guestCounts[index];
//           totalPrice += roomTotalPrices[index]; // Add to total price
//         } else {
//           roomTotalPrices[index] = 0; // Reset if dates are invalid
//         }
//       } else {
//         roomTotalPrices[index] = 0; // Reset if dates are not set
//       }
//     }
//     setState(() {});
//   }

//   Future<void> _pickStartDate(int index) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: startDates[index] ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != startDates[index]) {
//       setState(() {
//         startDates[index] = picked;

//         // Ensure end date is after start date
//         if (endDates[index] != null &&
//             startDates[index]!.isAfter(endDates[index]!)) {
//           endDates[index] = null; // Reset end date if invalid
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content:
//                     Text('Start date cannot be after or equal to end date.')),
//           );
//         }
//         _calculateTotalPrice(); // Recalculate total price
//       });
//     }
//   }

//   Future<void> _pickEndDate(int index) async {
//     if (startDates[index] == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please pick start date first')));
//       return;
//     }
//     final picked = await showDatePicker(
//       context: context,
//       initialDate:
//           endDates[index] ?? startDates[index]!.add(const Duration(days: 1)),
//       firstDate: startDates[index]!
//           .add(const Duration(days: 1)), // Ensure end date is after start date
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != endDates[index]) {
//       setState(() {
//         endDates[index] = picked;

//         // Ensure start date is before end date
//         if (endDates[index]!.isBefore(startDates[index]!) ||
//             endDates[index]!.isAtSameMomentAs(startDates[index]!)) {
//           startDates[index] = null; // Reset start date if invalid
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content:
//                     Text('End date cannot be before or equal to start date.')),
//           );
//         }
//         _calculateTotalPrice(); // Recalculate total price
//       });
//     }
//   }

//   Future<void> _toggleRoomSelection(int index) async {
//     // Before toggling selection, check for conflicts if selecting
//     if (!selectedRoomIndices.contains(index)) {
//       if (_isBookingConflict(index)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Room is already booked for the selected dates or dates conflict with existing bookings.')),
//         );
//         return;
//       }
//     }

//     setState(() {
//       if (selectedRoomIndices.contains(index)) {
//         selectedRoomIndices.remove(index);
//         startDates[index] = null;
//         endDates[index] = null;
//         guestCounts[index] = 1;
//         roomTotalPrices[index] = 0;
//       } else {
//         selectedRoomIndices.add(index);
//       }
//       _calculateTotalPrice();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Hotel?>(
//       future: Hotel.fetchHotelDetails(widget.hotelId), // Ambil detail hotel
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData) {
//           return const Center(child: Text('Hotel not found'));
//         }

//         final hotel = snapshot.data!; // Ambil data hotel

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Hotel Details",
//                 style: TextStyle(color: Colors.white)),
//             backgroundColor: Colors.blue,
//             centerTitle: true,
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//           bottomNavigationBar: selectedRoomIndices.isNotEmpty
//               ? Container(
//                   padding: const EdgeInsets.all(16),
//                   color: Colors.white,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Total Price: ${formatCurrency(totalPrice)}',
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ElevatedButton(
//                         onPressed: () async {
//                           try {
//                             // Check for booking conflicts before proceeding
//                             for (var index in selectedRoomIndices) {
//                               if (startDates[index] == null || endDates[index] == null) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Please select dates for all chosen rooms.')),
//                                 );
//                                 return;
//                               }
//                               if (_isBookingConflict(index)) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                         'One or more rooms are already booked for the selected dates or dates conflict.'),
//                                   ),
//                                 );
//                                 return;
//                               }
//                             }

//                             // Proceed with booking if no conflicts are found
//                             for (var index in selectedRoomIndices) {
//                               final room = _rooms[index];

//                               // Set tanggal, guest, dan total harga ke object
//                               room.startDate = startDates[index];
//                               room.endDate = endDates[index];
//                               room.guestCount = guestCounts[index];
//                               room.totalPrice = roomTotalPrices[index];

//                               // Panggil bookRoom dari instance
//                               await room.bookRoom(userId!); // Pass userId here
//                             }

//                             // Navigasi ke halaman history booking
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const HistoryPage()),
//                             );
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("Booking successful!"), backgroundColor: Colors.green),
//                             );
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Booking gagal: $e')),
//                             );
//                             debugPrint('Booking failed: $e');
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepPurple),
//                         child: const Text("Book Now",
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 )
//               : null,
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 100),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Hotel Banner
//                 SizedBox(
//                   height: 240,
//                   width: double.infinity,
//                   child: _hotelImageBytes != null
//                       ? Image.memory(
//                           _hotelImageBytes!,
//                           fit: BoxFit.cover,
//                         )
//                       : Image.asset(
//                           'assets/images/hotel.png', // Default image
//                           fit: BoxFit.cover,
//                         ),
//                 ),

//                 // Hotel Info
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(hotel.name,
//                           style: const TextStyle(
//                               fontSize: 26, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               color: Colors.orange, size: 20),
//                           const SizedBox(width: 4),
//                           Text("${hotel.rating} / 5.0"),
//                           const Spacer(),
//                           const Icon(Icons.location_on,
//                               color: Colors.red, size: 20),
//                           const SizedBox(width: 4),
//                           FutureBuilder<String>(
//                             future:
//                                 Location.fetchLocationName(hotel.locationId),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Text("Loading...");
//                               } else if (snapshot.hasError) {
//                                 return const Text("Error");
//                               } else {
//                                 return Text(
//                                     snapshot.data ?? "Unknown Location");
//                               }
//                             },
//                           )
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(hotel.description),
//                       const SizedBox(height: 20),

//                       // Amenities
//                       const Text("Amenities",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.w600)),
//                       const SizedBox(height: 10),
//                       Wrap( // Using Wrap for better layout of amenities
//                         spacing: 8.0, // gap between adjacent chips
//                         runSpacing: 4.0, // gap between lines
//                         children: hotel.amenities.map((item) => Chip(
//                           label: Text(item),
//                           backgroundColor: Colors.blue.shade50,
//                           labelStyle: const TextStyle(color: Colors.blue),
//                           avatar: const Icon(Icons.check_circle_outline, color: Colors.blue, size: 18),
//                         )).toList(),
//                       ),

//                       const SizedBox(height: 30),

//                       // Room Options
//                       const Text("Available Rooms",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 16),
//                       Column(
//                         children: _rooms.asMap().entries.map((entry) {
//                           int index = entry.key;
//                           var room = entry.value;
//                           bool isSelected = selectedRoomIndices.contains(index);
//                           String roomStatus = _getRoomStatus(index);

//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 16),
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: isSelected
//                                     ? Colors.deepPurple
//                                     : Colors.grey.shade300,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 4,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: const BorderRadius.vertical(
//                                       top: Radius.circular(12)),
//                                   child: Image.asset(
//                                     "assets/images/room.png", // This should probably be dynamic based on room type
//                                     height: 160,
//                                     width: double.infinity,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(room.type,
//                                           style: const TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w700,
//                                           )),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                           "${formatCurrency(room.price)} / night",
//                                           style: const TextStyle(fontSize: 16)),
//                                       const SizedBox(height: 12),

//                                       const Text("Existing Bookings:",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold)),
//                                       if (room.bookings.isEmpty)
//                                         const Text("No current bookings."),
//                                       ...room.bookings.map((booking) {
//                                         return Text(
//                                           '> From ${formatDate(booking.startDate)} To ${formatDate(booking.endDate)} - Total: ${formatCurrency(booking.totalPrice)}',
//                                           style: TextStyle(
//                                               color: booking.userId == userId
//                                                   ? Colors.deepPurple[800]
//                                                   : Colors.black54, // Dim other user's bookings
//                                           ),
//                                         );
//                                       }).toList(),

//                                       const SizedBox(height: 16),

//                                       /// Start Date Picker
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: TextButton.icon(
//                                               onPressed: isSelected
//                                                   ? () => _pickStartDate(index)
//                                                   : null,
//                                               icon: const Icon(Icons.date_range),
//                                               label: Text(startDates[index] ==
//                                                       null
//                                                   ? 'Pick Start Date'
//                                                   : 'Start: ${formatDate(startDates[index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Expanded(
//                                             child: TextButton.icon(
//                                               onPressed: isSelected
//                                                   ? () => _pickEndDate(index)
//                                                   : null,
//                                               icon: const Icon(
//                                                   Icons.date_range_outlined),
//                                               label: Text(endDates[index] == null
//                                                   ? 'Pick End Date'
//                                                   : 'End: ${formatDate(endDates[index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
//                                             ),
//                                           ),
//                                         ],
//                                       ),

//                                       const SizedBox(height: 16),

//                                       /// Guest Count
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           OutlinedButton(
//                                             onPressed: isSelected &&
//                                                     guestCounts[index] > 1
//                                                 ? () {
//                                                     setState(() {
//                                                       guestCounts[index]--;
//                                                       _calculateTotalPrice();
//                                                     });
//                                                   }
//                                                 : null,
//                                             style: OutlinedButton.styleFrom(
//                                               shape: const CircleBorder(),
//                                               padding: const EdgeInsets.all(10),
//                                             ),
//                                             child: const Icon(Icons.remove),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 24, vertical: 10),
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               color: Colors.grey.shade200,
//                                             ),
//                                             child: Text(
//                                               '${guestCounts[index]} Guest${guestCounts[index] > 1 ? 's' : ''}',
//                                               style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w500),
//                                             ),
//                                           ),
//                                           OutlinedButton(
//                                             onPressed: isSelected
//                                                 ? () {
//                                                     setState(() {
//                                                       guestCounts[index]++;
//                                                       _calculateTotalPrice();
//                                                     });
//                                                   }
//                                                 : null,
//                                             style: OutlinedButton.styleFrom(
//                                               shape: const CircleBorder(),
//                                               padding: const EdgeInsets.all(10),
//                                             ),
//                                             child: const Icon(Icons.add),
//                                           ),
//                                         ],
//                                       ),

//                                       const SizedBox(height: 16),

//                                       /// Total Price for this room
//                                       if (roomTotalPrices[index] > 0 && isSelected)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 10, horizontal: 12),
//                                           margin:
//                                               const EdgeInsets.only(bottom: 10),
//                                           decoration: BoxDecoration(
//                                             color: Colors.green.shade50,
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                           child: Text(
//                                             'Room Price: ${formatCurrency(roomTotalPrices[index])}',
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16,
//                                                 color: Colors.green),
//                                           ),
//                                         ),

//                                       /// Room Status
//                                       if (roomStatus.isNotEmpty)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 8, horizontal: 12),
//                                           decoration: BoxDecoration(
//                                             color: roomStatus == "In Use"
//                                                 ? Colors.red.shade50
//                                                 : Colors.orange.shade50,
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                           child: Text(
//                                             roomStatus,
//                                             style: TextStyle(
//                                               color: roomStatus == "In Use"
//                                                   ? Colors.red
//                                                   : Colors.orange,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),

//                                       const SizedBox(height: 16),

//                                       /// Choose Button
//                                       SizedBox(
//                                         width: double.infinity,
//                                         child: ElevatedButton(
//                                           onPressed: roomStatus == "In Use" || roomStatus == "Booked by You"
//                                               ? null // Disable if in use or already booked by current user
//                                               : () {
//                                                   _toggleRoomSelection(index);
//                                                 },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: isSelected
//                                                 ? Colors.blue
//                                                 : (roomStatus.isNotEmpty ? Colors.grey[500] : Colors.deepPurple), // Change color if disabled
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 14),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             isSelected ? "Selected" : "Choose",
//                                             style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'dart:typed_data'; // For Uint8List
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/model/room.dart';
// import 'package:intl/intl.dart';
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// class HotelDetailPage extends StatefulWidget {
//   final String hotelId;
//   final List<Map<String, dynamic>> rooms; // This parameter might be redundant if you always fetch rooms from Firestore

//   const HotelDetailPage({
//     Key? key,
//     required this.hotelId,
//     required this.rooms, // Consider removing this if rooms are always fetched
//   }) : super(key: key);

//   @override
//   _HotelDetailPageState createState() => _HotelDetailPageState();
// }

// class _HotelDetailPageState extends State<HotelDetailPage> {
//   List<Room> _rooms = []; // List to store room data
//   List<DateTime?> startDates = []; // List to store start date per room
//   List<DateTime?> endDates = []; // List to store end date per room
//   List<int> guestCounts = []; // List to store guest count per room
//   List<double> roomTotalPrices =
//       []; // List to store total price per room for each room
//   double totalPrice = 0; // Overall total price
//   List<int> selectedRoomIndices =
//       []; // List to store indices of selected rooms
//   String? userId; // Define userId variable

//   Uint8List? _hotelImageBytes; // To store hotel image from Hive

//   // Function to format currency
//   String formatCurrency(double amount) {
//     final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
//     return formatCurrency.format(amount);
//   }

//   // Function to format date in Indonesian
//   String formatDate(DateTime? date) {
//     if (date == null) return '-';
//     final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
//     return dateFormat.format(date);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchRooms(); // Fetch room data when the page is initialized
//     userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
//     _loadHotelImage(); // Load hotel image from Hive
//   }

//   Future<void> _loadHotelImage() async {
//     final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//     final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId);

//     debugPrint('Attempting to load hotel image bytes for ID: ${widget.hotelId} from Hive.');

//     if (imageBytes != null) {
//       setState(() {
//         _hotelImageBytes = imageBytes;
//       });
//       debugPrint('Hotel image bytes found and loaded for ID: ${widget.hotelId}.');
//     } else {
//       setState(() {
//         _hotelImageBytes = null; // No image bytes found in Hive
//       });
//       debugPrint('Hotel image bytes not found for ID: ${widget.hotelId} in Hive. Showing default.');
//     }
//   }

//   Future<void> _fetchRooms() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('rooms')
//         .where('hotelId', isEqualTo: widget.hotelId)
//         .get();

//     setState(() {
//       _rooms = snapshot.docs.map((doc) {
//         return Room(
//           id: doc.id,
//           hotelId: doc['hotelId'],
//           type: doc['type'],
//           price: (doc['price'] as num).toDouble(),
//           // startDate, endDate, guestCount, totalPrice are not directly from room document initially
//           // They are dynamic values based on user selection in this page
//           startDate: null, // Reset or ensure they are null here
//           endDate: null,
//           guestCount: 1,
//           totalPrice: 0,
//         );
//       }).toList();

//       // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
//       startDates = List<DateTime?>.filled(_rooms.length, null);
//       endDates = List<DateTime?>.filled(_rooms.length, null);
//       guestCounts = List<int>.filled(_rooms.length, 1);
//       roomTotalPrices = List<double>.filled(_rooms.length, 0);
//     });

//     // Fetch bookings for each room
//     for (var room in _rooms) {
//       await room.fetchBookings();
//       debugPrint('Bookings for room ${room.id}: ${room.bookings.length}');
//       for (var booking in room.bookings) {
//         debugPrint(
//             'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
//       }
//     }

//     // After fetching bookings, call setState to update the UI
//     setState(() {}); // This will re-trigger the build method to show booking statuses
//   }

//   bool _isBookingConflict(int index) {
//     final selectedStartDate = startDates[index];
//     final selectedEndDate = endDates[index];

//     if (selectedStartDate == null || selectedEndDate == null) {
//       return false; // No dates selected, so no conflict yet for these dates
//     }

//     // Normalize selected dates to start of day for comparison
//     final normalizedSelectedStart = DateTime(selectedStartDate.year, selectedStartDate.month, selectedStartDate.day);
//     final normalizedSelectedEnd = DateTime(selectedEndDate.year, selectedEndDate.month, selectedEndDate.day);

//     for (var booking in _rooms[index].bookings) {
//       // Normalize existing booking dates to start of day for comparison
//       final normalizedBookingStart = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);
//       final normalizedBookingEnd = DateTime(booking.endDate.year, booking.endDate.month, booking.endDate.day);

//       // Check for overlap. A conflict occurs if:
//       // (StartA < EndB) AND (EndA > StartB)
//       bool isOverlapping = (normalizedSelectedStart.isBefore(normalizedBookingEnd) &&
//           normalizedSelectedEnd.isAfter(normalizedBookingStart));

//       if (isOverlapping) {
//         return true; // Conflict found
//       }
//     }
//     return false; // No conflict
//   }

//   String _getRoomStatus(int index) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);

//     for (var booking in _rooms[index].bookings) {
//       final bookingStart = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);
//       final bookingEnd = DateTime(booking.endDate.year, booking.endDate.month, booking.endDate.day);

//       // Check if room is currently in use
//       if (today.isAfter(bookingStart.subtract(const Duration(days: 1))) &&
//           today.isBefore(bookingEnd)) {
//         return "In Use"; // Room is currently in use based on today's date
//       }

//       // Check if room is booked by the current user for future dates
//       if (booking.userId == userId && today.isBefore(bookingStart)) {
//         return "Booked by You"; // Room is booked by the current user for a future date
//       }
//     }
//     return ""; // Room is available
//   }

//   void _calculateTotalPrice() {
//     totalPrice = 0;
//     for (var index in selectedRoomIndices) {
//       if (startDates[index] != null && endDates[index] != null) {
//         final nights = endDates[index]!.difference(startDates[index]!).inDays;
//         if (nights > 0) {
//           roomTotalPrices[index] =
//               nights * _rooms[index].price * guestCounts[index];
//           totalPrice += roomTotalPrices[index]; // Add to total price
//         } else {
//           roomTotalPrices[index] = 0; // Reset if dates are invalid
//         }
//       } else {
//         roomTotalPrices[index] = 0; // Reset if dates are not set
//       }
//     }
//     setState(() {});
//   }

//   Future<void> _pickStartDate(int index) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: startDates[index] ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != startDates[index]) {
//       setState(() {
//         startDates[index] = picked;

//         // Ensure end date is after start date
//         if (endDates[index] != null &&
//             startDates[index]!.isAfter(endDates[index]!)) {
//           endDates[index] = null; // Reset end date if invalid
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content:
//                     Text('Start date cannot be after or equal to end date.')),
//           );
//         }
//         _calculateTotalPrice(); // Recalculate total price
//       });
//     }
//   }

//   Future<void> _pickEndDate(int index) async {
//     if (startDates[index] == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please pick start date first')));
//       return;
//     }
//     final picked = await showDatePicker(
//       context: context,
//       initialDate:
//           endDates[index] ?? startDates[index]!.add(const Duration(days: 1)),
//       firstDate: startDates[index]!
//           .add(const Duration(days: 1)), // Ensure end date is after start date
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != endDates[index]) {
//       setState(() {
//         endDates[index] = picked;

//         // Ensure start date is before end date
//         if (endDates[index]!.isBefore(startDates[index]!) ||
//             endDates[index]!.isAtSameMomentAs(startDates[index]!)) {
//           startDates[index] = null; // Reset start date if invalid
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content:
//                     Text('End date cannot be before or equal to start date.')),
//           );
//         }
//         _calculateTotalPrice(); // Recalculate total price
//       });
//     }
//   }

//   Future<void> _toggleRoomSelection(int index) async {
//     // Before toggling selection, check for conflicts if selecting
//     if (!selectedRoomIndices.contains(index)) {
//       // if (startDates[index] == null || endDates[index] == null) {
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(content: Text('Please select both start and end dates first.')),
//       //   );
//       //   return;
//       // }
//       if (_isBookingConflict(index)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Room is already booked for the selected dates or dates conflict with existing bookings.')),
//         );
//         return;
//       }
//     }

//     setState(() {
//       if (selectedRoomIndices.contains(index)) {
//         selectedRoomIndices.remove(index);
//         startDates[index] = null;
//         endDates[index] = null;
//         guestCounts[index] = 1;
//         roomTotalPrices[index] = 0;
//       } else {
//         selectedRoomIndices.add(index);
//       }
//       _calculateTotalPrice();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Hotel?>(
//       future: Hotel.fetchHotelDetails(widget.hotelId), // Fetch hotel details
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData) {
//           return const Center(child: Text('Hotel not found'));
//         }

//         final hotel = snapshot.data!; // Get hotel data

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Hotel Details",
//                 style: TextStyle(color: Colors.white)),
//             backgroundColor: Colors.blue,
//             centerTitle: true,
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//           bottomNavigationBar: selectedRoomIndices.isNotEmpty
//               ? Container(
//                   padding: const EdgeInsets.all(16),
//                   color: Colors.white,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Total Price: ${formatCurrency(totalPrice)}',
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ElevatedButton(
//                         onPressed: () async {
//                           try {
//                             // Check for booking conflicts before proceeding
//                             for (var index in selectedRoomIndices) {
//                               if (startDates[index] == null || endDates[index] == null) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Please select dates for all chosen rooms.')),
//                                 );
//                                 return;
//                               }
//                               if (_isBookingConflict(index)) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                         'One or more rooms are already booked for the selected dates or dates conflict.'),
//                                   ),
//                                 );
//                                 return;
//                               }
//                             }

//                             // Proceed with booking if no conflicts are found
//                             for (var index in selectedRoomIndices) {
//                               final room = _rooms[index];

//                               // Set tanggal, guest, dan total harga ke object
//                               room.startDate = startDates[index];
//                               room.endDate = endDates[index];
//                               room.guestCount = guestCounts[index];
//                               room.totalPrice = roomTotalPrices[index];

//                               // Call bookRoom from instance
//                               await room.bookRoom(userId!); // Pass userId here
//                             }

//                             // Navigate to history page
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(
//                             //       builder: (_) => const HistoryPage()),
//                             // );
//                             Navigator.of(context).popUntil((route) => route.isFirst);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("Booking successful!"), backgroundColor: Colors.green),
//                             );
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Booking failed: $e')),
//                             );
//                             debugPrint('Booking failed: $e');
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepPurple),
//                         child: const Text("Book Now",
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 )
//               : null,
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 100),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Hotel Banner
//                 SizedBox(
//                   height: 240,
//                   width: double.infinity,
//                   child: _hotelImageBytes != null
//                       ? Image.memory(
//                           _hotelImageBytes!,
//                           fit: BoxFit.cover,
//                         )
//                       : Image.asset(
//                           'assets/images/hotel.png', // Default image
//                           fit: BoxFit.cover,
//                         ),
//                 ),

//                 // Hotel Info
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(hotel.name,
//                           style: const TextStyle(
//                               fontSize: 26, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               color: Colors.orange, size: 20),
//                           const SizedBox(width: 4),
//                           Text("${hotel.rating} / 5.0"),
//                           const Spacer(),
//                           const Icon(Icons.location_on,
//                               color: Colors.red, size: 20),
//                           const SizedBox(width: 4),
//                           FutureBuilder<String>(
//                             future:
//                                 Location.fetchLocationName(hotel.locationId),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Text("Loading...");
//                               } else if (snapshot.hasError) {
//                                 return const Text("Error");
//                               } else {
//                                 return Text(
//                                     snapshot.data ?? "Unknown Location");
//                               }
//                             },
//                           )
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(hotel.description),
//                       const SizedBox(height: 20),

//                       // Amenities
//                       const Text("Amenities",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.w600)),
//                       const SizedBox(height: 10),
//                       Wrap( // Using Wrap for better layout of amenities
//                         spacing: 8.0, // gap between adjacent chips
//                         runSpacing: 4.0, // gap between lines
//                         children: hotel.amenities.map((item) => Chip(
//                           label: Text(item),
//                           backgroundColor: Colors.blue.shade50,
//                           labelStyle: const TextStyle(color: Colors.blue),
//                           avatar: const Icon(Icons.check_circle_outline, color: Colors.blue, size: 18),
//                         )).toList(),
//                       ),

//                       const SizedBox(height: 30),

//                       // Room Options
//                       const Text("Available Rooms",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 16),
//                       Column(
//                         children: _rooms.asMap().entries.map((entry) {
//                           int index = entry.key;
//                           var room = entry.value;
//                           bool isSelected = selectedRoomIndices.contains(index);
//                           String roomStatus = _getRoomStatus(index);

//                           return RoomCard( // Using a new widget for RoomCard
//                             room: room,
//                             index: index,
//                             isSelected: isSelected,
//                             roomStatus: roomStatus,
//                             formatCurrency: formatCurrency,
//                             formatDate: formatDate,
//                             startDates: startDates,
//                             endDates: endDates,
//                             guestCounts: guestCounts,
//                             roomTotalPrices: roomTotalPrices,
//                             pickStartDate: _pickStartDate,
//                             pickEndDate: _pickEndDate,
//                             toggleRoomSelection: _toggleRoomSelection,
//                             calculateTotalPrice: _calculateTotalPrice,
//                             userId: userId, // Pass userId to RoomCard
//                           );
//                         }).toList(),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Extracting RoomCard into its own StatefulWidget for better organization and image loading
// class RoomCard extends StatefulWidget {
//   final Room room;
//   final int index;
//   final bool isSelected;
//   final String roomStatus;
//   final Function(double) formatCurrency;
//   final Function(DateTime?) formatDate;
//   final List<DateTime?> startDates;
//   final List<DateTime?> endDates;
//   final List<int> guestCounts;
//   final List<double> roomTotalPrices;
//   final Function(int) pickStartDate;
//   final Function(int) pickEndDate;
//   final Function(int) toggleRoomSelection;
//   final VoidCallback calculateTotalPrice;
//   final String? userId; // Pass userId to RoomCard

//   const RoomCard({
//     Key? key,
//     required this.room,
//     required this.index,
//     required this.isSelected,
//     required this.roomStatus,
//     required this.formatCurrency,
//     required this.formatDate,
//     required this.startDates,
//     required this.endDates,
//     required this.guestCounts,
//     required this.roomTotalPrices,
//     required this.pickStartDate,
//     required this.pickEndDate,
//     required this.toggleRoomSelection,
//     required this.calculateTotalPrice,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   State<RoomCard> createState() => _RoomCardState();
// }

// class _RoomCardState extends State<RoomCard> {
//   Uint8List? _roomImageBytes;

//   @override
//   void initState() {
//     super.initState();
//     _loadRoomImage();
//   }

//   @override
//   void didUpdateWidget(covariant RoomCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.room.id != oldWidget.room.id) {
//       _loadRoomImage();
//     }
//   }

//   Future<void> _loadRoomImage() async {
//     final roomImagesBox = Hive.box<Uint8List>('room_images');
//     final Uint8List? imageBytes = roomImagesBox.get(widget.room.id);

//     debugPrint('Attempting to load room image bytes for ID: ${widget.room.id} from Hive.');

//     if (imageBytes != null) {
//       setState(() {
//         _roomImageBytes = imageBytes;
//       });
//       debugPrint('Room image bytes found and loaded for ID: ${widget.room.id}.');
//     } else {
//       setState(() {
//         _roomImageBytes = null; // No image bytes found in Hive
//       });
//       debugPrint('Room image bytes not found for ID: ${widget.room.id} in Hive. Showing default.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           color: widget.isSelected
//               ? Colors.deepPurple
//               : Colors.grey.shade300,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 4,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(12)),
//             child: SizedBox(
//               height: 160,
//               width: double.infinity,
//               child: _roomImageBytes != null
//                   ? Image.memory(
//                       _roomImageBytes!,
//                       fit: BoxFit.cover,
//                     )
//                   : Image.asset(
//                       "assets/images/room.png", // Default image
//                       fit: BoxFit.cover,
//                     ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(widget.room.type,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                     )),
//                 const SizedBox(height: 8),
//                 Text(
//                     "${widget.formatCurrency(widget.room.price)} / night",
//                     style: const TextStyle(fontSize: 16)),
//                 const SizedBox(height: 12),

//                 const Text("Existing Bookings:",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold)),
//                 if (widget.room.bookings.isEmpty)
//                   const Text("No current bookings."),
//                 ...widget.room.bookings.map((booking) {
//                   return Text(
//                     '> From ${widget.formatDate(booking.startDate)} To ${widget.formatDate(booking.endDate)} - Total: ${widget.formatCurrency(booking.totalPrice)}',
//                     style: TextStyle(
//                         color: booking.userId == widget.userId
//                             ? Colors.deepPurple[800]
//                             : Colors.black54, // Dim other user's bookings
//                     ),
//                   );
//                 }).toList(),

//                 const SizedBox(height: 16),

//                 /// Start Date Picker
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextButton.icon(
//                         onPressed: widget.isSelected
//                             ? () => widget.pickStartDate(widget.index)
//                             : null,
//                         icon: const Icon(Icons.date_range),
//                         label: Text(widget.startDates[widget.index] ==
//                                 null
//                             ? 'Pick Start Date'
//                             : 'Start: ${widget.formatDate(widget.startDates[widget.index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextButton.icon(
//                         onPressed: widget.isSelected
//                             ? () => widget.pickEndDate(widget.index)
//                             : null,
//                         icon: const Icon(
//                             Icons.date_range_outlined),
//                         label: Text(widget.endDates[widget.index] == null
//                             ? 'Pick End Date'
//                             : 'End: ${widget.formatDate(widget.endDates[widget.index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 /// Guest Count
//                 Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,
//                   children: [
//                     OutlinedButton(
//                       onPressed: widget.isSelected &&
//                               widget.guestCounts[widget.index] > 1
//                           ? () {
//                               setState(() {
//                                 widget.guestCounts[widget.index]--;
//                                 widget.calculateTotalPrice();
//                               });
//                             }
//                           : null,
//                       style: OutlinedButton.styleFrom(
//                         shape: const CircleBorder(),
//                         padding: const EdgeInsets.all(10),
//                       ),
//                       child: const Icon(Icons.remove),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 10),
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(8),
//                         color: Colors.grey.shade200,
//                       ),
//                       child: Text(
//                         '${widget.guestCounts[widget.index]} Guest${widget.guestCounts[widget.index] > 1 ? 's' : ''}',
//                         style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                     OutlinedButton(
//                       onPressed: widget.isSelected
//                           ? () {
//                               setState(() {
//                                 widget.guestCounts[widget.index]++;
//                                 widget.calculateTotalPrice();
//                               });
//                             }
//                           : null,
//                       style: OutlinedButton.styleFrom(
//                         shape: const CircleBorder(),
//                         padding: const EdgeInsets.all(10),
//                       ),
//                       child: const Icon(Icons.add),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 /// Total Price for this room
//                 if (widget.roomTotalPrices[widget.index] > 0 && widget.isSelected)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 12),
//                     margin:
//                         const EdgeInsets.only(bottom: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       borderRadius:
//                           BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Room Price: ${widget.formatCurrency(widget.roomTotalPrices[widget.index])}',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.green),
//                     ),
//                   ),

//                 /// Room Status
//                 if (widget.roomStatus.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8, horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: widget.roomStatus == "In Use"
//                           ? Colors.red.shade50
//                           : Colors.orange.shade50,
//                       borderRadius:
//                           BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       widget.roomStatus,
//                       style: TextStyle(
//                         color: widget.roomStatus == "In Use"
//                             ? Colors.red
//                             : Colors.orange,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 const SizedBox(height: 16),

//                 /// Choose Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: widget.roomStatus == "In Use" || widget.roomStatus == "Booked by You"
//                         ? null // Disable if in use or already booked by current user
//                         : () {
//                             widget.toggleRoomSelection(widget.index);
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: widget.isSelected
//                           ? Colors.blue
//                           : (widget.roomStatus.isNotEmpty ? Colors.grey[500] : Colors.deepPurple), // Change color if disabled
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       widget.isSelected ? "Selected" : "Choose",
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // class RoomCard extends StatefulWidget {
// //   final Room room; // Room object containing guestCount
// //   final int index;
// //   final bool isSelected;
// //   final String roomStatus;
// //   final Function(double) formatCurrency;
// //   final Function(DateTime?) formatDate;
// //   final List<DateTime?> startDates;
// //   final List<DateTime?> endDates;
// //   final List<int> guestCounts; // This list holds selected guest count for each room
// //   final List<double> roomTotalPrices;
// //   final Function(int) pickStartDate;
// //   final Function(int) pickEndDate;
// //   final Function(int) toggleRoomSelection;
// //   final VoidCallback calculateTotalPrice;
// //   final String? userId; // Pass userId to RoomCard

// //   const RoomCard({
// //     Key? key,
// //     required this.room, // Pass the Room object
// //     required this.index,
// //     required this.isSelected,
// //     required this.roomStatus,
// //     required this.formatCurrency,
// //     required this.formatDate,
// //     required this.startDates,
// //     required this.endDates,
// //     required this.guestCounts,
// //     required this.roomTotalPrices,
// //     required this.pickStartDate,
// //     required this.pickEndDate,
// //     required this.toggleRoomSelection,
// //     required this.calculateTotalPrice,
// //     required this.userId,
// //   }) : super(key: key);

// //   @override
// //   State<RoomCard> createState() => _RoomCardState();
// // }

// // class _RoomCardState extends State<RoomCard> {
// //   Uint8List? _roomImageBytes;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadRoomImage();
// //   }

// //   @override
// //   void didUpdateWidget(covariant RoomCard oldWidget) {
// //     super.didUpdateWidget(oldWidget);
// //     if (widget.room.id != oldWidget.room.id) {
// //       _loadRoomImage();
// //     }
// //   }

// //   Future<void> _loadRoomImage() async {
// //     final roomImagesBox = Hive.box<Uint8List>('room_images');
// //     final Uint8List? imageBytes = roomImagesBox.get(widget.room.id);

// //     debugPrint('Attempting to load room image bytes for ID: ${widget.room.id} from Hive.');

// //     if (imageBytes != null) {
// //       setState(() {
// //         _roomImageBytes = imageBytes;
// //       });
// //       debugPrint('Room image bytes found and loaded for ID: ${widget.room.id}.');
// //     } else {
// //       setState(() {
// //         _roomImageBytes = null; // No image bytes found in Hive
// //       });
// //       debugPrint('Room image bytes not found for ID: ${widget.room.id} in Hive. Showing default.');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get the maximum guest capacity for this specific room
// //     final int maxGuestCapacity = widget.room.guestCount ?? 1; // Default to 1 if not set

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       shape: RoundedRectangleBorder(
// //         side: BorderSide(
// //           color: widget.isSelected
// //               ? Colors.deepPurple
// //               : Colors.grey.shade300,
// //         ),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       elevation: 4,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           ClipRRect(
// //             borderRadius: const BorderRadius.vertical(
// //                 top: Radius.circular(12)),
// //             child: SizedBox(
// //               height: 160,
// //               width: double.infinity,
// //               child: _roomImageBytes != null
// //                   ? Image.memory(
// //                       _roomImageBytes!,
// //                       fit: BoxFit.cover,
// //                     )
// //                   : Image.asset(
// //                       "assets/images/room.png", // Default image
// //                       fit: BoxFit.cover,
// //                     ),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment:
// //                   CrossAxisAlignment.start,
// //               children: [
// //                 Text(widget.room.type,
// //                     style: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.w700,
// //                     )),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                     "${widget.formatCurrency(widget.room.price)} / night",
// //                     style: const TextStyle(fontSize: 16)),
// //                 // Display the room's maximum capacity
// //                 Text(
// //                   'Kapasitas Maks: ${widget.room.guestCount ?? 'Tidak Diketahui'} Tamu',
// //                   style: const TextStyle(fontSize: 14, color: Colors.grey),
// //                 ),
// //                 const SizedBox(height: 12),

// //                 const Text("Pemesanan Saat Ini:",
// //                     style: TextStyle(
// //                         fontWeight: FontWeight.bold)),
// //                 if (widget.room.bookings.isEmpty)
// //                   const Text("Tidak ada pemesanan saat ini."),
// //                 ...widget.room.bookings.map((booking) {
// //                   return Text(
// //                     '> Dari ${widget.formatDate(booking.startDate)} Hingga ${widget.formatDate(booking.endDate)} - Total: ${widget.formatCurrency(booking.totalPrice)}',
// //                     style: TextStyle(
// //                         color: booking.userId == widget.userId
// //                             ? Colors.deepPurple[800]
// //                             : Colors.black54, // Redupkan pemesanan pengguna lain
// //                     ),
// //                   );
// //                 }).toList(),

// //                 const SizedBox(height: 16),

// //                 /// Date Pickers
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextButton.icon(
// //                         onPressed: widget.isSelected
// //                             ? () => widget.pickStartDate(widget.index)
// //                             : null,
// //                         icon: const Icon(Icons.date_range),
// //                         label: Text(widget.startDates[widget.index] ==
// //                                 null
// //                             ? 'Pilih Tanggal Mulai'
// //                             : 'Mulai: ${widget.formatDate(widget.startDates[widget.index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: TextButton.icon(
// //                         onPressed: widget.isSelected
// //                             ? () => widget.pickEndDate(widget.index)
// //                             : null,
// //                         icon: const Icon(
// //                             Icons.date_range_outlined),
// //                         label: Text(widget.endDates[widget.index] == null
// //                             ? 'Pilih Tanggal Akhir'
// //                             : 'Akhir: ${widget.formatDate(widget.endDates[widget.index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 const SizedBox(height: 16),

// //                 /// Guest Count Selector
// //                 Row(
// //                   mainAxisAlignment:
// //                       MainAxisAlignment.center,
// //                   children: [
// //                     OutlinedButton(
// //                       onPressed: widget.isSelected &&
// //                               widget.guestCounts[widget.index] > 1
// //                           ? () {
// //                               setState(() {
// //                                 widget.guestCounts[widget.index]--;
// //                                 widget.calculateTotalPrice();
// //                               });
// //                             }
// //                           : null,
// //                       style: OutlinedButton.styleFrom(
// //                         shape: const CircleBorder(),
// //                         padding: const EdgeInsets.all(10),
// //                       ),
// //                       child: const Icon(Icons.remove),
// //                     ),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                           horizontal: 24, vertical: 10),
// //                       decoration: BoxDecoration(
// //                         borderRadius:
// //                             BorderRadius.circular(8),
// //                         color: Colors.grey.shade200,
// //                       ),
// //                       child: Text(
// //                         '${widget.guestCounts[widget.index]} Tamu${widget.guestCounts[widget.index] > 1 ? '' : ''}',
// //                         style: const TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.w500),
// //                       ),
// //                     ),
// //                     OutlinedButton(
// //                       onPressed: widget.isSelected &&
// //                               widget.guestCounts[widget.index] < maxGuestCapacity // BATAS MAKSIMUM DI SINI
// //                           ? () {
// //                               setState(() {
// //                                 widget.guestCounts[widget.index]++;
// //                                 widget.calculateTotalPrice();
// //                               });
// //                             }
// //                           : null,
// //                       style: OutlinedButton.styleFrom(
// //                         shape: const CircleBorder(),
// //                         padding: const EdgeInsets.all(10),
// //                       ),
// //                       child: const Icon(Icons.add),
// //                     ),
// //                   ],
// //                 ),

// //                 const SizedBox(height: 16),

// //                 /// Total Price for this room
// //                 if (widget.roomTotalPrices[widget.index] > 0 && widget.isSelected)
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                         vertical: 10, horizontal: 12),
// //                     margin:
// //                         const EdgeInsets.only(bottom: 10),
// //                     decoration: BoxDecoration(
// //                       color: Colors.green.shade50,
// //                       borderRadius:
// //                           BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       'Harga Kamar: ${widget.formatCurrency(widget.roomTotalPrices[widget.index])}',
// //                       style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                           color: Colors.green),
// //                     ),
// //                   ),

// //                 /// Room Status
// //                 if (widget.roomStatus.isNotEmpty)
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                         vertical: 8, horizontal: 12),
// //                     decoration: BoxDecoration(
// //                       color: widget.roomStatus == "In Use"
// //                           ? Colors.red.shade50
// //                           : Colors.orange.shade50,
// //                       borderRadius:
// //                           BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       widget.roomStatus,
// //                       style: TextStyle(
// //                         color: widget.roomStatus == "In Use"
// //                             ? Colors.red
// //                             : Colors.orange,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),

// //                 const SizedBox(height: 16),

// //                 /// Choose Button
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: widget.roomStatus == "In Use" || widget.roomStatus == "Booked by You"
// //                         ? null // Disable if in use or already booked by current user
// //                         : () {
// //                             widget.toggleRoomSelection(widget.index);
// //                           },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: widget.isSelected
// //                           ? Colors.blue
// //                           : (widget.roomStatus.isNotEmpty ? Colors.grey[500] : Colors.deepPurple), // Change color if disabled
// //                       padding: const EdgeInsets.symmetric(
// //                           vertical: 14),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius:
// //                             BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     child: Text(
// //                       widget.isSelected ? "Terpilih" : "Pilih",
// //                       style: const TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 16),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

import 'dart:typed_data'; // For Uint8List
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/model/room.dart'; // Make sure this imports your Room model
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

class HotelDetailPage extends StatefulWidget {
  final String hotelId;
  // This 'rooms' parameter is likely redundant if you always fetch rooms from Firestore.
  // It's safer to remove it to avoid confusion or outdated data.
  final List<Map<String, dynamic>>
      rooms; // Keeping it for now as per your original code, but consider removing.

  const HotelDetailPage({
    Key? key,
    required this.hotelId,
    required this.rooms, // Consider removing this if rooms are always fetched
  }) : super(key: key);

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  List<Room> _rooms =
      []; // List to store room data (now includes guestCount from Firestore)
  List<DateTime?> startDates = []; // List to store start date per room
  List<DateTime?> endDates = []; // List to store end date per room
  List<int> guestCounts =
      []; // List to store *selected* guest count per room (up to room.guestCount capacity)
  List<double> roomTotalPrices =
      []; // List to store total price per room for each room
  double totalPrice = 0; // Overall total price
  List<int> selectedRoomIndices = []; // List to store indices of selected rooms
  String? userId; // Define userId variable

  Uint8List? _hotelImageBytes; // To store hotel image from Hive

  // Function to format currency
  String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
    return formatCurrency.format(amount);
  }

  // Function to format date in Indonesian
  String formatDate(DateTime? date) {
    if (date == null) return '-';
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    return dateFormat.format(date);
  }

  @override
  void initState() {
    super.initState();
    _fetchRooms(); // Fetch room data when the page is initialized
    userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
    _loadHotelImage(); // Load hotel image from Hive
  }

  Future<void> _loadHotelImage() async {
    final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
    final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId);

    debugPrint(
        'Attempting to load hotel image bytes for ID: ${widget.hotelId} from Hive.');

    if (imageBytes != null) {
      setState(() {
        _hotelImageBytes = imageBytes;
      });
      debugPrint(
          'Hotel image bytes found and loaded for ID: ${widget.hotelId}.');
    } else {
      setState(() {
        _hotelImageBytes = null; // No image bytes found in Hive
      });
      debugPrint(
          'Hotel image bytes not found for ID: ${widget.hotelId} in Hive. Showing default.');
    }
  }

  Future<void> _fetchRooms() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('hotelId', isEqualTo: widget.hotelId)
          .get();

      final fetchedRooms = snapshot.docs.map((doc) {
        // Correctly use the fromFirestore factory to get all room properties including guestCount
        return Room.fromFirestore(doc);
      }).toList();

      setState(() {
        _rooms = fetchedRooms;

        // Initialize lists based on the fetched rooms' actual guestCount
        // guestCounts should be initialized to 1 (or a default min) but limited by room.guestCount
        startDates = List<DateTime?>.filled(_rooms.length, null);
        endDates = List<DateTime?>.filled(_rooms.length, null);
        guestCounts = List<int>.generate(_rooms.length,
            (index) => 1); // Start with 1 guest, will be capped by maxCapacity
        roomTotalPrices = List<double>.filled(_rooms.length, 0);
      });

      // Fetch bookings for each room
      for (var room in _rooms) {
        await room.fetchBookings();
        debugPrint('Bookings for room ${room.id}: ${room.bookings.length}');
        for (var booking in room.bookings) {
          debugPrint(
              'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
        }
      }

      // After fetching bookings, call setState to update the UI
      setState(
          () {}); // This will re-trigger the build method to show booking statuses
    } catch (e) {
      debugPrint('Error fetching rooms or bookings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load rooms: $e')),
      );
    }
  }

  bool _isBookingConflict(int index) {
    final selectedStartDate = startDates[index];
    final selectedEndDate = endDates[index];

    if (selectedStartDate == null || selectedEndDate == null) {
      return false; // No dates selected, so no conflict yet for these dates
    }

    // Normalize selected dates to start of day for comparison
    final normalizedSelectedStart = DateTime(
        selectedStartDate.year, selectedStartDate.month, selectedStartDate.day);
    final normalizedSelectedEnd = DateTime(
        selectedEndDate.year, selectedEndDate.month, selectedEndDate.day);

    for (var booking in _rooms[index].bookings) {
      // Normalize existing booking dates to start of day for comparison
      final normalizedBookingStart = DateTime(booking.startDate.year,
          booking.startDate.month, booking.startDate.day);
      final normalizedBookingEnd = DateTime(
          booking.endDate.year, booking.endDate.month, booking.endDate.day);

      // Check for overlap. A conflict occurs if:
      // (StartA < EndB) AND (EndA > StartB)
      bool isOverlapping =
          (normalizedSelectedStart.isBefore(normalizedBookingEnd) &&
              normalizedSelectedEnd.isAfter(normalizedBookingStart));

      if (isOverlapping) {
        return true; // Conflict found
      }
    }
    return false; // No conflict
  }

  String _getRoomStatus(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var booking in _rooms[index].bookings) {
      final bookingStart = DateTime(booking.startDate.year,
          booking.startDate.month, booking.startDate.day);
      final bookingEnd = DateTime(
          booking.endDate.year, booking.endDate.month, booking.endDate.day);

      // Check if room is currently in use
      // A room is "In Use" if today is between (or on) the booking start and end date (inclusive of start, exclusive of end for simple logic)
      if ((today.isAfter(bookingStart) ||
              today.isAtSameMomentAs(bookingStart)) &&
          today.isBefore(bookingEnd)) {
        return "In Use"; // Room is currently in use based on today's date
      }

      // Check if room is booked by the current user for future dates
      // And importantly, check if the *current user* is the one who booked it.
      if (booking.userId == userId && today.isBefore(bookingStart)) {
        return "Booked by You"; // Room is booked by the current user for a future date
      }
    }
    return ""; // Room is available
  }

  void _calculateTotalPrice() {
    totalPrice = 0;
    for (var index in selectedRoomIndices) {
      if (startDates[index] != null && endDates[index] != null) {
        final nights = endDates[index]!.difference(startDates[index]!).inDays;
        if (nights > 0) {
          roomTotalPrices[index] =
              nights * _rooms[index].price * guestCounts[index];
          totalPrice += roomTotalPrices[index]; // Add to overall total price
        } else {
          roomTotalPrices[index] = 0; // Reset if dates are invalid
        }
      } else {
        roomTotalPrices[index] = 0; // Reset if dates are not set
      }
    }
    setState(() {}); // Rebuild to reflect total price changes
  }

  Future<void> _pickStartDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDates[index] ?? now,
      firstDate: DateTime(now.year -
          1), // Allow selection from past for reference, or restrict to now.
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDates[index]) {
      setState(() {
        startDates[index] = picked;

        // Ensure end date is after start date
        if (endDates[index] != null &&
            startDates[index]!.isAfter(endDates[index]!)) {
          endDates[index] = null; // Reset end date if invalid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Tanggal mulai tidak boleh setelah atau sama dengan tanggal akhir.')),
          );
        }
        _calculateTotalPrice(); // Recalculate total price
      });
    }
  }

  Future<void> _pickEndDate(int index) async {
    if (startDates[index] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Silakan pilih tanggal mulai terlebih dahulu')));
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate:
          endDates[index] ?? startDates[index]!.add(const Duration(days: 1)),
      firstDate: startDates[index]!.add(const Duration(
          days: 1)), // Ensure end date is strictly after start date
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDates[index]) {
      setState(() {
        endDates[index] = picked;

        // Ensure start date is before end date (re-check if user changes end date to be before start date)
        if (endDates[index]!.isBefore(startDates[index]!) ||
            endDates[index]!.isAtSameMomentAs(startDates[index]!)) {
          // This case should ideally be prevented by `firstDate` in `showDatePicker`
          // for _pickEndDate. However, it's a good safety check.
          startDates[index] = null; // Reset start date if invalid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Tanggal akhir tidak boleh sebelum atau sama dengan tanggal mulai.')),
          );
        }
        _calculateTotalPrice(); // Recalculate total price
      });
    }
  }

  Future<void> _toggleRoomSelection(int index) async {
    // Before toggling selection, check for conflicts if selecting
    if (!selectedRoomIndices.contains(index)) {
      // Prompt user to select dates if not already selected for a new room
      // if (startDates[index] == null || endDates[index] == null) {
      //    ScaffoldMessenger.of(context).showSnackBar(
      //      const SnackBar(content: Text('Harap pilih tanggal mulai dan berakhir terlebih dahulu.')),
      //    );
      //    return;
      // }

      // Check for booking conflicts before allowing selection
      if (_isBookingConflict(index)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Kamar sudah dipesan untuk tanggal yang dipilih atau tanggal konflik dengan pemesanan yang ada.')),
        );
        return;
      }
    }

    setState(() {
      if (selectedRoomIndices.contains(index)) {
        selectedRoomIndices.remove(index);
        // Reset associated data when a room is deselected
        startDates[index] = null;
        endDates[index] = null;
        guestCounts[index] = 1; // Reset to default 1 guest
        roomTotalPrices[index] = 0;
      } else {
        selectedRoomIndices.add(index);
      }
      _calculateTotalPrice(); // Recalculate overall total price after selection change
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Hotel?>(
      future: Hotel.fetchHotelDetails(widget.hotelId), // Fetch hotel details
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          debugPrint(
              'HotelDetailPage: Error fetching hotel: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Hotel tidak ditemukan'));
        }

        final hotel = snapshot.data!; // Get hotel data

        return Scaffold(
          appBar: AppBar(
            title: const Text("Detail Hotel",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          bottomNavigationBar: selectedRoomIndices.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child:
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text('Total Harga: ${formatCurrency(totalPrice)}',
                      //         style: const TextStyle(fontWeight: FontWeight.bold)),
                      //     ElevatedButton(
                      //       onPressed: () async {
                      //         try {
                      //           // Check for booking conflicts before proceeding
                      //           for (var index in selectedRoomIndices) {
                      //             if (startDates[index] == null || endDates[index] == null) {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 const SnackBar(content: Text('Harap pilih tanggal untuk semua kamar yang dipilih.')),
                      //               );
                      //               return;
                      //             }
                      //             if (_isBookingConflict(index)) {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 const SnackBar(
                      //                     content: Text(
                      //                         'Satu atau lebih kamar sudah dipesan untuk tanggal yang dipilih atau tanggal konflik.')),
                      //               );
                      //               return;
                      //             }
                      //           }

                      //           // Proceed with booking if no conflicts are found
                      //           for (var index in selectedRoomIndices) {
                      //             final room = _rooms[index];

                      //             // Set tanggal, guest, dan total harga ke object Room untuk booking
                      //             room.startDate = startDates[index];
                      //             room.endDate = endDates[index];
                      //             room.guestCount = guestCounts[index]; // Use the selected guest count
                      //             room.totalPrice = roomTotalPrices[index];

                      //             // Call bookRoom from instance
                      //             await room.bookRoom(userId!); // Pass userId here
                      //           }

                      //           Navigator.of(context).popUntil((route) => route.isFirst);
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(content: Text("Pemesanan berhasil!"), backgroundColor: Colors.green),
                      //           );
                      //         } catch (e) {
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             SnackBar(content: Text('Pemesanan gagal: $e')),
                      //           );
                      //           debugPrint('Pemesanan gagal: $e');
                      //         }
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.deepPurple),
                      //       child: const Text("Pesan Sekarang",
                      //           style: TextStyle(color: Colors.white)),
                      //     ),
                      //   ],
                      // ),
                      Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total Harga: ${formatCurrency(totalPrice)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Spacer kecil antara teks dan tombol
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            for (var index in selectedRoomIndices) {
                              if (startDates[index] == null ||
                                  endDates[index] == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Harap pilih tanggal untuk semua kamar yang dipilih.')),
                                );
                                return;
                              }
                              if (_isBookingConflict(index)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Satu atau lebih kamar sudah dipesan untuk tanggal yang dipilih atau tanggal konflik.'),
                                  ),
                                );
                                return;
                              }
                            }

                            for (var index in selectedRoomIndices) {
                              final room = _rooms[index];
                              room.startDate = startDates[index];
                              room.endDate = endDates[index];
                              room.guestCount = guestCounts[index];
                              room.totalPrice = roomTotalPrices[index];
                              await room.bookRoom(userId!);
                            }

                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Pemesanan berhasil!"),
                                  backgroundColor: Colors.green),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pemesanan gagal: $e')),
                            );
                            debugPrint('Pemesanan gagal: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          "Pesan Sekarang",
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Banner
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: _hotelImageBytes != null
                      ? Image.memory(
                          _hotelImageBytes!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/hotel.png', // Default image
                          fit: BoxFit.cover,
                        ),
                ),

                // Hotel Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel.name,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text("${hotel.rating} / 5.0"),
                          const Spacer(),
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 4),
                          FutureBuilder<String>(
                            future:
                                Location.fetchLocationName(hotel.locationId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Memuat...");
                              } else if (snapshot.hasError) {
                                return const Text("Error");
                              } else {
                                return Text(
                                    snapshot.data ?? "Lokasi Tidak Diketahui");
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(hotel.description),
                      const SizedBox(height: 20),

                      // Amenities
                      const Text("Fasilitas",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Wrap(
                        // Using Wrap for better layout of amenities
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between lines
                        children: hotel.amenities
                            .map((item) => Chip(
                                  label: Text(item),
                                  backgroundColor: Colors.blue.shade50,
                                  labelStyle:
                                      const TextStyle(color: Colors.blue),
                                  avatar: const Icon(Icons.check_circle_outline,
                                      color: Colors.blue, size: 18),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 30),

                      // Room Options
                      const Text("Kamar Tersedia",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Column(
                        children: _rooms.asMap().entries.map((entry) {
                          int index = entry.key;
                          var room = entry
                              .value; // This room object now has the correct guestCount from Firestore
                          bool isSelected = selectedRoomIndices.contains(index);
                          String roomStatus = _getRoomStatus(index);

                          return RoomCard(
                            // Using a new widget for RoomCard
                            room:
                                room, // Pass the Room object with its actual guestCount
                            index: index,
                            isSelected: isSelected,
                            roomStatus: roomStatus,
                            formatCurrency: formatCurrency,
                            formatDate: formatDate,
                            startDates: startDates,
                            endDates: endDates,
                            guestCounts: guestCounts,
                            roomTotalPrices: roomTotalPrices,
                            pickStartDate: _pickStartDate,
                            pickEndDate: _pickEndDate,
                            toggleRoomSelection: _toggleRoomSelection,
                            calculateTotalPrice: _calculateTotalPrice,
                            userId: userId, // Pass userId to RoomCard
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extracted RoomCard into its own StatefulWidget for better organization and image loading
// The definition of RoomCard is below, assuming it's in the same file or imported.

class RoomCard extends StatefulWidget {
  final Room room; // Room object containing guestCount from Firestore
  final int index;
  final bool isSelected;
  final String roomStatus;
  final Function(double) formatCurrency;
  final Function(DateTime?) formatDate;
  final List<DateTime?> startDates;
  final List<DateTime?> endDates;
  final List<int>
      guestCounts; // This list holds *selected* guest count per room
  final List<double> roomTotalPrices;
  final Function(int) pickStartDate;
  final Function(int) pickEndDate;
  final Function(int) toggleRoomSelection;
  final VoidCallback calculateTotalPrice;
  final String? userId; // Pass userId to RoomCard

  const RoomCard({
    Key? key,
    required this.room, // Pass the Room object
    required this.index,
    required this.isSelected,
    required this.roomStatus,
    required this.formatCurrency,
    required this.formatDate,
    required this.startDates,
    required this.endDates,
    required this.guestCounts,
    required this.roomTotalPrices,
    required this.pickStartDate,
    required this.pickEndDate,
    required this.toggleRoomSelection,
    required this.calculateTotalPrice,
    required this.userId,
  }) : super(key: key);

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  Uint8List? _roomImageBytes;

  @override
  void initState() {
    super.initState();
    _loadRoomImage();
  }

  @override
  void didUpdateWidget(covariant RoomCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.room.id != oldWidget.room.id) {
      _loadRoomImage();
    }
  }

  Future<void> _loadRoomImage() async {
    final roomImagesBox = Hive.box<Uint8List>('room_images');
    final Uint8List? imageBytes = roomImagesBox.get(widget.room.id);

    debugPrint(
        'Attempting to load room image bytes for ID: ${widget.room.id} from Hive.');

    if (imageBytes != null) {
      setState(() {
        _roomImageBytes = imageBytes;
      });
      debugPrint(
          'Room image bytes found and loaded for ID: ${widget.room.id}.');
    } else {
      setState(() {
        _roomImageBytes = null; // No image bytes found in Hive
      });
      debugPrint(
          'Room image bytes not found for ID: ${widget.room.id} in Hive. Showing default.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the maximum guest capacity for this specific room from the Room object
    final int maxGuestCapacity =
        widget.room.guestCount ?? 1; // Default to 1 if not set in Firestore

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: widget.isSelected ? Colors.deepPurple : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _roomImageBytes != null
                  ? Image.memory(
                      _roomImageBytes!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/images/room.png", // Default image
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.type,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 8),
                Text("${widget.formatCurrency(widget.room.price)} / night",
                    style: const TextStyle(fontSize: 16)),
                // Display the room's maximum capacity fetched from Firestore
                Text(
                  'Kapasitas Maks: ${widget.room.guestCount ?? 'Belum Diset'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                const Text("Pemesanan Saat Ini:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (widget.room.bookings.isEmpty)
                  const Text("Tidak ada pemesanan saat ini."),
                ...widget.room.bookings.map((booking) {
                  return Text(
                    '> Dari ${widget.formatDate(booking.startDate)} Hingga ${widget.formatDate(booking.endDate)} - Total: ${widget.formatCurrency(booking.totalPrice)}',
                    style: TextStyle(
                      color: booking.userId == widget.userId
                          ? Colors.deepPurple[800]
                          : Colors.black54, // Dim other user's bookings
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),

                /// Date Pickers
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: widget.isSelected
                            ? () => widget.pickStartDate(widget.index)
                            : null,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          widget.startDates[widget.index] == null
                              ? 'Pilih Tanggal Mulai'
                              : 'Mulai: ${widget.formatDate(widget.startDates[widget.index]!)}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: widget.isSelected
                            ? () => widget.pickEndDate(widget.index)
                            : null,
                        icon: const Icon(Icons.date_range_outlined),
                        label: Text(
                          widget.endDates[widget.index] == null
                              ? 'Pilih Tanggal Akhir'
                              : 'Akhir: ${widget.formatDate(widget.endDates[widget.index]!)}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Guest Count Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: widget.isSelected &&
                              widget.guestCounts[widget.index] > 1
                          ? () {
                              setState(() {
                                widget.guestCounts[widget.index]--;
                                widget.calculateTotalPrice();
                              });
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: const Icon(Icons.remove),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      child: Text(
                        '${widget.guestCounts[widget.index]} Tamu${widget.guestCounts[widget.index] > 1 ? '' : ''}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: widget.isSelected &&
                              widget.guestCounts[widget.index] <
                                  maxGuestCapacity // **BATAS MAKSIMUM DI SINI**
                          ? () {
                              setState(() {
                                widget.guestCounts[widget.index]++;
                                widget.calculateTotalPrice();
                              });
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Total Price for this room
                if (widget.roomTotalPrices[widget.index] > 0 &&
                    widget.isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Harga Kamar: ${widget.formatCurrency(widget.roomTotalPrices[widget.index])}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green),
                    ),
                  ),

                /// Room Status
                if (widget.roomStatus.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: widget.roomStatus == "In Use"
                          ? Colors.red.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.roomStatus,
                      style: TextStyle(
                        color: widget.roomStatus == "In Use"
                            ? Colors.red
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                /// Choose Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.roomStatus == "In Use" ||
                            widget.roomStatus == "Booked by You"
                        ? null // Disable if in use or already booked by current user
                        : () {
                            widget.toggleRoomSelection(widget.index);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isSelected
                          ? Colors.blue
                          : (widget.roomStatus.isNotEmpty
                              ? Colors.grey[500]
                              : Colors.deepPurple), // Change color if disabled
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.isSelected ? "Terpilih" : "Pilih",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
