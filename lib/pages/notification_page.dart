// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hotel_booking_app/model/room.dart'; // Contains the Booking model
// import 'package:intl/intl.dart'; // For date formatting

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({Key? key}) : super(key: key);

//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final User? _currentUser = FirebaseAuth.instance.currentUser;

//   @override
//   Widget build(BuildContext context) {
//     if (_currentUser == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Notifications', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.blue,
//           iconTheme: const IconThemeData(color: Colors.white),
//         ),
//         body: const Center(
//           child: Text('Please log in to view your notifications.'),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('book_history')
//             .where('user_id', isEqualTo: _currentUser!.uid)
//             .orderBy('end_date', descending: false) // Order by soonest expiration
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             debugPrint('NotificationPage: StreamBuilder Error: ${snapshot.error}');
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No active bookings or notifications.'));
//           }

//           final userBookings = snapshot.data!.docs;
//           final List<Booking> notifications = [];
//           final now = DateTime.now();

//           for (var doc in userBookings) {
//             final booking = Booking.fromFirestore(doc);
//             // Only show notifications for bookings that are currently active or ending soon (e.g., within next 7 days)
//             // or have recently ended but user might still be interested (e.g., last 3 days)
//             if (booking.endDate.isAfter(now.subtract(const Duration(days: 3))) && booking.startDate.isBefore(now.add(const Duration(days: 7)))) {
//               notifications.add(booking);
//             }
//           }

//           if (notifications.isEmpty) {
//             return const Center(child: Text('No relevant notifications at this time.'));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final booking = notifications[index];
//               final daysUntilEnd = booking.endDate.difference(now).inDays;
//               String notificationMessage;
//               Color notificationColor = Colors.black87;
//               IconData notificationIcon = Icons.info_outline;

//               if (daysUntilEnd >= 1) {
//                 // Booking is active and ending in the future
//                 notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) akan berakhir dalam $daysUntilEnd hari!';
//                 notificationColor = Colors.blue.shade800;
//                 notificationIcon = Icons.notifications_active;
//               } else if (daysUntilEnd == 0) {
//                 // Booking ends today
//                 notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) berakhir HARI INI!';
//                 notificationColor = Colors.orange.shade800;
//                 notificationIcon = Icons.warning_amber;
//               } else {
//                 // Booking has recently ended
//                 notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) telah berakhir ${daysUntilEnd.abs()} hari yang lalu.';
//                 notificationColor = Colors.grey.shade600;
//                 notificationIcon = Icons.check_circle_outline; // Or a different icon for past bookings
//               }

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(notificationIcon, color: notificationColor, size: 24),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               notificationMessage,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: notificationColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Hotel: ${booking.hotelName}',
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                       Text(
//                         'Kamar: ${booking.roomSummary}',
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                       Text(
//                         'Tanggal: ${DateFormat('dd MMM yyyy').format(booking.startDate)} - ${DateFormat('dd MMM yyyy').format(booking.endDate)}',
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                       const SizedBox(height: 8),
//                       Align(
//                         alignment: Alignment.bottomRight,
//                         child: Text(
//                           'Dipesan pada: ${DateFormat('dd MMM yyyy HH:mm').format(booking.createdAt)}',
//                           style: const TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
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

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hotel_booking_app/model/room.dart'; // Contains the Booking model
// import 'package:intl/intl.dart'; // For date formatting
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// // Define the same constants as in main.dart
// const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
// const String NEW_NOTIFICATION_KEY = 'new_notification_count';

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({Key? key}) : super(key: key);

//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final User? _currentUser = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _resetNotificationCount(); // Reset count when page is initialized
//   }

//   Future<void> _resetNotificationCount() async {
//     final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
//     await countBox.put(NEW_NOTIFICATION_KEY, 0); // Reset count to 0
//     debugPrint('NotificationPage: New notification count reset to 0.');
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_currentUser == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Notifications', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.blue,
//           iconTheme: const IconThemeData(color: Colors.white),
//         ),
//         body: const Center(
//           child: Text('Please log in to view your notifications.'),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('book_history')
//             .where('user_id', isEqualTo: _currentUser!.uid)
//             .orderBy('end_date', descending: false)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             debugPrint('NotificationPage: StreamBuilder Error: ${snapshot.error}');
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No active bookings or notifications.'));
//           }

//           final userBookings = snapshot.data!.docs;
//           final List<Booking> notifications = [];
//           final now = DateTime.now();

//           for (var doc in userBookings) {
//             final booking = Booking.fromFirestore(doc);
//             if (booking.endDate.isAfter(now.subtract(const Duration(days: 3))) &&
//                 booking.startDate.isBefore(now.add(const Duration(days: 7)))) {
//               notifications.add(booking);
//             }
//           }

//           if (notifications.isEmpty) {
//             return const Center(child: Text('No relevant notifications at this time.'));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final booking = notifications[index];
//               final daysUntilEnd = booking.endDate.difference(now).inDays;
//               String notificationMessage;
//               Color notificationColor = Colors.black87;
//               IconData notificationIcon = Icons.info_outline;

//               if (daysUntilEnd >= 1) {
//                 notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) akan berakhir dalam $daysUntilEnd hari!';
//                 notificationColor = Colors.blue.shade800;
//                 notificationIcon = Icons.notifications_active;
//               } else if (daysUntilEnd == 0) {
//                 notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) berakhir HARI INI!';
//                 notificationColor = Colors.orange.shade800;
//                 notificationIcon = Icons.warning_amber;
//               } else {
//                 notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) telah berakhir ${daysUntilEnd.abs()} hari yang lalu.';
//                 notificationColor = Colors.grey.shade600;
//                 notificationIcon = Icons.check_circle_outline;
//               }

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(notificationIcon, color: notificationColor, size: 24),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               notificationMessage,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: notificationColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Hotel: ${booking.hotelName}',
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                       Text(
//                         'Kamar: ${booking.roomSummary}',
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                       Text(
//                         'Tanggal: ${DateFormat('dd MMM BCE').format(booking.startDate)} - ${DateFormat('dd MMM BCE').format(booking.endDate)}',
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                       const SizedBox(height: 8),
//                       Align(
//                         alignment: Alignment.bottomRight,
//                         child: Text(
//                           'Dipesan pada: ${DateFormat('dd MMM BCE HH:mm').format(booking.createdAt)}',
//                           style: const TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/model/room.dart'; // Contains the Booking model
import 'package:intl/intl.dart'; // For date formatting
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive

// Define the same constants as in main.dart
const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
const String NEW_NOTIFICATION_KEY = 'new_notification_count';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Only reset count if the user is logged in
    if (_currentUser != null) {
      _resetNotificationCount();
    }
  }

  Future<void> _resetNotificationCount() async {
    // Ensure the box is open before trying to use it
    if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
      await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
    }
    final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
    await countBox.put(NEW_NOTIFICATION_KEY, 0); // Reset count to 0
    debugPrint('NotificationPage: New notification count reset to 0.');
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('Please log in to view your notifications.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('book_history')
            .where('user_id', isEqualTo: _currentUser!.uid)
            .orderBy('end_date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('NotificationPage: StreamBuilder Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active bookings or notifications.'));
          }

          final userBookings = snapshot.data!.docs;
          final List<Booking> notifications = [];
          final now = DateTime.now();

          for (var doc in userBookings) {
            final booking = Booking.fromFirestore(doc);
            if (booking.endDate.isAfter(now.subtract(const Duration(days: 3))) &&
                booking.startDate.isBefore(now.add(const Duration(days: 7)))) {
              notifications.add(booking);
            }
          }

          if (notifications.isEmpty) {
            return const Center(child: Text('No relevant notifications at this time.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final booking = notifications[index];
              final daysUntilEnd = booking.endDate.difference(now).inDays;
              String notificationMessage;
              Color notificationColor = Colors.black87;
              IconData notificationIcon = Icons.info_outline;

              if (daysUntilEnd >= 1) {
                notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) akan berakhir dalam $daysUntilEnd hari!';
                notificationColor = Colors.blue.shade800;
                notificationIcon = Icons.notifications_active;
              } else if (daysUntilEnd == 0) {
                notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) berakhir HARI INI!';
                notificationColor = Colors.orange.shade800;
                notificationIcon = Icons.warning_amber;
              } else {
                notificationMessage = 'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) telah berakhir ${daysUntilEnd.abs()} hari yang lalu.';
                notificationColor = Colors.grey.shade600;
                notificationIcon = Icons.check_circle_outline;
              }

              return Card(
                key: ValueKey(booking.id), // Add a ValueKey for better list performance
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(notificationIcon, color: notificationColor, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              notificationMessage,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: notificationColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hotel: ${booking.hotelName}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        'Kamar: ${booking.roomSummary}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      // Corrected DateFormat usage: use 'yyyy' instead of 'BCE'
                      Text(
                        'Tanggal: ${DateFormat('dd MMM yyyy').format(booking.startDate)} - ${DateFormat('dd MMM yyyy').format(booking.endDate)}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'Dipesan pada: ${DateFormat('dd MMM yyyy HH:mm').format(booking.createdAt)}', // Corrected DateFormat
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
