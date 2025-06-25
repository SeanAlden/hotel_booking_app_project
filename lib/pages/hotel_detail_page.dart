import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/model/room.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HotelDetailPage extends StatefulWidget {
  final String hotelId;

  final List<Map<String, dynamic>> rooms;

  const HotelDetailPage({
    Key? key,
    required this.hotelId,
    required this.rooms,
  }) : super(key: key);

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  List<Room> _rooms = [];
  List<DateTime?> startDates = [];
  List<DateTime?> endDates = [];
  List<int> guestCounts = [];
  List<double> roomTotalPrices = [];
  double totalPrice = 0;
  List<int> selectedRoomIndices = [];
  String? userId;

  Hotel? _hotel;
  bool _isLoadingHotel = true;
  String? _errorHotel;

  Uint8List? _hotelImageBytes;

  String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
    return formatCurrency.format(amount);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    return dateFormat.format(date);
  }

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _fetchHotelDetails();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadHotelImage();
  }

  Future<void> _fetchHotelDetails() async {
    try {
      final fetchedHotel = await Hotel.fetchHotelDetails(widget.hotelId);
      setState(() {
        _hotel = fetchedHotel;
        _isLoadingHotel = false;
      });
    } catch (e) {
      setState(() {
        _errorHotel = 'Gagal memuat detail hotel: $e';
        _isLoadingHotel = false;
      });
    }
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
        _hotelImageBytes = null;
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
        return Room.fromFirestore(doc);
      }).toList();

      setState(() {
        _rooms = fetchedRooms;

        startDates = List<DateTime?>.filled(_rooms.length, null);
        endDates = List<DateTime?>.filled(_rooms.length, null);
        guestCounts = List<int>.generate(_rooms.length, (index) => 1);
        roomTotalPrices = List<double>.filled(_rooms.length, 0);
      });

      for (var room in _rooms) {
        await room.fetchBookings();
        debugPrint('Bookings for room ${room.id}: ${room.bookings.length}');
        for (var booking in room.bookings) {
          debugPrint(
              'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
        }
      }

      setState(() {});
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
      return false;
    }

    final normalizedSelectedStart = DateTime(
        selectedStartDate.year, selectedStartDate.month, selectedStartDate.day);
    final normalizedSelectedEnd = DateTime(
        selectedEndDate.year, selectedEndDate.month, selectedEndDate.day);

    for (var booking in _rooms[index].bookings) {
      final normalizedBookingStart = DateTime(booking.startDate.year,
          booking.startDate.month, booking.startDate.day);
      final normalizedBookingEnd = DateTime(
          booking.endDate.year, booking.endDate.month, booking.endDate.day);

      bool isOverlapping =
          (normalizedSelectedStart.isBefore(normalizedBookingEnd) &&
              normalizedSelectedEnd.isAfter(normalizedBookingStart));

      if (isOverlapping) {
        return true;
      }
    }
    return false;
  }

  String _getRoomStatus(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var booking in _rooms[index].bookings) {
      final bookingStart = DateTime(booking.startDate.year,
          booking.startDate.month, booking.startDate.day);
      final bookingEnd = DateTime(
          booking.endDate.year, booking.endDate.month, booking.endDate.day);

      if ((today.isAfter(bookingStart) ||
              today.isAtSameMomentAs(bookingStart)) &&
          today.isBefore(bookingEnd)) {
        return "In Use";
      }

      if (booking.userId == userId && today.isBefore(bookingStart)) {
        return "Booked by You";
      }
    }
    return "";
  }

  void _calculateTotalPrice() {
    totalPrice = 0;
    for (var index in selectedRoomIndices) {
      if (startDates[index] != null && endDates[index] != null) {
        final nights = endDates[index]!.difference(startDates[index]!).inDays;
        if (nights > 0) {
          roomTotalPrices[index] =
              nights * _rooms[index].price * guestCounts[index];
          totalPrice += roomTotalPrices[index];
        } else {
          roomTotalPrices[index] = 0;
        }
      } else {
        roomTotalPrices[index] = 0;
      }
    }
    setState(() {});
  }

  Future<void> _pickStartDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDates[index] ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDates[index]) {
      setState(() {
        startDates[index] = picked;

        if (endDates[index] != null &&
            startDates[index]!.isAfter(endDates[index]!)) {
          endDates[index] = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Tanggal mulai tidak boleh setelah atau sama dengan tanggal akhir.')),
          );
        }
        _calculateTotalPrice();
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
      firstDate: startDates[index]!.add(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDates[index]) {
      setState(() {
        endDates[index] = picked;

        if (endDates[index]!.isBefore(startDates[index]!) ||
            endDates[index]!.isAtSameMomentAs(startDates[index]!)) {
          startDates[index] = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Tanggal akhir tidak boleh sebelum atau sama dengan tanggal mulai.')),
          );
        }
        _calculateTotalPrice();
      });
    }
  }

  Future<void> _toggleRoomSelection(int index) async {
    if (!selectedRoomIndices.contains(index)) {
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

        startDates[index] = null;
        endDates[index] = null;
        guestCounts[index] = 1;
        roomTotalPrices[index] = 0;
      } else {
        selectedRoomIndices.add(index);
      }
      _calculateTotalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingHotel) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorHotel != null) {
      return Scaffold(
        body: Center(child: Text(_errorHotel!)),
      );
    }

    if (_hotel == null) {
      return const Scaffold(
        body: Center(child: Text("Hotel tidak ditemukan.")),
      );
    }

    final hotel = _hotel!;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Detail Hotel", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: selectedRoomIndices.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total Harga: ${formatCurrency(totalPrice)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
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
            SizedBox(
              height: 240,
              width: double.infinity,
              child: _hotelImageBytes != null
                  ? Image.memory(
                      _hotelImageBytes!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/hotel.png',
                      fit: BoxFit.cover,
                    ),
            ),
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
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text("${hotel.rating} / 5.0"),
                      const Spacer(),
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 4),
                      FutureBuilder<String>(
                        future: Location.fetchLocationName(hotel.locationId),
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
                  const Text("Fasilitas",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: hotel.amenities
                        .map((item) => Chip(
                              label: Text(item),
                              backgroundColor: Colors.blue.shade50,
                              labelStyle: const TextStyle(color: Colors.blue),
                              avatar: const Icon(Icons.check_circle_outline,
                                  color: Colors.blue, size: 18),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 30),
                  const Text("Kamar Tersedia",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Column(
                    children: _rooms.asMap().entries.map((entry) {
                      int index = entry.key;
                      var room = entry.value;
                      bool isSelected = selectedRoomIndices.contains(index);
                      String roomStatus = _getRoomStatus(index);

                      return RoomCard(
                        room: room,
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
                        userId: userId,
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
  }
}

class RoomCard extends StatefulWidget {
  final Room room;
  final int index;
  final bool isSelected;
  final String roomStatus;
  final Function(double) formatCurrency;
  final Function(DateTime?) formatDate;
  final List<DateTime?> startDates;
  final List<DateTime?> endDates;
  final List<int> guestCounts;
  final List<double> roomTotalPrices;
  final Function(int) pickStartDate;
  final Function(int) pickEndDate;
  final Function(int) toggleRoomSelection;
  final VoidCallback calculateTotalPrice;
  final String? userId;

  const RoomCard({
    Key? key,
    required this.room,
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
        _roomImageBytes = null;
      });
      debugPrint(
          'Room image bytes not found for ID: ${widget.room.id} in Hive. Showing default.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int maxGuestCapacity = widget.room.guestCount ?? 1;

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
                      "assets/images/room.png",
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
                          : Colors.black54,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
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
                                  maxGuestCapacity
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.roomStatus == "In Use" ||
                            widget.roomStatus == "Booked by You"
                        ? null
                        : () {
                            widget.toggleRoomSelection(widget.index);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isSelected
                          ? Colors.blue
                          : (widget.roomStatus.isNotEmpty
                              ? Colors.grey[500]
                              : Colors.deepPurple),
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
