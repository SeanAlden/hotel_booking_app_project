// import 'dart:io';
// import 'dart:typed_data'; // Needed for Uint8List
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart'; // For image picking
// import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/room.dart';

// class EditRoomPage extends StatefulWidget {
//   final String roomId; // Pass the roomId to be edited

//   const EditRoomPage({Key? key, required this.roomId}) : super(key: key);

//   @override
//   _EditRoomPageState createState() => _EditRoomPageState();
// }

// class _EditRoomPageState extends State<EditRoomPage> {
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _guestCountController = TextEditingController();

//   String? _selectedHotelId;
//   List<Hotel> _hotels = [];

//   // These fields are typically for booking data, but kept here for consistency
//   // if your Room model stores them for some initial/default availability.
//   DateTime? _startDate;
//   DateTime? _endDate;
//   double? _totalPrice;

//   Uint8List? _imageBytes; // Holds image bytes for display/update
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoadingData = true; // To show loading while fetching existing data

//   @override
//   void initState() {
//     super.initState();
//     _fetchHotels();
//     _guestCountController.addListener(_recalculateTotalPrice);
//     _priceController.addListener(_recalculateTotalPrice);
//     _loadExistingRoomData(); // Load data of the room to be edited
//   }

//   @override
//   void dispose() {
//     _typeController.dispose();
//     _priceController.dispose();
//     _guestCountController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchHotels() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('hotels').get();
//       setState(() {
//         _hotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
//       });
//       debugPrint('EditRoomPage: Fetched ${_hotels.length} hotels.');
//     } catch (e) {
//       debugPrint('EditRoomPage: Error fetching hotels: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching hotels: $e')),
//       );
//     }
//   }

//   Future<void> _loadExistingRoomData() async {
//     try {
//       DocumentSnapshot roomDoc = await FirebaseFirestore.instance
//           .collection('rooms')
//           .doc(widget.roomId)
//           .get();

//       if (roomDoc.exists) {
//         final data = roomDoc.data() as Map<String, dynamic>;
//         _typeController.text = data['type'] ?? '';
//         _priceController.text = (data['price'] as num?)?.toString() ?? '';
//         _guestCountController.text = (data['guestCount'] as num?)?.toString() ?? ''; // Load guestCount
//         _selectedHotelId = data['hotelId'];

//         // If you stored startDate/endDate/totalPrice in room itself, load them:
//         if (data['startDate'] is String && data['startDate'].isNotEmpty) {
//           _startDate = DateTime.parse(data['startDate']);
//         }
//         if (data['endDate'] is String && data['endDate'].isNotEmpty) {
//           _endDate = DateTime.parse(data['endDate']);
//         }
//         _totalPrice = (data['totalPrice'] as num?)?.toDouble();

//         // Load existing image from Hive
//         final roomImagesBox = Hive.box<Uint8List>('room_images');
//         final Uint8List? existingImageBytes = roomImagesBox.get(widget.roomId);
//         setState(() {
//           _imageBytes = existingImageBytes;
//         });
//         debugPrint('EditRoomPage: Existing room data loaded for ID: ${widget.roomId}');
//         debugPrint('EditRoomPage: Image loaded from Hive: ${existingImageBytes != null ? 'Yes' : 'No'}');
//       } else {
//         debugPrint('EditRoomPage: Room with ID ${widget.roomId} not found in Firestore.');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Room data not found!')),
//         );
//       }
//     } catch (e) {
//       debugPrint('EditRoomPage: Error loading existing room data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading room data: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoadingData = false;
//       });
//     }
//   }

//   void _recalculateTotalPrice() {
//     final price = double.tryParse(_priceController.text);
//     final guestCount = int.tryParse(_guestCountController.text);
//     if (_startDate != null &&
//         _endDate != null &&
//         price != null &&
//         guestCount != null) {
//       final nights = _endDate!.difference(_startDate!).inDays;
//       if (nights > 0) {
//         setState(() {
//           _totalPrice = nights * price * guestCount;
//         });
//         debugPrint('EditRoomPage: Recalculated total price: $_totalPrice');
//         return;
//       }
//     }
//     setState(() {
//       _totalPrice = null;
//     });
//   }

//   Future<void> _pickImage() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final bytes = await pickedFile.readAsBytes();
//       setState(() {
//         _imageBytes = bytes; // Store bytes directly
//       });
//       debugPrint('EditRoomPage: New image picked from: ${pickedFile.path}, size: ${bytes.lengthInBytes} bytes');
//     } else {
//       debugPrint('EditRoomPage: Image picking cancelled.');
//     }
//   }

//   Future<void> _updateRoom() async {
//     final type = _typeController.text.trim();
//     final price = double.tryParse(_priceController.text);
//     final guestCount = int.tryParse(_guestCountController.text);

//     if (_selectedHotelId == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Please select a hotel')));
//       return;
//     }
//     if (type.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter room type')));
//       return;
//     }
//     if (price == null || price < 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter valid price')));
//       return;
//     }

//     double? calculatedTotalPrice;
//     if (_startDate != null && _endDate != null && guestCount != null && guestCount > 0) {
//       final nights = _endDate!.difference(_startDate!).inDays;
//       if (nights > 0) {
//         calculatedTotalPrice = nights * price * guestCount;
//       }
//     }

//     final roomData = {
//       'hotelId': _selectedHotelId!,
//       'type': type,
//       'price': price,
//       'guestCount': guestCount, // Store guestCount as part of room data
//       // Store dates and total price only if they are truly part of the room definition
//       // (e.g., a default booking duration/price for this room type),
//       // otherwise, they belong only in booking history.
//       'startDate': _startDate?.toIso8601String(),
//       'endDate': _endDate?.toIso8601String(),
//       'totalPrice': calculatedTotalPrice,
//     };

//     try {
//       await FirebaseFirestore.instance
//           .collection('rooms')
//           .doc(widget.roomId)
//           .update(roomData);
//       debugPrint('EditRoomPage: Room ID ${widget.roomId} updated in Firestore.');

//       final roomImagesBox = Hive.box<Uint8List>('room_images');
//       if (_imageBytes != null) {
//         await roomImagesBox.put(widget.roomId, _imageBytes!);
//         debugPrint('EditRoomPage: Image bytes updated in Hive for key: ${widget.roomId}');
//       } else {
//         await roomImagesBox.delete(widget.roomId);
//         debugPrint('EditRoomPage: Image removed from Hive for key: ${widget.roomId}');
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Room updated successfully!')));

//       Navigator.pop(context, true); // Pop back and indicate success
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to update room: $e')));
//       debugPrint('EditRoomPage: Error updating room: $e');
//     }
//   }

//   Future<void> _pickStartDate() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _startDate ?? now,
//       firstDate: DateTime(now.year - 1),
//       lastDate: DateTime(now.year + 5),
//     );
//     if (picked != null) {
//       setState(() {
//         _startDate = picked;
//         if (_endDate != null && _endDate!.isBefore(picked)) {
//           _endDate = null;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('End date reset: must be after start date.')),
//           );
//         }
//       });
//       _recalculateTotalPrice();
//     }
//   }

//   Future<void> _pickEndDate() async {
//     if (_startDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please pick start date first')));
//       return;
//     }
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
//       firstDate: _startDate!
//           .add(const Duration(days: 1)),
//       lastDate: DateTime(_startDate!.year + 5),
//     );
//     if (picked != null) {
//       setState(() {
//         _endDate = picked;
//       });
//       _recalculateTotalPrice();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoadingData) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Edit Room', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.blue,
//           iconTheme: const IconThemeData(color: Colors.white),
//         ),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Room', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 labelText: 'Select Hotel',
//                 border: OutlineInputBorder(),
//               ),
//               hint: const Text('Select Hotel'),
//               value: _selectedHotelId,
//               items: _hotels.map((hotel) {
//                 return DropdownMenuItem(
//                   value: hotel.id,
//                   child: Text(hotel.name),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedHotelId = val;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _typeController,
//               decoration: const InputDecoration(
//                   labelText: 'Room Type', border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _priceController,
//               decoration: const InputDecoration(
//                   labelText: 'Price per Night', border: OutlineInputBorder()),
//               keyboardType:
//                   const TextInputType.numberWithOptions(decimal: true),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _guestCountController,
//               decoration: const InputDecoration(
//                   labelText: 'Guest Capacity',
//                   border: OutlineInputBorder()),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickStartDate,
//                     child: Text(_startDate == null
//                         ? 'Pick Start Date (Optional Booking)'
//                         : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickEndDate,
//                     child: Text(_endDate == null
//                         ? 'Pick End Date (Optional Booking)'
//                         : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_totalPrice != null)
//               Text(
//                 'Total Price (for selected dates/guests): \$${_totalPrice!.toStringAsFixed(2)}',
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             const SizedBox(height: 16),
//             _imageBytes == null
//                 ? const Text('No image selected for room.')
//                 : Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _pickImage,
//                     icon: const Icon(Icons.image),
//                     label: const Text('Pick New Image'),
//                   ),
//                 ),
//                 if (_imageBytes != null) // Option to remove existing image
//                   const SizedBox(width: 8),
//                 if (_imageBytes != null)
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           _imageBytes = null; // Clear the image
//                         });
//                         debugPrint('EditRoomPage: Image cleared by user.');
//                       },
//                       icon: const Icon(Icons.clear),
//                       label: const Text('Remove Image'),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _updateRoom,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Update Room', style: TextStyle(fontSize: 18)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/room.dart';

class EditRoomPage extends StatefulWidget {
  final String roomId; // Pass the roomId to be edited

  const EditRoomPage({Key? key, required this.roomId}) : super(key: key);

  @override
  _EditRoomPageState createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController();

  String? _selectedHotelId;
  List<Hotel> _hotels = [];

  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalPrice;

  Uint8List? _imageBytes; // Holds image bytes for display/update
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingData = true; // To show loading while fetching existing data

  @override
  void initState() {
    super.initState();
    _fetchHotels();
    _guestCountController.addListener(_recalculateTotalPrice);
    _priceController.addListener(_recalculateTotalPrice);
    _loadExistingRoomData(); // Load data of the room to be edited
  }

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    _guestCountController.dispose();
    super.dispose();
  }

  Future<void> _fetchHotels() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('hotels').get();
      setState(() {
        _hotels = snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      });
      debugPrint('EditRoomPage: Fetched ${_hotels.length} hotels.');
    } catch (e) {
      debugPrint('EditRoomPage: Error fetching hotels: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching hotels: $e')),
      );
    }
  }

  Future<void> _loadExistingRoomData() async {
    try {
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .get();

      if (roomDoc.exists) {
        final data = roomDoc.data() as Map<String, dynamic>;
        _typeController.text = data['type'] ?? '';
        _priceController.text = (data['price'] as num?)?.toString() ?? '';
        _guestCountController.text = (data['guestCount'] as num?)?.toString() ?? ''; // Load guestCount
        _selectedHotelId = data['hotelId'];

        if (data['startDate'] is String && data['startDate'].isNotEmpty) {
          _startDate = DateTime.parse(data['startDate']);
        }
        if (data['endDate'] is String && data['endDate'].isNotEmpty) {
          _endDate = DateTime.parse(data['endDate']);
        }
        _totalPrice = (data['totalPrice'] as num?)?.toDouble();

        // Load existing image from Hive
        final roomImagesBox = Hive.box<Uint8List>('room_images');
        final Uint8List? existingImageBytes = roomImagesBox.get(widget.roomId);
        setState(() {
          _imageBytes = existingImageBytes;
        });
        debugPrint('EditRoomPage: Existing room data loaded for ID: ${widget.roomId}');
        debugPrint('EditRoomPage: Image loaded from Hive: ${existingImageBytes != null ? 'Yes' : 'No'}');
      } else {
        debugPrint('EditRoomPage: Room with ID ${widget.roomId} not found in Firestore.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room data not found!')),
        );
      }
    } catch (e) {
      debugPrint('EditRoomPage: Error loading existing room data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading room data: $e')),
      );
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _recalculateTotalPrice() {
    final price = double.tryParse(_priceController.text);
    final guestCount = int.tryParse(_guestCountController.text);
    if (_startDate != null &&
        _endDate != null &&
        price != null &&
        guestCount != null) {
      final nights = _endDate!.difference(_startDate!).inDays;
      if (nights > 0) {
        setState(() {
          _totalPrice = nights * price * guestCount;
        });
        debugPrint('EditRoomPage: Recalculated total price: $_totalPrice');
        return;
      }
    }
    setState(() {
      _totalPrice = null;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes; // Store bytes directly
      });
      debugPrint('EditRoomPage: New image picked from: ${pickedFile.path}, size: ${bytes.lengthInBytes} bytes');
    } else {
      debugPrint('EditRoomPage: Image picking cancelled.');
    }
  }

  Future<void> _updateRoom() async {
    final type = _typeController.text.trim();
    final price = double.tryParse(_priceController.text);
    final guestCount = int.tryParse(_guestCountController.text);

    if (_selectedHotelId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a hotel')));
      return;
    }
    if (type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter room type')));
      return;
    }
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid price')));
      return;
    }

    if (guestCount == null || guestCount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid guest capacity')));
      return;
    }

    double? calculatedTotalPrice;
    if (_startDate != null && _endDate != null && guestCount != null && guestCount > 0) {
      final nights = _endDate!.difference(_startDate!).inDays;
      if (nights > 0) {
        calculatedTotalPrice = nights * price * guestCount;
      }
    }

    final roomData = {
      'hotelId': _selectedHotelId!,
      'type': type,
      'price': price,
      'guestCount': guestCount, // Store guestCount as part of room data
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'totalPrice': calculatedTotalPrice,
    };

    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .update(roomData);
      debugPrint('EditRoomPage: Room ID ${widget.roomId} updated in Firestore.');

      final roomImagesBox = Hive.box<Uint8List>('room_images');
      if (_imageBytes != null) {
        await roomImagesBox.put(widget.roomId, _imageBytes!);
        debugPrint('EditRoomPage: Image bytes updated in Hive for key: ${widget.roomId}');
      } else {
        await roomImagesBox.delete(widget.roomId);
        debugPrint('EditRoomPage: Image removed from Hive for key: ${widget.roomId}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room updated successfully!')));

      // IMPORTANT: Pop with 'true' to indicate success
      Navigator.pop(context, true); 

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update room: $e')));
      debugPrint('EditRoomPage: Error updating room: $e');
      // Pop with 'false' to indicate failure or just pop without result
      Navigator.pop(context, false);
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('End date reset: must be after start date.')),
          );
        }
      });
      _recalculateTotalPrice();
    }
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick start date first')));
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!
          .add(const Duration(days: 1)),
      lastDate: DateTime(_startDate!.year + 5),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _recalculateTotalPrice();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Room', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Room', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Hotel',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select Hotel'),
              value: _selectedHotelId,
              items: _hotels.map((hotel) {
                return DropdownMenuItem(
                  value: hotel.id,
                  child: Text(hotel.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedHotelId = val;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                  labelText: 'Room Type', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                  labelText: 'Price per Night', border: OutlineInputBorder()),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _guestCountController,
              decoration: const InputDecoration(
                  labelText: 'Guest Capacity',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: _pickStartDate,
            //         child: Text(_startDate == null
            //             ? 'Pick Start Date (Optional Booking)'
            //             : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}'),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: _pickEndDate,
            //         child: Text(_endDate == null
            //             ? 'Pick End Date (Optional Booking)'
            //             : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}'),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 16),
            if (_totalPrice != null)
              Text(
                'Total Price (for selected dates/guests): \$${_totalPrice!.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            const SizedBox(height: 16),
            _imageBytes == null
                ? const Text('No image selected for room.')
                : Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick New Image'),
                  ),
                ),
                if (_imageBytes != null) // Option to remove existing image
                  const SizedBox(width: 8),
                if (_imageBytes != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _imageBytes = null; // Clear the image
                        });
                        debugPrint('EditRoomPage: Image cleared by user.');
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Remove Image'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Update Room', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
