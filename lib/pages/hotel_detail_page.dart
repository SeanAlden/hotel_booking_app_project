import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/model/room.dart';
import 'package:hotel_booking_app/pages/history_page.dart';

class HotelDetailPage extends StatefulWidget {
  final String hotelId; // Ganti hotelName dengan hotelId
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
  List<Room> _rooms = []; // Tambahkan list untuk menyimpan data kamar
  List<DateTime?> startDates = []; // List untuk menyimpan start date per room
  List<DateTime?> endDates = []; // List untuk menyimpan end date per room
  List<int> guestCounts = []; // List untuk menyimpan guest count per room
  List<double> roomTotalPrices =
      []; // List untuk menyimpan total price per room
  double totalPrice = 0; // Total price calculation
  List<int> selectedRoomIndices =
      []; // List untuk menyimpan indeks ruangan yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchRooms(); // Ambil data kamar saat halaman diinisialisasi
  }

  Future<void> _fetchRooms() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('hotelId',
            isEqualTo: widget.hotelId) // Ambil kamar berdasarkan hotelId
        .get();

    setState(() {
      _rooms = snapshot.docs.map((doc) {
        return Room(
          id: doc.id,
          hotelId: doc['hotelId'],
          type: doc['type'],
          price: (doc['price'] as num).toDouble(),
          startDate: doc['startDate'] != null
              ? DateTime.parse(doc['startDate'])
              : null,
          endDate:
              doc['endDate'] != null ? DateTime.parse(doc['endDate']) : null,
          guestCount: doc['guestCount'],
          totalPrice: doc['totalPrice'],
        );
      }).toList();

      // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
      startDates = List<DateTime?>.filled(_rooms.length, null);
      endDates = List<DateTime?>.filled(_rooms.length, null);
      guestCounts = List<int>.filled(
          _rooms.length, 1); // Default guest count for each room
      roomTotalPrices =
          List<double>.filled(_rooms.length, 0); // Initialize room total prices
    });
  }

  void _calculateTotalPrice() {
    totalPrice = 0;
    for (var index in selectedRoomIndices) {
      if (startDates[index] != null && endDates[index] != null) {
        final nights = endDates[index]!.difference(startDates[index]!).inDays;
        if (nights > 0) {
          roomTotalPrices[index] =
              nights * _rooms[index].price * guestCounts[index];
          totalPrice += roomTotalPrices[index]; // Add to total price
        } else {
          roomTotalPrices[index] = 0; // Reset if dates are invalid
        }
      } else {
        roomTotalPrices[index] = 0; // Reset if dates are not set
      }
    }
    setState(() {});
  }

  Future<void> _pickStartDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDates[index] ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDates[index]) {
      setState(() {
        startDates[index] = picked;
        _calculateTotalPrice(); // Recalculate total price
      });
    }
  }

  Future<void> _pickEndDate(int index) async {
    if (startDates[index] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick start date first')));
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
        _calculateTotalPrice(); // Recalculate total price
      });
    }
  }

  void _toggleRoomSelection(int index) {
    setState(() {
      if (selectedRoomIndices.contains(index)) {
        selectedRoomIndices.remove(index); // Deselect room
        startDates[index] = null; // Reset start date
        endDates[index] = null; // Reset end date
        guestCounts[index] = 1; // Reset guest count
        roomTotalPrices[index] = 0; // Reset room total price
      } else {
        selectedRoomIndices.add(index); // Select room
      }
      _calculateTotalPrice(); // Recalculate total price
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Hotel?>(
      future: Hotel.fetchHotelDetails(widget.hotelId), // Ambil detail hotel
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Hotel not found'));
        }

        final hotel = snapshot.data!; // Ambil data hotel

        return Scaffold(
          appBar: AppBar(
            title: const Text("Hotel Details",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          bottomNavigationBar: selectedRoomIndices.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Price: Rp${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            for (var index in selectedRoomIndices) {
                              final room = _rooms[index];

                              // Set tanggal, guest, dan total harga ke object
                              room.startDate = startDates[index];
                              room.endDate = endDates[index];
                              room.guestCount = guestCounts[index];
                              room.totalPrice = roomTotalPrices[index];

                              // Panggil bookRoom dari instance
                              await room.bookRoom();
                            }

                            // Navigasi ke halaman history booking
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HistoryPage()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Booking gagal: $e')),
                            );
                          }
                          // Navigate to booking page
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple),
                        child: const Text("Book Now",
                            style: TextStyle(color: Colors.white)),
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
                  child: Image.asset(
                    'assets/images/hotel.png',
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
                                return const Text("Loading...");
                              } else if (snapshot.hasError) {
                                return const Text("Error");
                              } else {
                                return Text(
                                    snapshot.data ?? "Unknown Location");
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(hotel.description),
                      const SizedBox(height: 20),

                      // Amenities
                      const Text("Amenities",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      ...hotel.amenities.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.green),
                                const SizedBox(width: 10),
                                Text(item),
                              ],
                            ),
                          )),

                      const SizedBox(height: 30),

                      // Room Options
                      const Text("Available Rooms",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Column(
                        children: _rooms.asMap().entries.map((entry) {
                          int index = entry.key;
                          var room = entry.value;
                          bool isSelected = selectedRoomIndices.contains(index);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/room.png", // Ganti dengan gambar kamar jika ada
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(room.type,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      Text("Rp${room.price} / night"),
                                      const SizedBox(height: 12),
                                      // Date Picker for Start Date
                                      OutlinedButton(
                                        onPressed: isSelected
                                            ? () => _pickStartDate(index)
                                            : null,
                                        child: Text(startDates[index] == null
                                            ? 'Pick Start Date'
                                            : 'Start: ${startDates[index]!.toLocal().toString().split(' ')[0]}'),
                                      ),
                                      const SizedBox(height: 8),
                                      // Date Picker for End Date
                                      OutlinedButton(
                                        onPressed: isSelected
                                            ? () => _pickEndDate(index)
                                            : null,
                                        child: Text(endDates[index] == null
                                            ? 'Pick End Date'
                                            : 'End: ${endDates[index]!.toLocal().toString().split(' ')[0]}'),
                                      ),
                                      const SizedBox(height: 8),
                                      // Guest Count Input with Increment/Decrement
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: isSelected
                                                ? () {
                                                    setState(() {
                                                      if (guestCounts[index] >
                                                          1)
                                                        guestCounts[index]--;
                                                      _calculateTotalPrice(); // Recalculate total price
                                                    });
                                                  }
                                                : null,
                                          ),
                                          Expanded(
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                  labelText: 'Guest Count'),
                                              controller: TextEditingController(
                                                  text: guestCounts[index]
                                                      .toString()),
                                              onChanged: (value) {
                                                setState(() {
                                                  guestCounts[index] = int
                                                          .tryParse(value) ??
                                                      1; // Default to 1 if parsing fails
                                                  _calculateTotalPrice(); // Recalculate total price
                                                });
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: isSelected
                                                ? () {
                                                    setState(() {
                                                      guestCounts[index]++;
                                                      _calculateTotalPrice(); // Recalculate total price
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Display Total Price for the room
                                      if (roomTotalPrices[index] > 0)
                                        Text(
                                          'Room Total Price: Rp${roomTotalPrices[index].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          _toggleRoomSelection(
                                              index); // Toggle room selection
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelected
                                              ? Colors.blue
                                              : Colors.grey[500],
                                        ),
                                        child: Text(
                                            isSelected ? "Selected" : "Choose",
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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
