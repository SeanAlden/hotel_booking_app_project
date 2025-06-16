import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/model/room.dart';
import 'package:hotel_booking_app/pages/history_page.dart';
import 'package:intl/intl.dart';

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
  String? userId; // Define userId variable

  // Fungsi untuk memformat harga
  String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
    return formatCurrency.format(amount);
  }

  // Fungsi format tanggal Indonesia
  String formatDate(DateTime? date) {
    if (date == null) return '-';
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    return dateFormat.format(date);
  }

  @override
  void initState() {
    super.initState();
    _fetchRooms(); // Ambil data kamar saat halaman diinisialisasi
    userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID
  }

  // Future<void> _fetchRooms() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('rooms')
  //       .where('hotelId',
  //           isEqualTo: widget.hotelId) // Ambil kamar berdasarkan hotelId
  //       .get();

  //   setState(() {
  //     _rooms = snapshot.docs.map((doc) {
  //       return Room(
  //         id: doc.id,
  //         hotelId: doc['hotelId'],
  //         type: doc['type'],
  //         price: (doc['price'] as num).toDouble(),
  //         startDate: doc['startDate'] != null
  //             ? DateTime.parse(doc['startDate'])
  //             : null,
  //         endDate:
  //             doc['endDate'] != null ? DateTime.parse(doc['endDate']) : null,
  //         guestCount: doc['guestCount'],
  //         totalPrice: doc['totalPrice'],
  //       );
  //     }).toList();

  //     // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
  //     startDates = List<DateTime?>.filled(_rooms.length, null);
  //     endDates = List<DateTime?>.filled(_rooms.length, null);
  //     guestCounts = List<int>.filled(
  //         _rooms.length, 1); // Default guest count for each room
  //     roomTotalPrices =
  //         List<double>.filled(_rooms.length, 0); // Initialize room total prices
  //   });
  // }

  // Future<void> _fetchRooms() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('rooms')
  //       .where('hotelId', isEqualTo: widget.hotelId)
  //       .get();

  //   setState(() {
  //     _rooms = snapshot.docs.map((doc) {
  //       return Room(
  //         id: doc.id,
  //         hotelId: doc['hotelId'],
  //         type: doc['type'],
  //         price: (doc['price'] as num).toDouble(),
  //         startDate: doc['startDate'] != null
  //             ? DateTime.parse(doc['startDate'])
  //             : null,
  //         endDate: doc['endDate'] != null
  //             ? DateTime.parse(doc['endDate'])
  //             : null,
  //         guestCount: doc['guestCount'],
  //         totalPrice: doc['totalPrice'],
  //       );
  //     }).toList();

  //     // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
  //     startDates = List<DateTime?>.filled(_rooms.length, null);
  //     endDates = List<DateTime?>.filled(_rooms.length, null);
  //     guestCounts = List<int>.filled(_rooms.length, 1);
  //     roomTotalPrices = List<double>.filled(_rooms.length, 0);
  //   });

  //   // Fetch bookings for each room
  //   for (var room in _rooms) {
  //     await room.fetchBookings();
  //   }
  // }

  // Future<void> _fetchRooms() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('rooms')
  //       .where('hotelId', isEqualTo: widget.hotelId)
  //       .get();

  //   setState(() {
  //     _rooms = snapshot.docs.map((doc) {
  //       return Room(
  //         id: doc.id,
  //         hotelId: doc['hotelId'],
  //         type: doc['type'],
  //         price: (doc['price'] as num).toDouble(),
  //         startDate: doc['startDate'] != null
  //             ? DateTime.parse(doc['startDate'])
  //             : null,
  //         endDate:
  //             doc['endDate'] != null ? DateTime.parse(doc['endDate']) : null,
  //         guestCount: doc['guestCount'],
  //         totalPrice: doc['totalPrice'],
  //       );
  //     }).toList();

  //     // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
  //     startDates = List<DateTime?>.filled(_rooms.length, null);
  //     endDates = List<DateTime?>.filled(_rooms.length, null);
  //     guestCounts = List<int>.filled(_rooms.length, 1);
  //     roomTotalPrices = List<double>.filled(_rooms.length, 0);
  //   });

  //   // Fetch bookings for each room
  //   for (var room in _rooms) {
  //     await room.fetchBookings();
  //     // Debugging: Print the bookings after fetching
  //     print('Fetched bookings for room ${room.id}: ${room.bookings.length}');
  //   }
  // }

  Future<void> _fetchRooms() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('hotelId', isEqualTo: widget.hotelId)
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
      guestCounts = List<int>.filled(_rooms.length, 1);
      roomTotalPrices = List<double>.filled(_rooms.length, 0);
    });

    // Fetch bookings for each room
    // for (var room in _rooms) {
    //   await room.fetchBookings();
    //   // Debugging: Print the bookings after fetching
    //   print('Fetched bookings for room ${room.id}: ${room.bookings.length}');
    // }

    for (var room in _rooms) {
      await room.fetchBookings();
      print('Bookings for room ${room.id}: ${room.bookings.length}');
      for (var booking in room.bookings) {
        print(
            'Booking from ${booking.startDate} to ${booking.endDate} - Total: ${booking.totalPrice}');
      }
    }

    // After fetching bookings, call setState to update the UI
    setState(() {});
  }

  // Future<void> _fetchRooms() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('rooms')
  //       .where('hotelId', isEqualTo: widget.hotelId)
  //       .get();

  //   setState(() {
  //     _rooms = snapshot.docs.map((doc) {
  //       return Room(
  //         id: doc.id,
  //         hotelId: doc['hotelId'],
  //         type: doc['type'],
  //         price: (doc['price'] as num).toDouble(),
  //         startDate: doc['startDate'] != null
  //             ? DateTime.parse(doc['startDate'])
  //             : null,
  //         endDate:
  //             doc['endDate'] != null ? DateTime.parse(doc['endDate']) : null,
  //         guestCount: doc['guestCount'],
  //         totalPrice: doc['totalPrice'],
  //       );
  //     }).toList();

  //     // Initialize startDates, endDates, guestCounts, and roomTotalPrices lists
  //     startDates = List<DateTime?>.filled(_rooms.length, null);
  //     endDates = List<DateTime?>.filled(_rooms.length, null);
  //     guestCounts = List<int>.filled(_rooms.length, 1);
  //     roomTotalPrices = List<double>.filled(_rooms.length, 0);
  //   });

  //   // Fetch bookings for each room, passing the userId
  //   for (var room in _rooms) {
  //     await room.fetchBookings(userId!); // Pass userId here
  //     // Debugging: Print the bookings after fetching
  //     print('Fetched bookings for room ${room.id}: ${room.bookings.length}');
  //   }
  // }

  // bool _isBookingConflict(int index) {
  //   final selectedStartDate = startDates[index];
  //   final selectedEndDate = endDates[index];

  //   if (selectedStartDate == null || selectedEndDate == null) {
  //     return false; // No dates selected
  //   }

  //   for (var booking in _rooms[index].bookings) {
  //     if ((selectedStartDate.isBefore(booking.endDate) &&
  //         selectedEndDate.isAfter(booking.startDate))) {
  //       return true; // Conflict found
  //     }
  //   }
  //   return false; // No conflict
  // }

  // bool _isBookingConflict(int index) {
  //   final selectedStartDate = startDates[index];
  //   final selectedEndDate = endDates[index];

  //   if (selectedStartDate == null || selectedEndDate == null) {
  //     return false; // No dates selected
  //   }

  //   for (var booking in _rooms[index].bookings) {
  //     // Check if the selected dates overlap with existing bookings
  //     if ((selectedStartDate.isBefore(booking.endDate) &&
  //             selectedEndDate.isAfter(booking.startDate)) ||
  //         (selectedStartDate.isAtSameMomentAs(booking.startDate) ||
  //             selectedEndDate.isAtSameMomentAs(booking.endDate))) {
  //       return true; // Conflict found
  //     }
  //   }
  //   return false; // No conflict
  // }

  bool _isBookingConflict(int index) {
    final selectedStartDate = startDates[index];
    final selectedEndDate = endDates[index];

    if (selectedStartDate == null || selectedEndDate == null) {
      return false; // No dates selected
    }

    for (var booking in _rooms[index].bookings) {
      // Check if the selected dates overlap with existing bookings
      bool isOverlapping = (selectedStartDate.isBefore(booking.endDate) &&
              selectedEndDate.isAfter(booking.startDate)) ||
          (selectedStartDate.isAtSameMomentAs(booking.startDate) ||
              selectedEndDate.isAtSameMomentAs(booking.endDate)) ||
          (selectedStartDate.isAtSameMomentAs(booking.endDate) ||
              selectedEndDate.isAtSameMomentAs(booking.startDate)) ||
          (selectedStartDate.isAfter(booking.startDate) &&
              selectedEndDate.isBefore(booking.endDate)) ||
          (selectedStartDate.isBefore(booking.startDate) &&
              selectedEndDate.isAfter(booking.endDate));

      if (isOverlapping) {
        return true; // Conflict found
      }
    }
    return false; // No conflict
  }

  String _getRoomStatus(int index) {
    // Check if the room is booked or in use
    for (var booking in _rooms[index].bookings) {
      if (booking.startDate.isBefore(DateTime.now()) &&
          booking.endDate.isAfter(DateTime.now())) {
        return "In Use"; // Room is currently in use
      } else if (booking.startDate.isAfter(DateTime.now()) &&
          booking.endDate.isAfter(DateTime.now()) &&
          booking.userId == userId) {
        return "Booked"; // Room is booked by the current user
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

  // Future<void> _pickStartDate(int index) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: startDates[index] ?? DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != startDates[index]) {
  //     setState(() {
  //       startDates[index] = picked;
  //       _calculateTotalPrice(); // Recalculate total price
  //     });
  //   }
  // }

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

        // Check if the end date is set and if the start date is after or equal to the end date
        if (endDates[index] != null &&
            startDates[index]!.isAfter(endDates[index]!)) {
          endDates[index] = null; // Reset end date if invalid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Start date cannot be after or equal to end date.')),
          );
        }

        _calculateTotalPrice(); // Recalculate total price
      });
    }
  }

  // Future<void> _pickEndDate(int index) async {
  //   if (startDates[index] == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Please pick start date first')));
  //     return;
  //   }
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate:
  //         endDates[index] ?? startDates[index]!.add(const Duration(days: 1)),
  //     firstDate: startDates[index]!.add(const Duration(days: 1)),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != endDates[index]) {
  //     setState(() {
  //       endDates[index] = picked;
  //       _calculateTotalPrice(); // Recalculate total price
  //     });
  //   }
  // }

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
      firstDate: startDates[index]!
          .add(const Duration(days: 1)), // Ensure end date is after start date
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDates[index]) {
      setState(() {
        endDates[index] = picked;

        // Check if the start date is set and if the end date is before or equal to the start date
        if (endDates[index]!.isBefore(startDates[index]!) ||
            endDates[index]!.isAtSameMomentAs(startDates[index]!)) {
          startDates[index] = null; // Reset start date if invalid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('End date cannot be before or equal to start date.')),
          );
        }

        _calculateTotalPrice(); // Recalculate total price
      });
    }
  }

  // void _toggleRoomSelection(int index) {
  //   setState(() {
  //     if (selectedRoomIndices.contains(index)) {
  //       selectedRoomIndices.remove(index); // Deselect room
  //       startDates[index] = null; // Reset start date
  //       endDates[index] = null; // Reset end date
  //       guestCounts[index] = 1; // Reset guest count
  //       roomTotalPrices[index] = 0; // Reset room total price
  //     } else {
  //       selectedRoomIndices.add(index); // Select room
  //     }
  //     _calculateTotalPrice(); // Recalculate total price
  //   });
  // }

  Future<void> _toggleRoomSelection(int index) async {
    setState(() {
      if (selectedRoomIndices.contains(index)) {
        selectedRoomIndices.remove(index);
        startDates[index] = null;
        endDates[index] = null;
        guestCounts[index] = 1;
        roomTotalPrices[index] = 0;
      } else {
        if (_isBookingConflict(index)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Room is already booked for the selected dates')),
          );
          return; // Prevent selection if there's a conflict
        }
        selectedRoomIndices.add(index);
      }
      _calculateTotalPrice();
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
                      Text('Total Price: ${formatCurrency(totalPrice)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     try {
                      //       for (var index in selectedRoomIndices) {
                      //         final room = _rooms[index];

                      //         // Set tanggal, guest, dan total harga ke object
                      //         room.startDate = startDates[index];
                      //         room.endDate = endDates[index];
                      //         room.guestCount = guestCounts[index];
                      //         room.totalPrice = roomTotalPrices[index];

                      //         // Panggil bookRoom dari instance
                      //         await room.bookRoom();
                      //       }

                      //       // Navigasi ke halaman history booking
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (_) => const HistoryPage()),
                      //       );
                      //     } catch (e) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text('Booking gagal: $e')),
                      //       );
                      //     }
                      //     // Navigate to booking page
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.deepPurple),
                      //   child: const Text("Book Now",
                      //       style: TextStyle(color: Colors.white)),
                      // ),

                      // ElevatedButton(
                      //   onPressed: () async {
                      //     try {
                      //       for (var index in selectedRoomIndices) {
                      //         final room = _rooms[index];

                      //         // Set tanggal, guest, dan total harga ke object
                      //         room.startDate = startDates[index];
                      //         room.endDate = endDates[index];
                      //         room.guestCount = guestCounts[index];
                      //         room.totalPrice = roomTotalPrices[index];

                      //         // Panggil bookRoom dari instance
                      //         await room.bookRoom(userId!); // Pass userId here
                      //       }

                      //       // Navigasi ke halaman history booking
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (_) => const HistoryPage()),
                      //       );
                      //     } catch (e) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text('Booking gagal: $e')),
                      //       );
                      //     }
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.deepPurple),
                      //   child: const Text("Book Now",
                      //       style: TextStyle(color: Colors.white)),
                      // ),

                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // Check for booking conflicts before proceeding
                            for (var index in selectedRoomIndices) {
                              if (_isBookingConflict(index)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Room is already booked for the selected dates'),
                                  ),
                                );
                                return; // Prevent booking if there's a conflict
                              }
                            }

                            // Proceed with booking if no conflicts are found
                            for (var index in selectedRoomIndices) {
                              final room = _rooms[index];

                              // Set tanggal, guest, dan total harga ke object
                              room.startDate = startDates[index];
                              room.endDate = endDates[index];
                              room.guestCount = guestCounts[index];
                              room.totalPrice = roomTotalPrices[index];

                              // Panggil bookRoom dari instance
                              await room.bookRoom(userId!); // Pass userId here
                            }

                            // Navigasi ke halaman history booking
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HistoryPage()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Booking gagal: $e')),
                            );
                          }
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
                      // Column(
                      //   children: _rooms.asMap().entries.map((entry) {
                      //     int index = entry.key;
                      //     var room = entry.value;
                      //     bool isSelected = selectedRoomIndices.contains(index);

                      //     return Card(
                      //       margin: const EdgeInsets.only(bottom: 16),
                      //       shape: RoundedRectangleBorder(
                      //         side: BorderSide(
                      //             color: isSelected
                      //                 ? Colors.deepPurple
                      //                 : Colors.grey.shade300),
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Image.asset(
                      //             "assets/images/room.png", // Ganti dengan gambar kamar jika ada
                      //             height: 150,
                      //             width: double.infinity,
                      //             fit: BoxFit.contain,
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.all(12.0),
                      //             child: Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.start,
                      //               children: [
                      //                 Text(room.type,
                      //                     style: const TextStyle(
                      //                         fontSize: 18,
                      //                         fontWeight: FontWeight.w600)),
                      //                 const SizedBox(height: 8),
                      //                 Text(
                      //                     "${formatCurrency(room.price)} / night"),
                      //                 // Display existing bookings
                      //                 const Text("Existing Bookings:",
                      //                     style: TextStyle(
                      //                         fontWeight: FontWeight.bold)),
                      //                 ...room.bookings.map((booking) {
                      //                   return Text(
                      //                       '> From ${formatDate(booking.startDate)} To ${formatDate(booking.endDate)} - Total: ${formatCurrency(booking.totalPrice)}');
                      //                 }).toList(),
                      //                 const SizedBox(height: 12),
                      //                 // Date Picker for Start Date
                      //                 OutlinedButton(
                      //                   onPressed: isSelected
                      //                       ? () => _pickStartDate(index)
                      //                       : null,
                      //                   child: Text(startDates[index] == null
                      //                       ? 'Pick Start Date'
                      //                       : 'Start: ${formatDate(startDates[index]!)}'),
                      //                 ),
                      //                 const SizedBox(height: 8),
                      //                 // Date Picker for End Date
                      //                 OutlinedButton(
                      //                   onPressed: isSelected
                      //                       ? () => _pickEndDate(index)
                      //                       : null,
                      //                   child: Text(endDates[index] == null
                      //                       ? 'Pick End Date'
                      //                       : 'End: ${formatDate(endDates[index]!)}'),
                      //                 ),
                      //                 const SizedBox(height: 8),
                      //                 // Guest Count Input with Increment/Decrement
                      //                 Row(
                      //                   children: [
                      //                     IconButton(
                      //                       icon: const Icon(Icons.remove),
                      //                       onPressed: isSelected
                      //                           ? () {
                      //                               setState(() {
                      //                                 if (guestCounts[index] >
                      //                                     1)
                      //                                   guestCounts[index]--;
                      //                                 _calculateTotalPrice(); // Recalculate total price
                      //                               });
                      //                             }
                      //                           : null,
                      //                     ),
                      //                     Expanded(
                      //                       child: TextField(
                      //                         keyboardType:
                      //                             TextInputType.number,
                      //                         decoration: const InputDecoration(
                      //                             labelText: 'Guest Count'),
                      //                         controller: TextEditingController(
                      //                             text: guestCounts[index]
                      //                                 .toString()),
                      //                         onChanged: (value) {
                      //                           setState(() {
                      //                             guestCounts[index] = int
                      //                                     .tryParse(value) ??
                      //                                 1; // Default to 1 if parsing fails
                      //                             _calculateTotalPrice(); // Recalculate total price
                      //                           });
                      //                         },
                      //                       ),
                      //                     ),
                      //                     IconButton(
                      //                       icon: const Icon(Icons.add),
                      //                       onPressed: isSelected
                      //                           ? () {
                      //                               setState(() {
                      //                                 guestCounts[index]++;
                      //                                 _calculateTotalPrice(); // Recalculate total price
                      //                               });
                      //                             }
                      //                           : null,
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const SizedBox(height: 12),
                      //                 // Display Total Price for the room
                      //                 if (roomTotalPrices[index] > 0)
                      //                   Text(
                      //                     'Room Total Price: ${formatCurrency(roomTotalPrices[index])}',
                      //                     style: const TextStyle(
                      //                         fontWeight: FontWeight.bold,
                      //                         fontSize: 16),
                      //                   ),
                      //                 const SizedBox(height: 12),
                      //                 ElevatedButton(
                      //                   onPressed: () {
                      //                     _toggleRoomSelection(
                      //                         index); // Toggle room selection
                      //                   },
                      //                   style: ElevatedButton.styleFrom(
                      //                     backgroundColor: isSelected
                      //                         ? Colors.blue
                      //                         : Colors.grey[500],
                      //                   ),
                      //                   child: Text(
                      //                       isSelected ? "Selected" : "Choose",
                      //                       style: const TextStyle(
                      //                           color: Colors.white)),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),

                      // Column(
                      //   children: _rooms.asMap().entries.map((entry) {
                      //     int index = entry.key;
                      //     var room = entry.value;
                      //     bool isSelected = selectedRoomIndices.contains(index);
                      //     String roomStatus =
                      //         _getRoomStatus(index); // Get the room status

                      //     return Card(
                      //       margin: const EdgeInsets.only(bottom: 16),
                      //       shape: RoundedRectangleBorder(
                      //         side: BorderSide(
                      //             color: isSelected
                      //                 ? Colors.deepPurple
                      //                 : Colors.grey.shade300),
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Image.asset(
                      //             "assets/images/room.png", // Ganti dengan gambar kamar jika ada
                      //             height: 150,
                      //             width: double.infinity,
                      //             fit: BoxFit.contain,
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.all(12.0),
                      //             child: Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.start,
                      //               children: [
                      //                 Text(room.type,
                      //                     style: const TextStyle(
                      //                         fontSize: 18,
                      //                         fontWeight: FontWeight.w600)),
                      //                 const SizedBox(height: 8),
                      //                 Text(
                      //                     "${formatCurrency(room.price)} / night"),
                      //                 // // Display existing bookings
                      //                 // const Text("Existing Bookings:",
                      //                 //     style: TextStyle(
                      //                 //         fontWeight: FontWeight.bold)),
                      //                 // ...room.bookings.map((booking) {
                      //                 //   return Text(
                      //                 //       '> From ${formatDate(booking.startDate)} To ${formatDate(booking.endDate)} - Total: ${formatCurrency(booking.totalPrice)}');
                      //                 // }).toList(),
                      //                 // Display existing bookings
                      //                 const Text("Existing Bookings:",
                      //                     style: TextStyle(
                      //                         fontWeight: FontWeight.bold)),
                      //                 ...room.bookings.map((booking) {
                      //                   return Text(
                      //                     '> From ${formatDate(booking.startDate)} To ${formatDate(booking.endDate)} - Total: ${formatCurrency(booking.totalPrice)}',
                      //                     style: TextStyle(
                      //                       color: booking.userId == userId
                      //                           ? Colors.orange[800]
                      //                           : Colors
                      //                               .black, // Change color based on userId
                      //                     ),
                      //                   );
                      //                 }).toList(),
                      //                 const SizedBox(height: 12),
                      //                 // Date Picker for Start Date
                      //                 OutlinedButton(
                      //                   onPressed: isSelected
                      //                       ? () => _pickStartDate(index)
                      //                       : null,
                      //                   child: Text(startDates[index] == null
                      //                       ? 'Pick Start Date'
                      //                       : 'Start: ${formatDate(startDates[index]!)}'),
                      //                 ),
                      //                 const SizedBox(height: 8),
                      //                 // Date Picker for End Date
                      //                 OutlinedButton(
                      //                   onPressed: isSelected
                      //                       ? () => _pickEndDate(index)
                      //                       : null,
                      //                   child: Text(endDates[index] == null
                      //                       ? 'Pick End Date'
                      //                       : 'End: ${formatDate(endDates[index]!)}'),
                      //                 ),
                      //                 const SizedBox(height: 8),
                      //                 // Guest Count Input with Increment/Decrement
                      //                 Row(
                      //                   children: [
                      //                     IconButton(
                      //                       icon: const Icon(Icons.remove),
                      //                       onPressed: isSelected
                      //                           ? () {
                      //                               setState(() {
                      //                                 if (guestCounts[index] >
                      //                                     1)
                      //                                   guestCounts[index]--;
                      //                                 _calculateTotalPrice(); // Recalculate total price
                      //                               });
                      //                             }
                      //                           : null,
                      //                     ),
                      //                     Expanded(
                      //                       child: TextField(
                      //                         keyboardType:
                      //                             TextInputType.number,
                      //                         decoration: const InputDecoration(
                      //                             labelText: 'Guest Count'),
                      //                         controller: TextEditingController(
                      //                             text: guestCounts[index]
                      //                                 .toString()),
                      //                         onChanged: (value) {
                      //                           setState(() {
                      //                             guestCounts[index] = int
                      //                                     .tryParse(value) ??
                      //                                 1; // Default to 1 if parsing fails
                      //                             _calculateTotalPrice(); // Recalculate total price
                      //                           });
                      //                         },
                      //                       ),
                      //                     ),
                      //                     IconButton(
                      //                       icon: const Icon(Icons.add),
                      //                       onPressed: isSelected
                      //                           ? () {
                      //                               setState(() {
                      //                                 guestCounts[index]++;
                      //                                 _calculateTotalPrice(); // Recalculate total price
                      //                               });
                      //                             }
                      //                           : null,
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const SizedBox(height: 12),
                      //                 // Display Total Price for the room
                      //                 if (roomTotalPrices[index] > 0)
                      //                   Text(
                      //                     'Room Total Price: ${formatCurrency(roomTotalPrices[index])}',
                      //                     style: const TextStyle(
                      //                         fontWeight: FontWeight.bold,
                      //                         fontSize: 16),
                      //                   ),
                      //                 const SizedBox(height: 12),
                      //                 // Display booking status
                      //                 if (roomStatus.isNotEmpty)
                      //                   Text(
                      //                     roomStatus,
                      //                     style: TextStyle(
                      //                       color: roomStatus == "In Use"
                      //                           ? Colors.red
                      //                           : Colors.orange,
                      //                       fontWeight: FontWeight.bold,
                      //                     ),
                      //                   ),
                      //                 const SizedBox(height: 12),
                      //                 ElevatedButton(
                      //                   onPressed: roomStatus == "Booked"
                      //                       ? null
                      //                       : () {
                      //                           _toggleRoomSelection(
                      //                               index); // Toggle room selection
                      //                         },
                      //                   style: ElevatedButton.styleFrom(
                      //                     backgroundColor: isSelected
                      //                         ? Colors.blue
                      //                         : Colors.grey[500],
                      //                   ),
                      //                   child: Text(
                      //                       isSelected ? "Selected" : "Choose",
                      //                       style: const TextStyle(
                      //                           color: Colors.white)),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),

                      Column(
                        children: _rooms.asMap().entries.map((entry) {
                          int index = entry.key;
                          var room = entry.value;
                          bool isSelected = selectedRoomIndices.contains(index);
                          String roomStatus = _getRoomStatus(index);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.asset(
                                    "assets/images/room.png",
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(room.type,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          )),
                                      const SizedBox(height: 8),
                                      Text(
                                          "${formatCurrency(room.price)} / night",
                                          style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 12),

                                      const Text("Existing Bookings:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      ...room.bookings.map((booking) {
                                        return Text(
                                          '> From ${formatDate(booking.startDate)} To ${formatDate(booking.endDate)} - Total: ${formatCurrency(booking.totalPrice)}',
                                          style: TextStyle(
                                            color: booking.userId == userId
                                                ? Colors.orange[800]
                                                : Colors.black,
                                          ),
                                        );
                                      }).toList(),

                                      const SizedBox(height: 16),

                                      /// Start Date Picker
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton.icon(
                                              onPressed: isSelected
                                                  ? () => _pickStartDate(index)
                                                  : null,
                                              icon: const Icon(Icons.date_range),
                                              label: Text(startDates[index] ==
                                                      null
                                                  ? 'Pick Start Date'
                                                  : 'Start: ${formatDate(startDates[index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextButton.icon(
                                              onPressed: isSelected
                                                  ? () => _pickEndDate(index)
                                                  : null,
                                              icon: const Icon(
                                                  Icons.date_range_outlined),
                                              label: Text(endDates[index] == null
                                                  ? 'Pick End Date'
                                                  : 'End: ${formatDate(endDates[index]!)}', overflow: TextOverflow.ellipsis, maxLines: 2,),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      /// Guest Count
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          OutlinedButton(
                                            onPressed: isSelected &&
                                                    guestCounts[index] > 1
                                                ? () {
                                                    setState(() {
                                                      guestCounts[index]--;
                                                      _calculateTotalPrice();
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: Text(
                                              '${guestCounts[index]} Guest${guestCounts[index] > 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: isSelected
                                                ? () {
                                                    setState(() {
                                                      guestCounts[index]++;
                                                      _calculateTotalPrice();
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

                                      /// Total Price
                                      if (roomTotalPrices[index] > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Room Total Price: ${formatCurrency(roomTotalPrices[index])}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.green),
                                          ),
                                        ),

                                      /// Room Status
                                      if (roomStatus.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: roomStatus == "In Use"
                                                ? Colors.red.shade50
                                                : Colors.orange.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            roomStatus,
                                            style: TextStyle(
                                              color: roomStatus == "In Use"
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
                                          onPressed: roomStatus == "Booked"
                                              ? null
                                              : () {
                                                  _toggleRoomSelection(index);
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isSelected
                                                ? Colors.blue
                                                : Colors.grey[500],
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            isSelected ? "Selected" : "Choose",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
