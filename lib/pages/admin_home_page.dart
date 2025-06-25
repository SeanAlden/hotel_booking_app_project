import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/pages/login_page.dart';
import 'package:hotel_booking_app/pages/manage_hotel_page.dart';
import 'package:hotel_booking_app/pages/manage_location_page.dart';
import 'package:hotel_booking_app/pages/manage_room_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _totalBookings = 0;
  int _totalUsers = 0;
  List<Hotel> _topHotels = [];
  List<RoomSummary> _topRooms = [];
  List<MapEntry<String, int>> _sortedHotelBookingCounts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookingSnapshot =
          await FirebaseFirestore.instance.collection('book_history').get();
      _totalBookings = bookingSnapshot.docs.length;
      debugPrint('AdminHomePage: Total Bookings: $_totalBookings');

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'user')
          .get();
      _totalUsers = userSnapshot.docs.length;
      debugPrint('AdminHomePage: Total Users (type "user"): $_totalUsers');

      final allBookingsSnapshot =
          await FirebaseFirestore.instance.collection('book_history').get();
      final Map<String, int> hotelBookingCounts = {};
      final Map<String, int> roomBookingCounts = {};

      for (var doc in allBookingsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final hotelId = data['hotel_id'] as String?;
        final roomSummary = data['room_summary'] as String?;

        if (hotelId != null) {
          hotelBookingCounts[hotelId] = (hotelBookingCounts[hotelId] ?? 0) + 1;
        }
        if (roomSummary != null) {
          roomBookingCounts[roomSummary] =
              (roomBookingCounts[roomSummary] ?? 0) + 1;
        }
      }

      _sortedHotelBookingCounts = hotelBookingCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      _topHotels.clear();
      for (int i = 0; i < _sortedHotelBookingCounts.length && i < 5; i++) {
        final hotelId = _sortedHotelBookingCounts[i].key;
        final hotelDoc = await FirebaseFirestore.instance
            .collection('hotels')
            .doc(hotelId)
            .get();
        if (hotelDoc.exists) {
          _topHotels.add(Hotel.fromFirestore(hotelDoc));
        }
      }
      debugPrint('AdminHomePage: Top Hotels fetched: ${_topHotels.length}');

      final sortedRooms = roomBookingCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      _topRooms.clear();
      for (int i = 0; i < sortedRooms.length && i < 5; i++) {
        _topRooms.add(
            RoomSummary(type: sortedRooms[i].key, count: sortedRooms[i].value));
      }
      debugPrint('AdminHomePage: Top Rooms fetched: ${_topRooms.length}');
    } catch (e) {
      _errorMessage = 'Error fetching dashboard data: $e';
      debugPrint('AdminHomePage: $_errorMessage');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDashboardData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildAdminDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchDashboardData,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDashboardCard(
                        title: "Total Bookings",
                        value: _totalBookings.toString(),
                        icon: Icons.receipt_long,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 16),
                      _buildDashboardCard(
                        title: "Total Users",
                        value: _totalUsers.toString(),
                        icon: Icons.people,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(height: 24),
                      Text("Top 5 Hotels by Bookings",
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _topHotels.isEmpty
                          ? const Text("No top hotels available yet.")
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _topHotels.length,
                              itemBuilder: (context, index) {
                                final hotel = _topHotels[index];
                                final count = _sortedHotelBookingCounts
                                    .firstWhere(
                                      (entry) => entry.key == hotel.id,
                                      orElse: () => MapEntry(hotel.id, 0),
                                    )
                                    .value;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.hotel,
                                        color: Colors.blue),
                                    title: Text(hotel.name),
                                    subtitle: Text('Bookings: $count'),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 24),
                      Text("Top 5 Rooms by Bookings",
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _topRooms.isEmpty
                          ? const Text("No top rooms available yet.")
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _topRooms.length,
                              itemBuilder: (context, index) {
                                final room = _topRooms[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.king_bed,
                                        color: Colors.purple),
                                    title: Text(room.type),
                                    subtitle: Text('Bookings: ${room.count}'),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome, ${FirebaseAuth.instance.currentUser?.email ?? 'Admin'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Manage Location'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageLocationPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.hotel),
            title: const Text('Manage Hotel'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManageHotelPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.meeting_room),
            title: const Text('Manage Room'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManageRoomPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RoomSummary {
  final String type;
  final int count;

  RoomSummary({required this.type, required this.count});
}
