import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data'; 
import 'package:hive_flutter/hive_flutter.dart'; 

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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case "In Use":
        return Colors.red.shade700;
      case "Done":
        return Colors.green.shade700; 
      case "Cancelled":
        return Colors.amber.shade800; 
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