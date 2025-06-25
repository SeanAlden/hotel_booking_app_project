import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/model/room.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

    if (_currentUser != null) {
      _resetNotificationCount();
    }
  }

  Future<void> _resetNotificationCount() async {
    if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
      await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
    }
    final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
    await countBox.put(NEW_NOTIFICATION_KEY, 0);
    debugPrint('NotificationPage: New notification count reset to 0.');
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications',
              style: TextStyle(color: Colors.white)),
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
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('book_history')
            .where('user_id', isEqualTo: _currentUser.uid)
            .orderBy('end_date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint(
                'NotificationPage: StreamBuilder Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No active bookings or notifications.'));
          }

          final userBookings = snapshot.data!.docs;
          final List<Booking> notifications = [];
          final now = DateTime.now();

          for (var doc in userBookings) {
            final booking = Booking.fromFirestore(doc);
            if (booking.endDate
                    .isAfter(now.subtract(const Duration(days: 3))) &&
                booking.startDate.isBefore(now.add(const Duration(days: 7)))) {
              notifications.add(booking);
            }
          }

          if (notifications.isEmpty) {
            return const Center(
                child: Text('No relevant notifications at this time.'));
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
                notificationMessage =
                    'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) akan berakhir dalam $daysUntilEnd hari!';
                notificationColor = Colors.blue.shade800;
                notificationIcon = Icons.notifications_active;
              } else if (daysUntilEnd == 0) {
                notificationMessage =
                    'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) berakhir HARI INI!';
                notificationColor = Colors.orange.shade800;
                notificationIcon = Icons.warning_amber;
              } else {
                notificationMessage =
                    'Booking Anda di ${booking.hotelName} (${booking.roomSummary}) telah berakhir ${daysUntilEnd.abs()} hari yang lalu.';
                notificationColor = Colors.grey.shade600;
                notificationIcon = Icons.check_circle_outline;
              }

              return Card(
                key: ValueKey(booking.id),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(notificationIcon,
                              color: notificationColor, size: 24),
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
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        'Kamar: ${booking.roomSummary}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        'Tanggal: ${DateFormat('dd MMM yyyy').format(booking.startDate)} - ${DateFormat('dd MMM yyyy').format(booking.endDate)}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'Dipesan pada: ${DateFormat('dd MMM yyyy HH:mm').format(booking.createdAt)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
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
