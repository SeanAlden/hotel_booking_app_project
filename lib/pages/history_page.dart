// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final currencyFormat = NumberFormat.currency(
//     locale: 'id_ID',
//     symbol: 'Rp ',
//     decimalDigits: 2,
//   );
//   final dateFormat = DateFormat('yyyy-MM-dd');
//   final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

//   String? userId; // Define userId variable

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser ?.uid; // Get current user ID
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'History List',
//           style: TextStyle(
//               fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('book_history')
//             .where('user_id', isEqualTo: userId) // Filter by user_id
//             .orderBy('created_at', descending: true)
//             .snapshots(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No booking history found.'));
//           }

//           final docs = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (ctx, i) {
//               final data = docs[i].data() as Map<String, dynamic>;

//               final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
//               final startDate = DateTime.tryParse(data['start_date'] ?? '');
//               final endDate = DateTime.tryParse(data['end_date'] ?? '');

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Booking Time : ${bookingTime != null ? dateTimeFormat.format(bookingTime) : '-'}',
//                         style: const TextStyle(
//                             fontSize: 13, fontWeight: FontWeight.w500),
//                       ),
//                       const Divider(),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[400],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(Icons.image, size: 30),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   data['hotel_name'] ?? 'Unknown Hotel',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Room Type : ${data['room_summary'] ?? '-'}',
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Duration : ${startDate != null ? dateFormat.format(startDate) : '-'} to ${endDate != null ? dateFormat.format(endDate) : '-'}',
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                           currencyFormat
//                                               .format(data['total_price'] ?? 0),
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 15)),
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         'Booking ID : ${data['booking_id'] ?? '-'}',
//                                         style: const TextStyle(
//                                             fontSize: 12,
//                                             overflow: TextOverflow.ellipsis),
//                                         maxLines: 2,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final currencyFormat = NumberFormat.currency(
//     locale: 'id_ID',
//     symbol: 'Rp ',
//     decimalDigits: 2,
//   );
//   final dateFormat = DateFormat('yyyy-MM-dd');
//   final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

//   String? userId; // Define userId variable

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser ?.uid; // Get current user ID
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'History List',
//           style: TextStyle(
//               fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('book_history')
//             .where('user_id', isEqualTo: userId) // Filter by user_id
//             .orderBy('created_at', descending: true)
//             .snapshots(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No booking history found.'));
//           }

//           final docs = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (ctx, i) {
//               final data = docs[i].data() as Map<String, dynamic>;

//               final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
//               final startDate = DateTime.tryParse(data['start_date'] ?? '');
//               final endDate = DateTime.tryParse(data['end_date'] ?? '');

//               // Determine the booking status
//               String bookingStatus;
//               if (startDate != null && endDate != null) {
//                 if (DateTime.now().isAfter(endDate)) {
//                   bookingStatus = "Done"; // Booking is done
//                 } else if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate)) {
//                   bookingStatus = "In Use"; // Booking is currently in use
//                 } else {
//                   bookingStatus = ""; // Booking is upcoming
//                 }
//               } else {
//                 bookingStatus = ""; // No valid dates
//               }

//               // Determine if the cancel button should be shown
//               bool showCancelButton = startDate != null &&
//                                       DateTime.now().isBefore(startDate.subtract(const Duration(days: 3)));

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Booking Time : ${bookingTime != null ? dateTimeFormat.format(bookingTime) : '-'}',
//                         style: const TextStyle(
//                             fontSize: 13, fontWeight: FontWeight.w500),
//                       ),
//                       const Divider(),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[400],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(Icons.image, size: 30),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   data['hotel_name'] ?? 'Unknown Hotel',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Room Type : ${data['room_summary'] ?? '-'}',
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Duration : ${startDate != null ? dateFormat.format(startDate) : '-'} to ${endDate != null ? dateFormat.format(endDate) : '-'}',
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                           currencyFormat
//                                               .format(data['total_price'] ?? 0),
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 15)),
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         'Booking ID : ${data['booking_id'] ?? '-'}',
//                                         style: const TextStyle(
//                                             fontSize: 12,
//                                             overflow: TextOverflow.ellipsis),
//                                         maxLines: 2,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 // Display booking status
//                                 if (bookingStatus.isNotEmpty)
//                                   Text(
//                                     bookingStatus,
//                                     style: TextStyle(
//                                       color: bookingStatus == "In Use" ? Colors.red : Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 // Cancel button
//                                 if (showCancelButton)
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       // Implement cancel booking logic here
//                                       _cancelBooking(data['booking_id']);
//                                     },
//                                     child: const Text("Cancel Book"),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _cancelBooking(String bookingId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .delete();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking cancelled successfully.')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to cancel booking: $e')),
//       );
//     }
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final currencyFormat = NumberFormat.currency(
//     locale: 'id_ID',
//     symbol: 'Rp ',
//     decimalDigits: 2,
//   );
//   final dateFormat = DateFormat('yyyy-MM-dd');
//   final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

//   String? userId; // Define userId variable

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser ?.uid; // Get current user ID
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'History List',
//           style: TextStyle(
//               fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('book_history')
//             .where('user_id', isEqualTo: userId) // Filter by user_id
//             .orderBy('created_at', descending: true)
//             .snapshots(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No booking history found.'));
//           }

//           final docs = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (ctx, i) {
//               final data = docs[i].data() as Map<String, dynamic>;

//               final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
//               final startDate = DateTime.tryParse(data['start_date'] ?? '');
//               final endDate = DateTime.tryParse(data['end_date'] ?? '');

//               // Determine the booking status
//               String bookingStatus;
//               if (startDate != null && endDate != null) {
//                 if (DateTime.now().isAfter(endDate)) {
//                   bookingStatus = "Done"; // Booking is done
//                 } else if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate)) {
//                   bookingStatus = "In Use"; // Booking is currently in use
//                 } else {
//                   bookingStatus = ""; // Booking is upcoming
//                 }
//               } else {
//                 bookingStatus = ""; // No valid dates
//               }

//               // Determine if the cancel button should be shown
//               bool showCancelButton = startDate != null &&
//                                       DateTime.now().isBefore(startDate.subtract(const Duration(days: 3)));

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Booking Time : ${bookingTime != null ? dateTimeFormat.format(bookingTime) : '-'}',
//                         style: const TextStyle(
//                             fontSize: 13, fontWeight: FontWeight.w500),
//                       ),
//                       const Divider(),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[400],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(Icons.image, size: 30),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   data['hotel_name'] ?? 'Unknown Hotel',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Room Type : ${data['room_summary'] ?? '-'}',
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Duration : ${startDate != null ? dateFormat.format(startDate) : '-'} to ${endDate != null ? dateFormat.format(endDate) : '-'}',
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                           currencyFormat
//                                               .format(data['total_price'] ?? 0),
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 15)),
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         'Booking ID : ${data['booking_id'] ?? '-'}',
//                                         style: const TextStyle(
//                                             fontSize: 12,
//                                             overflow: TextOverflow.ellipsis),
//                                         maxLines: 2,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 // Display booking status
//                                 if (bookingStatus.isNotEmpty)
//                                   Text(
//                                     bookingStatus,
//                                     style: TextStyle(
//                                       color: bookingStatus == "In Use" ? Colors.red : Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 // Cancel button
//                                 if (showCancelButton)
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       _showCancelConfirmationDialog(data['booking_id']);
//                                     },
//                                     child: const Text("Cancel Book"),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _showCancelConfirmationDialog(String bookingId) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // User must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Cancellation'),
//           content: const Text('Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//             TextButton(
//               child: const Text('Yes'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 _cancelBooking(bookingId); // Proceed with cancellation
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _cancelBooking(String bookingId) async {
//     try {
//       // Get the booking data to store in canceled bookings
//       final bookingSnapshot = await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .get();

//       if (bookingSnapshot.exists) {
//         final bookingData = bookingSnapshot.data() as Map<String, dynamic>;

//         // Store the canceled booking in a new collection
//         await FirebaseFirestore.instance.collection('canceled_bookings').add({
//           ...bookingData,
//           'cancellation_time': FieldValue.serverTimestamp(), // Add cancellation time
//         });
//       }

//       // Delete the original booking
//       await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking cancelled successfully.')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to cancel booking: $e')),
//       );
//     }
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final currencyFormat = NumberFormat.currency(
//     locale: 'id_ID',
//     symbol: 'Rp ',
//     decimalDigits: 2,
//   );
//   final dateFormat = DateFormat('yyyy-MM-dd');
//   final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

//   String? userId; // Define userId variable

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser ?.uid; // Get current user ID
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2, // Number of tabs
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'History List',
//             style: TextStyle(
//                 fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blue,
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Active'),
//               Tab(text: 'Cancelled'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildActiveBookings(),
//             _buildCancelledBookings(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActiveBookings() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('book_history')
//           .where('user_id', isEqualTo: userId) // Filter by user_id
//           .orderBy('created_at', descending: true)
//           .snapshots(),
//       builder: (ctx, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No active bookings found.'));
//         }

//         final docs = snapshot.data!.docs;

//         return ListView.builder(
//           itemCount: docs.length,
//           itemBuilder: (ctx, i) {
//             final data = docs[i].data() as Map<String, dynamic>;

//             final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
//             final startDate = DateTime.tryParse(data['start_date'] ?? '');
//             final endDate = DateTime.tryParse(data['end_date'] ?? '');

//             // Determine the booking status
//             String bookingStatus;
//             if (startDate != null && endDate != null) {
//               if (DateTime.now().isAfter(endDate)) {
//                 bookingStatus = "Done"; // Booking is done
//               } else if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate)) {
//                 bookingStatus = "In Use"; // Booking is currently in use
//               } else {
//                 bookingStatus = ""; // Booking is upcoming
//               }
//             } else {
//               bookingStatus = ""; // No valid dates
//             }

//             // Determine if the cancel button should be shown
//             bool showCancelButton = startDate != null &&
//                                     DateTime.now().isBefore(startDate.subtract(const Duration(days: 3)));

//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Booking Time : ${bookingTime != null ? dateTimeFormat.format(bookingTime) : '-'}',
//                       style: const TextStyle(
//                           fontSize: 13, fontWeight: FontWeight.w500),
//                     ),
//                     const Divider(),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[400],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(Icons.image, size: 30),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 data['hotel_name'] ?? 'Unknown Hotel',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Room Type : ${data['room_summary'] ?? '-'}',
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Duration : ${startDate != null ? dateFormat.format(startDate) : '-'} to ${endDate != null ? dateFormat.format(endDate) : '-'}',
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                         currencyFormat.format(data['total_price'] ?? 0),
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 15)),
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       'Booking ID : ${data['booking_id'] ?? '-'}',
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           overflow: TextOverflow.ellipsis),
//                                       maxLines: 2,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               // Display booking status
//                               if (bookingStatus.isNotEmpty)
//                                 Text(
//                                   bookingStatus,
//                                   style: TextStyle(
//                                     color: bookingStatus == "In Use" ? Colors.red : Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               // Cancel button
//                               if (showCancelButton)
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     _showCancelConfirmationDialog(data['booking_id']);
//                                   },
//                                   child: const Text("Cancel Book"),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildCancelledBookings() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('canceled_bookings')
//           .where('user_id', isEqualTo: userId) // Filter by user_id
//           .orderBy('cancellation_time', descending: true)
//           .snapshots(),
//       builder: (ctx, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No cancelled bookings found.'));
//         }

//         final docs = snapshot.data!.docs;

//         return ListView.builder(
//           itemCount: docs.length,
//           itemBuilder: (ctx, i) {
//             final data = docs[i].data() as Map<String, dynamic>;

//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Cancelled Booking Time : ${data['cancellation_time'] != null ? dateTimeFormat.format((data['cancellation_time'] as Timestamp).toDate()) : '-'}',
//                       style: const TextStyle(
//                           fontSize: 13, fontWeight: FontWeight.w500),
//                     ),
//                     const Divider(),
//                     Text(
//                       'Hotel Name: ${data['hotel_name'] ?? 'Unknown Hotel'}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Room Type: ${data['room_summary'] ?? '-'}',
//                       style: const TextStyle(fontSize: 13),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Total Price: ${currencyFormat.format(data['total_price'] ?? 0)}',
//                       style: const TextStyle(fontSize: 13),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Booking ID: ${data['booking_id'] ?? '-'}',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _showCancelConfirmationDialog(String bookingId) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // User must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Cancellation'),
//           content: const Text('Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//             TextButton(
//               child: const Text('Yes'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 _cancelBooking(bookingId); // Proceed with cancellation
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _cancelBooking(String bookingId) async {
//     try {
//       // Get the booking data to store in canceled bookings
//       final bookingSnapshot = await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .get();

//       if (bookingSnapshot.exists) {
//         final bookingData = bookingSnapshot.data() as Map<String, dynamic>;

//         // Store the canceled booking in a new collection
//         await FirebaseFirestore.instance.collection('canceled_bookings').add({
//           ...bookingData,
//           'cancellation_time': FieldValue.serverTimestamp(), // Add cancellation time
//         });
//       }

//       // Delete the original booking
//       await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking cancelled successfully.')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to cancel booking: $e')),
//       );
//     }
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final currencyFormat = NumberFormat.currency(
//     locale: 'id_ID',
//     symbol: 'Rp ',
//     decimalDigits: 2,
//   );
//   final dateFormat = DateFormat('yyyy-MM-dd');
//   final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

//   String? userId; // Define userId variable
//   String searchQuery = '';
//   DateTime? startDate;
//   DateTime? endDate;

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser ?.uid; // Get current user ID
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2, // Number of tabs
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'History List',
//             style: TextStyle(
//                 fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blue,
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Active'),
//               Tab(text: 'Cancelled'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildActiveBookings(),
//             _buildCancelledBookings(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActiveBookings() {
//     return Column(
//       children: [
//         _buildSearchBar(),
//         _buildDatePicker(),
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('book_history')
//                 .where('user_id', isEqualTo: userId) // Filter by user_id
//                 .orderBy('created_at', descending: true)
//                 .snapshots(),
//             builder: (ctx, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return const Center(child: Text('No active bookings found.'));
//               }

//               final docs = snapshot.data!.docs.where((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 final hotelName = data['hotel_name']?.toLowerCase() ?? '';
//                 final roomType = data['room_summary']?.toLowerCase() ?? '';
//                 final bookingId = data['booking_id']?.toLowerCase() ?? '';
//                 final totalPrice = data['total_price']?.toString() ?? '';

//                 // Check if the search query matches any of the fields
//                 final matchesSearchQuery = hotelName.contains(searchQuery.toLowerCase()) ||
//                     roomType.contains(searchQuery.toLowerCase()) ||
//                     bookingId.contains(searchQuery.toLowerCase()) ||
//                     totalPrice.contains(searchQuery);

//                 // Check if the booking date is within the selected range
//                 final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
//                 final isWithinDateRange = (startDate == null || bookingTime!.isAfter(startDate!)) &&
//                                            (endDate == null || bookingTime!.isBefore(endDate!.add(const Duration(days: 1))));

//                 return matchesSearchQuery && isWithinDateRange;
//               }).toList();

//               return ListView.builder(
//                 itemCount: docs.length,
//                 itemBuilder: (ctx, i) {
//                   final data = docs[i].data() as Map<String, dynamic>;

//                   final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
//                   final startDate = DateTime.tryParse(data['start_date'] ?? '');
//                   final endDate = DateTime.tryParse(data['end_date'] ?? '');

//                   // Determine the booking status
//                   String bookingStatus;
//                   if (startDate != null && endDate != null) {
//                     if (DateTime.now().isAfter(endDate)) {
//                       bookingStatus = "Done"; // Booking is done
//                     } else if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate)) {
//                       bookingStatus = "In Use"; // Booking is currently in use
//                     } else {
//                       bookingStatus = ""; // Booking is upcoming
//                     }
//                   } else {
//                     bookingStatus = ""; // No valid dates
//                   }

//                   // Determine if the cancel button should be shown
//                   bool showCancelButton = startDate != null &&
//                                           DateTime.now().isBefore(startDate.subtract(const Duration(days: 3)));

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Booking Time : ${bookingTime != null ? dateTimeFormat.format(bookingTime) : '-'}',
//                             style: const TextStyle(
//                                 fontSize: 13, fontWeight: FontWeight.w500),
//                           ),
//                           const Divider(),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 width: 50,
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[400],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Icon(Icons.image, size: 30),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       data['hotel_name'] ?? 'Unknown Hotel',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Room Type : ${data['room_summary'] ?? '-'}',
//                                       style: const TextStyle(fontSize: 13),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Duration : ${startDate != null ? dateFormat.format(startDate) : '-'} to ${endDate != null ? dateFormat.format(endDate) : '-'}',
//                                       style: const TextStyle(fontSize: 13),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                               currencyFormat.format(data['total_price'] ?? 0),
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 15)),
//                                         ),
//                                         Expanded(
//                                           child: Text(
//                                             'Booking ID : ${data['booking_id'] ?? '-'}',
//                                             style: const TextStyle(
//                                                 fontSize: 12,
//                                                 overflow: TextOverflow.ellipsis),
//                                             maxLines: 2,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     // Display booking status
//                                     if (bookingStatus.isNotEmpty)
//                                       Text(
//                                         bookingStatus,
//                                         style: TextStyle(
//                                           color: bookingStatus == "In Use" ? Colors.red : Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     // Cancel button
//                                     if (showCancelButton)
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           _showCancelConfirmationDialog(data['booking_id']);
//                                         },
//                                         child: const Text("Cancel Book"),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCancelledBookings() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('canceled_bookings')
//           .where('user_id', isEqualTo: userId) // Filter by user_id
//           .orderBy('cancellation_time', descending: true)
//           .snapshots(),
//       builder: (ctx, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No cancelled bookings found.'));
//         }

//         final docs = snapshot.data!.docs;

//         return ListView.builder(
//           itemCount: docs.length,
//           itemBuilder: (ctx, i) {
//             final data = docs[i].data() as Map<String, dynamic>;

//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Cancelled Booking Time : ${data['cancellation_time'] != null ? dateTimeFormat.format((data['cancellation_time'] as Timestamp).toDate()) : '-'}',
//                       style: const TextStyle(
//                           fontSize: 13, fontWeight: FontWeight.w500),
//                     ),
//                     const Divider(),
//                     Text(
//                       'Hotel Name: ${data['hotel_name'] ?? 'Unknown Hotel'}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Room Type: ${data['room_summary'] ?? '-'}',
//                       style: const TextStyle(fontSize: 13),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Total Price: ${currencyFormat.format(data['total_price'] ?? 0)}',
//                       style: const TextStyle(fontSize: 13),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Booking ID: ${data['booking_id'] ?? '-'}',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _showCancelConfirmationDialog(String bookingId) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // User must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Cancellation'),
//           content: const Text('Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//             TextButton(
//               child: const Text('Yes'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 _cancelBooking(bookingId); // Proceed with cancellation
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _cancelBooking(String bookingId) async {
//     try {
//       // Get the booking data to store in canceled bookings
//       final bookingSnapshot = await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .get();

//       if (bookingSnapshot.exists) {
//         final bookingData = bookingSnapshot.data() as Map<String, dynamic>;

//         // Store the canceled booking in a new collection
//         await FirebaseFirestore.instance.collection('canceled_bookings').add({
//           ...bookingData,
//           'cancellation_time': FieldValue.serverTimestamp(), // Add cancellation time
//         });
//       }

//       // Delete the original booking
//       await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking cancelled successfully.')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to cancel booking: $e')),
//       );
//     }
//   }

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         decoration: InputDecoration(
//           labelText: 'Search',
//           border: OutlineInputBorder(),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               setState(() {
//                 searchQuery = ''; // Clear the search query
//               });
//             },
//           ),
//         ),
//         onChanged: (value) {
//           setState(() {
//             searchQuery = value; // Update the search query
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildDatePicker() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         ElevatedButton(
//           onPressed: () async {
//             DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: startDate ?? DateTime.now(),
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2101),
//             );
//             if (pickedDate != null) {
//               setState(() {
//                 startDate = pickedDate; // Set the start date
//               });
//             }
//           },
//           child: const Text('Select Start Date'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: endDate ?? DateTime.now(),
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2101),
//             );
//             if (pickedDate != null) {
//               setState(() {
//                 endDate = pickedDate; // Set the end date
//               });
//             }
//           },
//           child: const Text('Select End Date'),
//         ),
//       ],
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );
  final dateFormat = DateFormat('yyyy-MM-dd');
  final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String? userId; // Define userId variable
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'History List',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          bottom:
              // const TabBar(
              //   tabs: [
              //     Tab(text: 'Active'),
              //     Tab(text: 'Cancelled'),
              //   ],
              // ),

              TabBar(
            labelColor: Colors.white, // Warna teks tab yang aktif
            unselectedLabelColor:
                Colors.white70, // Warna teks tab yang tidak aktif
            indicatorColor: Colors.white, // Warna garis indikator di bawah tab
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveBookings(),
            _buildCancelledBookings(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookings() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildDatePicker(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('book_history')
                .where('user_id', isEqualTo: userId) // Filter by user_id
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No active bookings found.'));
              }

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final hotelName = data['hotel_name']?.toLowerCase() ?? '';
                final roomType = data['room_summary']?.toLowerCase() ?? '';
                final bookingId = data['booking_id']?.toLowerCase() ?? '';
                final totalPrice = data['total_price']?.toString() ?? '';

                // Check if the search query matches any of the fields
                final matchesSearchQuery =
                    hotelName.contains(searchQuery.toLowerCase()) ||
                        roomType.contains(searchQuery.toLowerCase()) ||
                        bookingId.contains(searchQuery.toLowerCase()) ||
                        totalPrice.contains(searchQuery);

                // Check if the booking date is within the selected range
                final bookingTime =
                    (data['created_at'] as Timestamp?)?.toDate();
                final isWithinDateRange = (startDate == null ||
                        bookingTime!.isAfter(startDate!)) &&
                    (endDate == null ||
                        bookingTime!
                            .isBefore(endDate!.add(const Duration(days: 1))));

                return matchesSearchQuery && isWithinDateRange;
              }).toList();

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final data = docs[i].data() as Map<String, dynamic>;

                  final bookingTime =
                      (data['created_at'] as Timestamp?)?.toDate();
                  final startDate = DateTime.tryParse(data['start_date'] ?? '');
                  final endDate = DateTime.tryParse(data['end_date'] ?? '');

                  // Determine the booking status
                  String bookingStatus;
                  if (startDate != null && endDate != null) {
                    if (DateTime.now().isAfter(endDate)) {
                      bookingStatus = "Done"; // Booking is done
                    } else if (DateTime.now().isAfter(startDate) &&
                        DateTime.now().isBefore(endDate)) {
                      bookingStatus = "In Use"; // Booking is currently in use
                    } else {
                      bookingStatus = ""; // Booking is upcoming
                    }
                  } else {
                    bookingStatus = ""; // No valid dates
                  }

                  // Determine if the cancel button should be shown
                  bool showCancelButton = startDate != null &&
                      DateTime.now().isBefore(
                          startDate.subtract(const Duration(days: 3)));

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Time : ${bookingTime != null ? dateTimeFormat.format(bookingTime) : '-'}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: 
                                const Icon(Icons.image, size: 30),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['hotel_name'] ?? 'Unknown Hotel',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Room Type : ${data['room_summary'] ?? '-'}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Duration : ${startDate != null ? dateFormat.format(startDate) : '-'} to ${endDate != null ? dateFormat.format(endDate) : '-'}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                              currencyFormat.format(
                                                  data['total_price'] ?? 0),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Booking ID : ${data['booking_id'] ?? '-'}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Display booking status
                                    if (bookingStatus.isNotEmpty)
                                      Text(
                                        bookingStatus,
                                        style: TextStyle(
                                          color: bookingStatus == "In Use"
                                              ? Colors.red
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    // Cancel button
                                    if (showCancelButton)
                                      // ElevatedButton(
                                      //   onPressed: () {
                                      //     _showCancelConfirmationDialog(data['booking_id']);
                                      //   },
                                      //   child: const Text("Cancel Book", style: TextStyle(color: Colors.white),)
                                      //   ,
                                      // ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _showCancelConfirmationDialog(
                                              data['booking_id']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          "Cancel Book",
                                          style: TextStyle(
                                              color: Colors
                                                  .white), // Warna teks putih
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledBookings() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('canceled_bookings')
          .where('user_id', isEqualTo: userId) // Filter by user_id
          .orderBy('cancellation_time', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No cancelled bookings found.'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancelled Booking Time : ${data['cancellation_time'] != null ? dateTimeFormat.format((data['cancellation_time'] as Timestamp).toDate()) : '-'}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Divider(),
                    Text(
                      'Hotel Name: ${data['hotel_name'] ?? 'Unknown Hotel'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room Type: ${data['room_summary'] ?? '-'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Price: ${currencyFormat.format(data['total_price'] ?? 0)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking ID: ${data['booking_id'] ?? '-'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCancelConfirmationDialog(String bookingId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text(
              'Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _cancelBooking(bookingId); // Proceed with cancellation
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      // Get the booking data to store in canceled bookings
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('book_history')
          .doc(bookingId)
          .get();

      if (bookingSnapshot.exists) {
        final bookingData = bookingSnapshot.data() as Map<String, dynamic>;

        // Store the canceled booking in a new collection
        await FirebaseFirestore.instance.collection('canceled_bookings').add({
          ...bookingData,
          'cancellation_time':
              FieldValue.serverTimestamp(), // Add cancellation time
        });
      }

      // Delete the original booking
      await FirebaseFirestore.instance
          .collection('book_history')
          .doc(bookingId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking: $e')),
      );
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                searchQuery = ''; // Clear the search query
              });
            },
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value; // Update the search query
          });
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     ElevatedButton(
        //       onPressed: () async {
        //         DateTime? pickedDate = await showDatePicker(
        //           context: context,
        //           initialDate: startDate ?? DateTime.now(),
        //           firstDate: DateTime(2000),
        //           lastDate: DateTime(2101),
        //         );
        //         if (pickedDate != null) {
        //           setState(() {
        //             startDate = pickedDate; // Set the start date
        //           });
        //         }
        //       },
        //       child: const Text('Select Start Date'),
        //     ),
        //     ElevatedButton(
        //       onPressed: () async {
        //         DateTime? pickedDate = await showDatePicker(
        //           context: context,
        //           initialDate: endDate ?? DateTime.now(),
        //           firstDate: DateTime(2000),
        //           lastDate: DateTime(2101),
        //         );
        //         if (pickedDate != null) {
        //           setState(() {
        //             endDate = pickedDate; // Set the end date
        //           });
        //         }
        //       },
        //       child: const Text('Select End Date'),
        //     ),
        //   ],
        // ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     ElevatedButton.icon(
        //       onPressed: () async {
        //         // Step 1: Pick Start Date
        //         DateTime? pickedStartDate = await showDatePicker(
        //           context: context,
        //           initialDate: startDate ?? DateTime.now(),
        //           firstDate: DateTime(2000),
        //           lastDate: DateTime(2101),
        //         );

        //         if (pickedStartDate != null) {
        //           // Step 2: Pick End Date after Start Date
        //           DateTime? pickedEndDate = await showDatePicker(
        //             context: context,
        //             initialDate: pickedStartDate,
        //             firstDate: pickedStartDate, // Ensure end date >= start date
        //             lastDate: DateTime(2101),
        //           );

        //           if (pickedEndDate != null) {
        //             setState(() {
        //               startDate = pickedStartDate;
        //               endDate = pickedEndDate;
        //             });
        //           }
        //         }
        //       },
        //       icon: const Icon(Icons.calendar_today, color: Colors.white),
        //       label: const Text('Select Date Range',
        //           style: TextStyle(color: Colors.white)),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.blue,
        //         padding:
        //             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //       ),
        //     ),
        //   ],
        // ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tombol pilih tanggal
            ElevatedButton.icon(
              onPressed: () async {
                // Step 1: Pilih tanggal mulai
                DateTime? pickedStartDate = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedStartDate != null) {
                  // Step 2: Pilih tanggal akhir setelah tanggal mulai
                  DateTime? pickedEndDate = await showDatePicker(
                    context: context,
                    initialDate: pickedStartDate,
                    firstDate: pickedStartDate,
                    lastDate: DateTime(2101),
                  );

                  if (pickedEndDate != null) {
                    setState(() {
                      startDate = pickedStartDate;
                      endDate = pickedEndDate;
                    });
                  }
                }
              },
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: const Text('Select Date Range',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            // Tombol clear filter
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                });
              },
              icon: const Icon(Icons.clear, color: Colors.white),
              label: const Text('Clear Filter',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Display selected date range

        // Text(
        //   'Selected Date Range: ${startDate != null ? dateFormat.format(startDate!) : 'Not selected'} to ${endDate != null ? dateFormat.format(endDate!) : 'Not selected'}',
        //   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        // ),

        if (startDate != null && endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selected: ${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
