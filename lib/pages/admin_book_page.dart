import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/room.dart';
import 'package:hotel_booking_app/model/user.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';

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

                  if (_searchQuery.isEmpty) return true;

                  return hotelName.contains(_searchQuery) ||
                      roomSummary.contains(_searchQuery);
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
                      key: ValueKey(booking.id),
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
