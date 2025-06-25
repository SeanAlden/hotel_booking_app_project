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
//     userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
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
//           bottom:
//               // const TabBar(
//               //   tabs: [
//               //     Tab(text: 'Active'),
//               //     Tab(text: 'Cancelled'),
//               //   ],
//               // ),

//               TabBar(
//             labelColor: Colors.white, // Warna teks tab yang aktif
//             unselectedLabelColor:
//                 Colors.white70, // Warna teks tab yang tidak aktif
//             indicatorColor: Colors.white, // Warna garis indikator di bawah tab
//             tabs: const [
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
//                 final matchesSearchQuery =
//                     hotelName.contains(searchQuery.toLowerCase()) ||
//                         roomType.contains(searchQuery.toLowerCase()) ||
//                         bookingId.contains(searchQuery.toLowerCase()) ||
//                         totalPrice.contains(searchQuery);

//                 // Check if the booking date is within the selected range
//                 final bookingTime =
//                     (data['created_at'] as Timestamp?)?.toDate();
//                 final isWithinDateRange = (startDate == null ||
//                         bookingTime!.isAfter(startDate!)) &&
//                     (endDate == null ||
//                         bookingTime!
//                             .isBefore(endDate!.add(const Duration(days: 1))));

//                 return matchesSearchQuery && isWithinDateRange;
//               }).toList();

//               return ListView.builder(
//                 itemCount: docs.length,
//                 itemBuilder: (ctx, i) {
//                   final data = docs[i].data() as Map<String, dynamic>;

//                   final bookingTime =
//                       (data['created_at'] as Timestamp?)?.toDate();
//                   final startDate = DateTime.tryParse(data['start_date'] ?? '');
//                   final endDate = DateTime.tryParse(data['end_date'] ?? '');

//                   // Determine the booking status
//                   String bookingStatus;
//                   if (startDate != null && endDate != null) {
//                     if (DateTime.now().isAfter(endDate)) {
//                       bookingStatus = "Done"; // Booking is done
//                     } else if (DateTime.now().isAfter(startDate) &&
//                         DateTime.now().isBefore(endDate)) {
//                       bookingStatus = "In Use"; // Booking is currently in use
//                     } else {
//                       bookingStatus = ""; // Booking is upcoming
//                     }
//                   } else {
//                     bookingStatus = ""; // No valid dates
//                   }

//                   // Determine if the cancel button should be shown
//                   bool showCancelButton = startDate != null &&
//                       DateTime.now().isBefore(
//                           startDate.subtract(const Duration(days: 1)));

//                   return Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
//                                 child: 
//                                 const Icon(Icons.image, size: 30),
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
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                               currencyFormat.format(
//                                                   data['total_price'] ?? 0),
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 15)),
//                                         ),
//                                         Expanded(
//                                           child: Text(
//                                             'Booking ID : ${data['booking_id'] ?? '-'}',
//                                             style: const TextStyle(
//                                                 fontSize: 12,
//                                                 overflow:
//                                                     TextOverflow.ellipsis),
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
//                                           color: bookingStatus == "In Use"
//                                               ? Colors.red
//                                               : Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     // Cancel button
//                                     if (showCancelButton)
//                                       // ElevatedButton(
//                                       //   onPressed: () {
//                                       //     _showCancelConfirmationDialog(data['booking_id']);
//                                       //   },
//                                       //   child: const Text("Cancel Book", style: TextStyle(color: Colors.white),)
//                                       //   ,
//                                       // ),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           _showCancelConfirmationDialog(
//                                               data['booking_id']);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.blue,
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 20, vertical: 12),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           "Cancel Book",
//                                           style: TextStyle(
//                                               color: Colors
//                                                   .white), // Warna teks putih
//                                         ),
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
//           content: const Text(
//               'Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
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
//           'cancellation_time':
//               FieldValue.serverTimestamp(), // Add cancellation time
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
//     return Column(
//       children: [
//         // Row(
//         //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         //   children: [
//         //     ElevatedButton(
//         //       onPressed: () async {
//         //         DateTime? pickedDate = await showDatePicker(
//         //           context: context,
//         //           initialDate: startDate ?? DateTime.now(),
//         //           firstDate: DateTime(2000),
//         //           lastDate: DateTime(2101),
//         //         );
//         //         if (pickedDate != null) {
//         //           setState(() {
//         //             startDate = pickedDate; // Set the start date
//         //           });
//         //         }
//         //       },
//         //       child: const Text('Select Start Date'),
//         //     ),
//         //     ElevatedButton(
//         //       onPressed: () async {
//         //         DateTime? pickedDate = await showDatePicker(
//         //           context: context,
//         //           initialDate: endDate ?? DateTime.now(),
//         //           firstDate: DateTime(2000),
//         //           lastDate: DateTime(2101),
//         //         );
//         //         if (pickedDate != null) {
//         //           setState(() {
//         //             endDate = pickedDate; // Set the end date
//         //           });
//         //         }
//         //       },
//         //       child: const Text('Select End Date'),
//         //     ),
//         //   ],
//         // ),

//         // Row(
//         //   mainAxisAlignment: MainAxisAlignment.center,
//         //   children: [
//         //     ElevatedButton.icon(
//         //       onPressed: () async {
//         //         // Step 1: Pick Start Date
//         //         DateTime? pickedStartDate = await showDatePicker(
//         //           context: context,
//         //           initialDate: startDate ?? DateTime.now(),
//         //           firstDate: DateTime(2000),
//         //           lastDate: DateTime(2101),
//         //         );

//         //         if (pickedStartDate != null) {
//         //           // Step 2: Pick End Date after Start Date
//         //           DateTime? pickedEndDate = await showDatePicker(
//         //             context: context,
//         //             initialDate: pickedStartDate,
//         //             firstDate: pickedStartDate, // Ensure end date >= start date
//         //             lastDate: DateTime(2101),
//         //           );

//         //           if (pickedEndDate != null) {
//         //             setState(() {
//         //               startDate = pickedStartDate;
//         //               endDate = pickedEndDate;
//         //             });
//         //           }
//         //         }
//         //       },
//         //       icon: const Icon(Icons.calendar_today, color: Colors.white),
//         //       label: const Text('Select Date Range',
//         //           style: TextStyle(color: Colors.white)),
//         //       style: ElevatedButton.styleFrom(
//         //         backgroundColor: Colors.blue,
//         //         padding:
//         //             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         //       ),
//         //     ),
//         //   ],
//         // ),

//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             // Tombol pilih tanggal
//             ElevatedButton.icon(
//               onPressed: () async {
//                 // Step 1: Pilih tanggal mulai
//                 DateTime? pickedStartDate = await showDatePicker(
//                   context: context,
//                   initialDate: startDate ?? DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2101),
//                 );

//                 if (pickedStartDate != null) {
//                   // Step 2: Pilih tanggal akhir setelah tanggal mulai
//                   DateTime? pickedEndDate = await showDatePicker(
//                     context: context,
//                     initialDate: pickedStartDate,
//                     firstDate: pickedStartDate,
//                     lastDate: DateTime(2101),
//                   );

//                   if (pickedEndDate != null) {
//                     setState(() {
//                       startDate = pickedStartDate;
//                       endDate = pickedEndDate;
//                     });
//                   }
//                 }
//               },
//               icon: const Icon(Icons.calendar_today, color: Colors.white),
//               label: const Text('Select Date Range',
//                   style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),

//             // Tombol clear filter
//             ElevatedButton.icon(
//               onPressed: () {
//                 setState(() {
//                   startDate = null;
//                   endDate = null;
//                 });
//               },
//               icon: const Icon(Icons.clear, color: Colors.white),
//               label: const Text('Clear Filter',
//                   style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         // Display selected date range

//         // Text(
//         //   'Selected Date Range: ${startDate != null ? dateFormat.format(startDate!) : 'Not selected'} to ${endDate != null ? dateFormat.format(endDate!) : 'Not selected'}',
//         //   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         // ),

//         if (startDate != null && endDate != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Text(
//               'Selected: ${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//       ],
//     );
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'dart:typed_data'; // For Uint8List
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

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
//     userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
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
//           automaticallyImplyLeading: false,
//           centerTitle: true,
//           backgroundColor: Colors.blue,
//           bottom:
//               TabBar(
//             labelColor: Colors.white, // Active tab text color
//             unselectedLabelColor:
//                 Colors.white70, // Inactive tab text color
//             indicatorColor: Colors.white, // Tab indicator line color
//             tabs: const [
//               Tab(text: 'History'),
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
//                 final totalPriceString = (data['total_price'] as num?)?.toString() ?? '';

//                 // Check if the search query matches any of the fields
//                 final matchesSearchQuery =
//                     hotelName.contains(searchQuery.toLowerCase()) ||
//                     roomType.contains(searchQuery.toLowerCase()) ||
//                     bookingId.contains(searchQuery.toLowerCase()) ||
//                     totalPriceString.contains(searchQuery);

//                 // Check if the booking date is within the selected range
//                 final bookingTime =
//                     (data['created_at'] as Timestamp?)?.toDate();
//                 final isWithinDateRange = (startDate == null ||
//                         (bookingTime != null && bookingTime.isAfter(startDate!))) &&
//                     (endDate == null ||
//                         (bookingTime != null && bookingTime.isBefore(endDate!.add(const Duration(days: 1)))));

//                 return matchesSearchQuery && isWithinDateRange;
//               }).toList();

//               if (docs.isEmpty) {
//                 return Center(child: Text('No active bookings found matching your criteria.'));
//               }

//               return ListView.builder(
//                 itemCount: docs.length,
//                 itemBuilder: (ctx, i) {
//                   final data = docs[i].data() as Map<String, dynamic>;
//                   final docId = docs[i].id; // Get the Firestore document ID

//                   final bookingTime =
//                       (data['created_at'] as Timestamp?)?.toDate();
//                   final startDateBooking = DateTime.tryParse(data['start_date'] ?? '');
//                   final endDateBooking = DateTime.tryParse(data['end_date'] ?? '');

//                   // Determine the booking status
//                   String bookingStatus;
//                   if (startDateBooking != null && endDateBooking != null) {
//                     if (DateTime.now().isAfter(endDateBooking)) {
//                       bookingStatus = "Done"; // Booking is done
//                     } else if (DateTime.now().isAfter(startDateBooking) &&
//                         DateTime.now().isBefore(endDateBooking)) {
//                       bookingStatus = "In Use"; // Booking is currently in use
//                     } else {
//                       bookingStatus = ""; // Booking is upcoming
//                     }
//                   } else {
//                     bookingStatus = ""; // No valid dates
//                   }

//                   // Determine if the cancel button should be shown
//                   bool showCancelButton = startDateBooking != null &&
//                       DateTime.now().isBefore(
//                           startDateBooking.subtract(const Duration(days: 1)));

//                   // Extract hotelId from booking data
//                   final hotelId = data['hotel_id'] as String?;

//                   return Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
//                               // Hotel image from Hive
//                               _HistoryBookingImage(hotelId: hotelId), // Pass hotelId
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
//                                       'Duration : ${startDateBooking != null ? dateFormat.format(startDateBooking) : '-'} to ${endDateBooking != null ? dateFormat.format(endDateBooking) : '-'}',
//                                       style: const TextStyle(fontSize: 13),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                               currencyFormat.format(
//                                                   data['total_price'] ?? 0),
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 15)),
//                                         ),
//                                         Expanded(
//                                           child: Text(
//                                             'Booking ID : ${data['booking_id'] ?? '-'}',
//                                             style: const TextStyle(
//                                                 fontSize: 12,
//                                                 overflow:
//                                                     TextOverflow.ellipsis),
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
//                                           color: bookingStatus == "In Use"
//                                               ? Colors.red
//                                               : Colors.black, // Color for "Done" and upcoming
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     // Cancel button
//                                     if (showCancelButton)
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           _showCancelConfirmationDialog(
//                                               docId); // Use docId for cancellation
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.blue,
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 20, vertical: 12),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           "Cancel Book",
//                                           style: TextStyle(
//                                               color: Colors
//                                                   .white), // White text color
//                                         ),
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
//             final hotelId = data['hotel_id'] as String?; // Extract hotelId

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
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _HistoryBookingImage(hotelId: hotelId), // Pass hotelId
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Hotel Name: ${data['hotel_name'] ?? 'Unknown Hotel'}',
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Room Type: ${data['room_summary'] ?? '-'}',
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Total Price: ${currencyFormat.format(data['total_price'] ?? 0)}',
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Booking ID: ${data['booking_id'] ?? '-'}',
//                                 style: const TextStyle(fontSize: 12),
//                               ),
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

//   Future<void> _showCancelConfirmationDialog(String bookingId) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // User must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Cancellation'),
//           content: const Text(
//               'Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
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
//           'cancellation_time':
//               FieldValue.serverTimestamp(), // Add cancellation time
//         });
//         debugPrint('Booking $bookingId moved to canceled_bookings.');
//       }

//       // Delete the original booking
//       await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .delete();
//       debugPrint('Original booking $bookingId deleted from book_history.');

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking cancelled successfully.')),
//       );
//     } catch (e) {
//       debugPrint('Failed to cancel booking: $e');
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
//           labelText: 'Search by Hotel Name or Room Type', // Improved label
//           border: const OutlineInputBorder(),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               setState(() {
//                 searchQuery = ''; // Clear the search query
//                 // Also clear the text field
//                 // If you use a controller, it would be: _searchController.clear();
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
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             // Select Date Range button
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () async {
//                   DateTime? pickedStartDate = await showDatePicker(
//                     context: context,
//                     initialDate: startDate ?? DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2101),
//                   );
              
//                   if (pickedStartDate != null) {
//                     DateTime? pickedEndDate = await showDatePicker(
//                       context: context,
//                       initialDate: pickedStartDate,
//                       firstDate: pickedStartDate,
//                       lastDate: DateTime(2101),
//                     );
              
//                     if (pickedEndDate != null) {
//                       setState(() {
//                         startDate = pickedStartDate;
//                         endDate = pickedEndDate;
//                         debugPrint('Date range selected: $startDate to $endDate');
//                       });
//                     }
//                   }
//                 },
//                 icon: const Icon(Icons.calendar_today, color: Colors.white),
//                 label: const Text('Select Date Range',
//                     style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//               ),
//             ),

//             // Clear filter button
//             ElevatedButton.icon(
//               onPressed: () {
//                 setState(() {
//                   startDate = null;
//                   endDate = null;
//                   debugPrint('Date filter cleared.');
//                 });
//               },
//               icon: const Icon(Icons.clear, color: Colors.white),
//               label: const Text('Clear Filter',
//                   style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         // Display selected date range
//         if (startDate != null && endDate != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Text(
//               'Selected: ${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//       ],
//     );
//   }
// }

// // New StatefulWidget to load and display hotel image from Hive
// class _HistoryBookingImage extends StatefulWidget {
//   final String? hotelId; // Nullable because booking data might not always have it

//   const _HistoryBookingImage({Key? key, required this.hotelId}) : super(key: key);

//   @override
//   State<_HistoryBookingImage> createState() => _HistoryBookingImageState();
// }

// class _HistoryBookingImageState extends State<_HistoryBookingImage> {
//   Uint8List? _hotelImageBytes;

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _HistoryBookingImage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.hotelId != oldWidget.hotelId) {
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     if (widget.hotelId == null) {
//       setState(() {
//         _hotelImageBytes = null; // No hotelId, so no image to load
//       });
//       debugPrint('No hotelId provided for history booking image. Showing default.');
//       return;
//     }

//     final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//     final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId!);

//     debugPrint('Attempting to load history booking image bytes for hotel ID: ${widget.hotelId} from Hive.');

//     if (imageBytes != null) {
//       setState(() {
//         _hotelImageBytes = imageBytes;
//       });
//       debugPrint('History booking image bytes found and loaded for hotel ID: ${widget.hotelId}.');
//     } else {
//       setState(() {
//         _hotelImageBytes = null; // No image bytes found in Hive
//       });
//       debugPrint('History booking image bytes not found for hotel ID: ${widget.hotelId} in Hive. Showing default.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.grey[400],
//         borderRadius: BorderRadius.circular(8),
//         image: DecorationImage(
//           image: _hotelImageBytes != null
//               ? MemoryImage(_hotelImageBytes!) as ImageProvider
//               : const AssetImage("assets/images/hotel.png"), // Default image
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'dart:typed_data'; // For Uint8List
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   final currencyFormat = NumberFormat.currency(
//     locale: 'id_ID',
//     symbol: 'Rp ',
//     decimalDigits: 0, // Disesuaikan agar tidak ada desimal
//   );
//   final dateFormat = DateFormat('yyyy-MM-dd');
//   final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

//   String? userId;
//   String searchQuery = '';
//   DateTime? startDate;
//   DateTime? endDate;

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser?.uid;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Perubahan: DefaultTabController dan TabBarView dihapus
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'History List',
//           style: TextStyle(
//               fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         // Perubahan: TabBar di `bottom` dihapus
//       ),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           _buildDatePicker(),
//           Expanded(
//             child: _buildCombinedBookingsList(),
//           ),
//         ],
//       ),
//     );
//   }

//   // Perubahan: Method baru untuk menggabungkan data booking
//   Widget _buildCombinedBookingsList() {
//     if (userId == null) {
//       return const Center(child: Text('Please log in to see your history.'));
//     }

//     // Stream untuk booking yang aktif/selesai
//     Stream<QuerySnapshot> activeBookingsStream = FirebaseFirestore.instance
//         .collection('book_history')
//         .where('user_id', isEqualTo: userId)
//         .snapshots();

//     // Stream untuk booking yang dibatalkan
//     Stream<QuerySnapshot> cancelledBookingsStream = FirebaseFirestore.instance
//         .collection('canceled_bookings')
//         .where('user_id', isEqualTo: userId)
//         .snapshots();

//     return StreamBuilder<QuerySnapshot>(
//       stream: activeBookingsStream,
//       builder: (ctx, activeSnapshot) {
//         return StreamBuilder<QuerySnapshot>(
//           stream: cancelledBookingsStream,
//           builder: (ctx, cancelledSnapshot) {
//             if (activeSnapshot.connectionState == ConnectionState.waiting ||
//                 cancelledSnapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             // Gabungkan kedua list data
//             final List<Map<String, dynamic>> allBookings = [];

//             // Proses data booking aktif
//             if (activeSnapshot.hasData) {
//               for (var doc in activeSnapshot.data!.docs) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 data['doc_id'] = doc.id; // Simpan doc ID
//                 data['status'] = _getBookingStatus(
//                     data['start_date'], data['end_date']); // Tentukan status
//                 allBookings.add(data);
//               }
//             }

//             // Proses data booking yang dibatalkan
//             if (cancelledSnapshot.hasData) {
//               for (var doc in cancelledSnapshot.data!.docs) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 data['doc_id'] = doc.id; // Simpan doc ID
//                 data['status'] = "Cancelled"; // Status sudah pasti dibatalkan
//                 allBookings.add(data);
//               }
//             }
            
//             // Urutkan semua booking berdasarkan waktu dibuat (created_at) dari yang terbaru
//             allBookings.sort((a, b) {
//                 Timestamp tsA = a['created_at'] ?? Timestamp.now();
//                 Timestamp tsB = b['created_at'] ?? Timestamp.now();
//                 return tsB.compareTo(tsA);
//             });

//             // Terapkan filter pencarian dan tanggal
//             final filteredDocs = allBookings.where((data) {
//               final hotelName = data['hotel_name']?.toLowerCase() ?? '';
//               final roomType = data['room_summary']?.toLowerCase() ?? '';
//               final bookingId = data['booking_id']?.toLowerCase() ?? '';
//               final totalPriceString =
//                   (data['total_price'] as num?)?.toString() ?? '';

//               final matchesSearchQuery =
//                   hotelName.contains(searchQuery.toLowerCase()) ||
//                       roomType.contains(searchQuery.toLowerCase()) ||
//                       bookingId.contains(searchQuery.toLowerCase()) ||
//                       totalPriceString.contains(searchQuery);

//               final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
//               final isWithinDateRange = (startDate == null ||
//                       (bookingTime != null &&
//                           bookingTime.isAfter(startDate!))) &&
//                   (endDate == null ||
//                       (bookingTime != null &&
//                           bookingTime
//                               .isBefore(endDate!.add(const Duration(days: 1)))));

//               return matchesSearchQuery && isWithinDateRange;
//             }).toList();

//             if (filteredDocs.isEmpty) {
//               return const Center(
//                   child: Text('No bookings found matching your criteria.'));
//             }
            
//             return ListView.builder(
//               itemCount: filteredDocs.length,
//               itemBuilder: (ctx, i) {
//                 final data = filteredDocs[i];
//                 final docId = data['doc_id'] as String;
//                 final bookingStatus = data['status'] as String;

//                 final bookingTime =
//                     (data['created_at'] as Timestamp?)?.toDate();
//                 final startDateBooking =
//                     DateTime.tryParse(data['start_date'] ?? '');
//                 final endDateBooking =
//                     DateTime.tryParse(data['end_date'] ?? '');
//                 final hotelId = data['hotel_id'] as String?;

//                 // Tombol cancel hanya muncul jika statusnya "Upcoming"
//                 bool showCancelButton = bookingStatus == "Upcoming";
                
//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Booking Time : ${bookingTime != null ? dateTimeFormat.format(bookingTime) : '-'}',
//                           style: const TextStyle(
//                               fontSize: 13, fontWeight: FontWeight.w500),
//                         ),
//                         const Divider(),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _HistoryBookingImage(hotelId: hotelId),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     data['hotel_name'] ?? 'Unknown Hotel',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Room Type : ${data['room_summary'] ?? '-'}',
//                                     style: const TextStyle(fontSize: 13),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Duration : ${startDateBooking != null ? dateFormat.format(startDateBooking) : '-'} to ${endDateBooking != null ? dateFormat.format(endDateBooking) : '-'}',
//                                     style: const TextStyle(fontSize: 13),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                             currencyFormat.format(
//                                                 data['total_price'] ?? 0),
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 15)),
//                                       ),
//                                       Expanded(
//                                         child: Text(
//                                           'Booking ID : ${data['booking_id'] ?? '-'}',
//                                           style: const TextStyle(
//                                               fontSize: 12,
//                                               overflow: TextOverflow.ellipsis),
//                                           maxLines: 2,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   // Tampilkan status booking
//                                   Text(
//                                     'Status: $bookingStatus',
//                                     style: TextStyle(
//                                       color: _getStatusColor(bookingStatus),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   // Tombol Cancel
//                                   if (showCancelButton)
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         _showCancelConfirmationDialog(docId);
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.blue,
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 20, vertical: 12),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         "Cancel Book",
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   // Helper method untuk menentukan status booking
//   String _getBookingStatus(String? startDateStr, String? endDateStr) {
//     if (startDateStr == null || endDateStr == null) return "Upcoming";

//     final startDateBooking = DateTime.tryParse(startDateStr);
//     final endDateBooking = DateTime.tryParse(endDateStr);

//     if (startDateBooking == null || endDateBooking == null) return "Upcoming";
    
//     final now = DateTime.now();
//     if (now.isAfter(endDateBooking)) {
//       return "Done";
//     } else if (now.isAfter(startDateBooking) && now.isBefore(endDateBooking)) {
//       return "In Use";
//     } else if (now.isBefore(startDateBooking)) {
//         // Cek apakah masih bisa dibatalkan
//         if (now.isBefore(startDateBooking.subtract(const Duration(days: 1)))){
//             return "Upcoming";
//         } else {
//             return "Upcoming"; // Tetap upcoming, tapi tombol cancel akan disembunyikan oleh logic lain
//         }
//     }
//     return "Upcoming";
//   }
  
//   // Helper method untuk menentukan warna status
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case "In Use":
//         return Colors.red.shade700;
//       case "Done":
//         return Colors.green.shade700;
//       case "Cancelled":
//         return Colors.grey.shade700;
//       case "Upcoming":
//         return Colors.blue.shade700;
//       default:
//         return Colors.black;
//     }
//   }


//   // Dihapus: _buildActiveBookings dan _buildCancelledBookings tidak lagi digunakan.

//   Future<void> _showCancelConfirmationDialog(String bookingId) async {
//     // Fungsi ini tetap sama
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Cancellation'),
//           content: const Text(
//               'Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Yes'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _cancelBooking(bookingId);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _cancelBooking(String bookingId) async {
//     // Fungsi ini tetap sama
//     try {
//       final bookingSnapshot = await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .get();

//       if (bookingSnapshot.exists) {
//         final bookingData = bookingSnapshot.data() as Map<String, dynamic>;
//         await FirebaseFirestore.instance.collection('canceled_bookings').add({
//           ...bookingData,
//           'cancellation_time': FieldValue.serverTimestamp(),
//         });
//         debugPrint('Booking $bookingId moved to canceled_bookings.');
//       }

//       await FirebaseFirestore.instance
//           .collection('book_history')
//           .doc(bookingId)
//           .delete();
//       debugPrint('Original booking $bookingId deleted from book_history.');

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking cancelled successfully.')),
//       );
//     } catch (e) {
//       debugPrint('Failed to cancel booking: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to cancel booking: $e')),
//       );
//     }
//   }

//   Widget _buildSearchBar() {
//     // Fungsi ini tetap sama
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         decoration: InputDecoration(
//           labelText: 'Search by Hotel, Room, or Booking ID', // Improved label
//           border: const OutlineInputBorder(),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               setState(() {
//                 searchQuery = '';
//               });
//               // Anda mungkin perlu controller untuk mengosongkan teks field secara programatik
//               // _searchController.clear();
//             },
//           ),
//         ),
//         onChanged: (value) {
//           setState(() {
//             searchQuery = value;
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildDatePicker() {
//     // Fungsi ini tetap sama
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () async {
//                   DateTime? pickedStartDate = await showDatePicker(
//                     context: context,
//                     initialDate: startDate ?? DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2101),
//                   );

//                   if (pickedStartDate != null) {
//                     DateTime? pickedEndDate = await showDatePicker(
//                       context: context,
//                       initialDate: pickedStartDate,
//                       firstDate: pickedStartDate,
//                       lastDate: DateTime(2101),
//                     );

//                     if (pickedEndDate != null) {
//                       setState(() {
//                         startDate = pickedStartDate;
//                         endDate = pickedEndDate;
//                         debugPrint('Date range selected: $startDate to $endDate');
//                       });
//                     }
//                   }
//                 },
//                 icon: const Icon(Icons.calendar_today, color: Colors.white),
//                 label: const Text('Select Date Range',
//                     style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton.icon(
//               onPressed: () {
//                 setState(() {
//                   startDate = null;
//                   endDate = null;
//                   debugPrint('Date filter cleared.');
//                 });
//               },
//               icon: const Icon(Icons.clear, color: Colors.white),
//               label: const Text('Clear Filter',
//                   style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//         if (startDate != null && endDate != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Text(
//               'Selected: ${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }

// // Widget _HistoryBookingImage tidak perlu diubah, jadi tetap sama.
// class _HistoryBookingImage extends StatefulWidget {
//   final String? hotelId;

//   const _HistoryBookingImage({Key? key, required this.hotelId}) : super(key: key);

//   @override
//   State<_HistoryBookingImage> createState() => _HistoryBookingImageState();
// }

// class _HistoryBookingImageState extends State<_HistoryBookingImage> {
//   Uint8List? _hotelImageBytes;

//   @override
//   void initState() {
//     super.initState();
//     _loadHotelImage();
//   }

//   @override
//   void didUpdateWidget(covariant _HistoryBookingImage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.hotelId != oldWidget.hotelId) {
//       _loadHotelImage();
//     }
//   }

//   Future<void> _loadHotelImage() async {
//     if (widget.hotelId == null) {
//       if (mounted) {
//         setState(() {
//           _hotelImageBytes = null;
//         });
//       }
//       debugPrint('No hotelId provided for history booking image.');
//       return;
//     }

//     final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
//     final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId!);

//     if (mounted) {
//        setState(() {
//         _hotelImageBytes = imageBytes;
//       });
//     }
    
//     if (imageBytes == null) {
//         debugPrint('History booking image bytes not found for hotel ID: ${widget.hotelId} in Hive.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.grey[400],
//         borderRadius: BorderRadius.circular(8),
//         image: DecorationImage(
//           image: _hotelImageBytes != null
//               ? MemoryImage(_hotelImageBytes!) as ImageProvider
//               : const AssetImage("assets/images/hotel.png"),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data'; // For Uint8List
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final dateFormat = DateFormat('yyyy-MM-dd');
  final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String? userId;
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History List',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildDatePicker(),
          Expanded(
            child: _buildCombinedBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedBookingsList() {
    if (userId == null) {
      return const Center(child: Text('Please log in to see your history.'));
    }

    Stream<QuerySnapshot> activeBookingsStream = FirebaseFirestore.instance
        .collection('book_history')
        .where('user_id', isEqualTo: userId)
        .snapshots();

    Stream<QuerySnapshot> cancelledBookingsStream = FirebaseFirestore.instance
        .collection('canceled_bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: activeBookingsStream,
      builder: (ctx, activeSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: cancelledBookingsStream,
          builder: (ctx, cancelledSnapshot) {
            if (activeSnapshot.connectionState == ConnectionState.waiting ||
                cancelledSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<Map<String, dynamic>> allBookings = [];

            if (activeSnapshot.hasData) {
              for (var doc in activeSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                data['doc_id'] = doc.id;
                data['status'] = _getBookingStatus(
                    data['start_date'], data['end_date']);
                allBookings.add(data);
              }
            }

            if (cancelledSnapshot.hasData) {
              for (var doc in cancelledSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                data['doc_id'] = doc.id;
                data['status'] = "Cancelled";
                allBookings.add(data);
              }
            }
            
            allBookings.sort((a, b) {
                Timestamp tsA = a['created_at'] ?? Timestamp.now();
                Timestamp tsB = b['created_at'] ?? Timestamp.now();
                return tsB.compareTo(tsA);
            });

            final filteredDocs = allBookings.where((data) {
              final hotelName = data['hotel_name']?.toLowerCase() ?? '';
              final roomType = data['room_summary']?.toLowerCase() ?? '';
              final bookingId = data['booking_id']?.toLowerCase() ?? '';
              final totalPriceString =
                  (data['total_price'] as num?)?.toString() ?? '';

              final matchesSearchQuery =
                  hotelName.contains(searchQuery.toLowerCase()) ||
                      roomType.contains(searchQuery.toLowerCase()) ||
                      bookingId.contains(searchQuery.toLowerCase()) ||
                      totalPriceString.contains(searchQuery);

              final bookingTime = (data['created_at'] as Timestamp?)?.toDate();
              final isWithinDateRange = (startDate == null ||
                      (bookingTime != null &&
                          bookingTime.isAfter(startDate!))) &&
                  (endDate == null ||
                      (bookingTime != null &&
                          bookingTime
                              .isBefore(endDate!.add(const Duration(days: 1)))));

              return matchesSearchQuery && isWithinDateRange;
            }).toList();

            if (filteredDocs.isEmpty) {
              return const Center(
                  child: Text('No bookings found matching your criteria.'));
            }
            
            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (ctx, i) {
                final data = filteredDocs[i];
                final docId = data['doc_id'] as String;
                final bookingStatus = data['status'] as String;

                final bookingTime =
                    (data['created_at'] as Timestamp?)?.toDate();
                final startDateBooking =
                    DateTime.tryParse(data['start_date'] ?? '');
                final endDateBooking =
                    DateTime.tryParse(data['end_date'] ?? '');
                final hotelId = data['hotel_id'] as String?;

                bool showCancelButton = bookingStatus == "Upcoming" && (startDateBooking != null && DateTime.now().isBefore(startDateBooking.subtract(const Duration(days: 1))));
                
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
                            _HistoryBookingImage(hotelId: hotelId),
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
                                    'Duration : ${startDateBooking != null ? dateFormat.format(startDateBooking) : '-'} to ${endDateBooking != null ? dateFormat.format(endDateBooking) : '-'}',
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
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: $bookingStatus',
                                    style: TextStyle(
                                      color: _getStatusColor(bookingStatus),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (showCancelButton)
                                    ElevatedButton(
                                      onPressed: () {
                                        _showCancelConfirmationDialog(docId);
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
                                        style: TextStyle(color: Colors.white),
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
        );
      },
    );
  }

  String _getBookingStatus(String? startDateStr, String? endDateStr) {
    if (startDateStr == null || endDateStr == null) return "Upcoming";

    final startDateBooking = DateTime.tryParse(startDateStr);
    final endDateBooking = DateTime.tryParse(endDateStr);

    if (startDateBooking == null || endDateBooking == null) return "Upcoming";
    
    final now = DateTime.now();
    if (now.isAfter(endDateBooking)) {
      return "Done";
    } else if (now.isAfter(startDateBooking) && now.isBefore(endDateBooking)) {
      return "In Use";
    }
    return "Upcoming";
  }
  
  // Perubahan warna ada di method ini
  Color _getStatusColor(String status) {
    switch (status) {
      case "In Use":
        return Colors.red.shade700;
      case "Done":
        return Colors.green.shade700; // Warna hijau
      case "Cancelled":
        return Colors.amber.shade800; // Warna kuning/amber
      case "Upcoming":
        return Colors.blue.shade700;
      default:
        return Colors.black;
    }
  }

  Future<void> _showCancelConfirmationDialog(String bookingId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text(
              'Are you sure you want to cancel the booking? After cancellation, the booking cannot be reactivated.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(bookingId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('book_history')
          .doc(bookingId)
          .get();

      if (bookingSnapshot.exists) {
        final bookingData = bookingSnapshot.data() as Map<String, dynamic>;
        await FirebaseFirestore.instance.collection('canceled_bookings').add({
          ...bookingData,
          'cancellation_time': FieldValue.serverTimestamp(),
        });
        debugPrint('Booking $bookingId moved to canceled_bookings.');
      }

      await FirebaseFirestore.instance
          .collection('book_history')
          .doc(bookingId)
          .delete();
      debugPrint('Original booking $bookingId deleted from book_history.');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully.')),
      );
    } catch (e) {
      debugPrint('Failed to cancel booking: $e');
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
          labelText: 'Search by Hotel, Room, or Booking ID',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                searchQuery = '';
              });
            },
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DateTime? pickedStartDate = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (pickedStartDate != null) {
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
                          debugPrint('Date range selected: $startDate to $endDate');
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
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    startDate = null;
                    endDate = null;
                    debugPrint('Date filter cleared.');
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
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Selected: ${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HistoryBookingImage extends StatefulWidget {
  final String? hotelId;

  const _HistoryBookingImage({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<_HistoryBookingImage> createState() => _HistoryBookingImageState();
}

class _HistoryBookingImageState extends State<_HistoryBookingImage> {
  Uint8List? _hotelImageBytes;

  @override
  void initState() {
    super.initState();
    _loadHotelImage();
  }

  @override
  void didUpdateWidget(covariant _HistoryBookingImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hotelId != oldWidget.hotelId) {
      _loadHotelImage();
    }
  }

  Future<void> _loadHotelImage() async {
    if (widget.hotelId == null) {
      if (mounted) {
        setState(() {
          _hotelImageBytes = null;
        });
      }
      return;
    }

    final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
    final Uint8List? imageBytes = hotelImagesBox.get(widget.hotelId!);

    if (mounted) {
       setState(() {
        _hotelImageBytes = imageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: _hotelImageBytes != null
              ? MemoryImage(_hotelImageBytes!) as ImageProvider
              : const AssetImage("assets/images/hotel.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}