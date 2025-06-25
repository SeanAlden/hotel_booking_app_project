// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/room.dart';

// class AdminRoomAddPage extends StatefulWidget {
//   @override
//   _AdminRoomAddPageState createState() => _AdminRoomAddPageState();
// }

// class _AdminRoomAddPageState extends State<AdminRoomAddPage> {
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _guestCountController = TextEditingController();

//   String? _selectedHotelId;
//   List<Hotel> _hotels = [];

//   DateTime? _startDate;
//   DateTime? _endDate;

//   double? _totalPrice;

//   @override
//   void initState() {
//     super.initState();
//     _fetchHotels();
//     _guestCountController.addListener(_recalculateTotalPrice);
//     _priceController.addListener(_recalculateTotalPrice);
//   }

//   Future<void> _fetchHotels() async {
//     final snapshot = await FirebaseFirestore.instance.collection('hotels').get();
//     setState(() {
//       _hotels = snapshot.docs.map((doc) {
//         return Hotel(
//           id: doc.id,
//           name: doc['name'],
//           locationId: doc['locationId'],
//           rating: (doc['rating'] as num).toDouble(),
//           description: doc['description'],
//           amenities: List<String>.from(doc['amenities'] ?? []),
//         );
//       }).toList();
//     });
//   }

//   void _recalculateTotalPrice() {
//     final price = double.tryParse(_priceController.text);
//     final guestCount = int.tryParse(_guestCountController.text);
//     if (_startDate != null && _endDate != null && price != null && guestCount != null) {
//       final nights = _endDate!.difference(_startDate!).inDays;
//       if (nights > 0) {
//         setState(() {
//           _totalPrice = nights * price * guestCount;
//         });
//         return;
//       }
//     }
//     setState(() {
//       _totalPrice = null;
//     });
//   }

//   Future<void> _addRoom() async {
//     final type = _typeController.text.trim();
//     final price = double.tryParse(_priceController.text);
//     final guestCount = int.tryParse(_guestCountController.text);

//     if (_selectedHotelId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a hotel')));
//       return;
//     }
//     if (type.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter room type')));
//       return;
//     }
//     if (price == null || price < 0) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid price')));
//       return;
//     }

//     double? totalPrice;
//     if (_startDate != null && _endDate != null && guestCount != null && guestCount > 0) {
//       final nights = _endDate!.difference(_startDate!).inDays;
//       if (nights > 0) {
//         totalPrice = nights * price * guestCount;
//       }
//     }

//     final room = Room(
//       id: '',
//       hotelId: _selectedHotelId!,
//       type: type,
//       price: price,
//       startDate: _startDate,
//       endDate: _endDate,
//       guestCount: guestCount,
//       totalPrice: totalPrice,
//     );

//     DocumentReference docRef = await FirebaseFirestore.instance.collection('rooms').add(room.toMap());

//     // Update the room with the generated ID
//     await docRef.update({'roomId': docRef.id});

//     _typeController.clear();
//     _priceController.clear();
//     _guestCountController.clear();

//     setState(() {
//       _selectedHotelId = null;
//       _startDate = null;
//       _endDate = null;
//       _totalPrice = null;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room added successfully!')));
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
//         }
//       });
//       _recalculateTotalPrice();
//     }
//   }

//   Future<void> _pickEndDate() async {
//     if (_startDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick start date first')));
//       return;
//     }
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
//       firstDate: _startDate!.add(const Duration(days: 1)),
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
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Room')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(labelText: 'Select Hotel'),
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
//             TextField(
//               controller: _typeController,
//               decoration: const InputDecoration(labelText: 'Room Type'),
//             ),
//             TextField(
//               controller: _priceController,
//               decoration: const InputDecoration(labelText: 'Price per Night'),
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             ),
//             TextField(
//               controller: _guestCountController,
//               decoration: const InputDecoration(labelText: 'Guest Count (optional)'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickStartDate,
//                     child: Text(_startDate == null
//                         ? 'Pick Start Date (optional)'
//                         : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickEndDate,
//                     child: Text(_endDate == null
//                         ? 'Pick End Date (optional)'
//                         : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_totalPrice != null)
//               Text(
//                 'Total Price: \$${_totalPrice!.toStringAsFixed(2)}',
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _addRoom,
//               child: const Text('Add Room'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io'; // Needed for File operations (picking image)
// import 'dart:typed_data'; // Needed for Uint8List
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart'; // For image picking
// import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/room.dart';

// class AddRoomPage extends StatefulWidget {
//   const AddRoomPage({super.key}); // Added Key parameter

//   @override
//   _AddRoomPageState createState() => _AddRoomPageState();
// }

// class _AddRoomPageState extends State<AddRoomPage> {
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _guestCountController = TextEditingController();

//   String? _selectedHotelId;
//   List<Hotel> _hotels = [];

//   DateTime? _startDate;
//   DateTime? _endDate;

//   double? _totalPrice;

//   File? _imageFile; // To store the selected image file
//   final ImagePicker _picker = ImagePicker(); // Image picker instance

//   @override
//   void initState() {
//     super.initState();
//     _fetchHotels();
//     _guestCountController.addListener(_recalculateTotalPrice);
//     _priceController.addListener(_recalculateTotalPrice);
//   }

//   @override
//   void dispose() {
//     _typeController.dispose();
//     _priceController.dispose();
//     _guestCountController.dispose();
//     // No need to dispose _imageFile directly as it's just a reference
//     super.dispose();
//   }

//   Future<void> _fetchHotels() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('hotels').get();
//       setState(() {
//         _hotels = snapshot.docs.map((doc) {
//           // Use Hotel.fromFirestore if available, or create manually
//           return Hotel(
//             id: doc.id,
//             name: doc['name'] ?? 'Unknown',
//             locationId: doc['locationId'] ?? 'Unknown',
//             rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
//             description: doc['description'] ?? '',
//             amenities: List<String>.from(doc['amenities'] ?? []),
//           );
//         }).toList();
//       });
//       debugPrint('Fetched ${_hotels.length} hotels.');
//     } catch (e) {
//       debugPrint('Error fetching hotels: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching hotels: $e')),
//       );
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
//         debugPrint('Recalculated total price: $_totalPrice');
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
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//       debugPrint('Image picked from: ${pickedFile.path}');
//     }
//   }

//   Future<void> _addRoom() async {
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
//     if (_startDate != null &&
//         _endDate != null &&
//         guestCount != null &&
//         guestCount > 0) {
//       final nights = _endDate!.difference(_startDate!).inDays;
//       if (nights > 0) {
//         calculatedTotalPrice = nights * price * guestCount;
//       }
//     }

//     final room = Room(
//       id: '', // ID will be generated by Firestore
//       hotelId: _selectedHotelId!,
//       type: type,
//       price: price,
//       // Store dates and guest count as part of initial room data if needed,
//       // but typically these are part of a 'booking' record, not the room itself.
//       // For room availability, you'd check existing bookings.
//       startDate: _startDate, // Keeping these as per your original code
//       endDate: _endDate, // Keeping these as per your original code
//       guestCount: guestCount, // Keeping these as per your original code
//       totalPrice:
//           calculatedTotalPrice, // Keeping this as per your original code
//     );

//     try {
//       DocumentReference docRef = await FirebaseFirestore.instance
//           .collection('rooms')
//           .add(room.toMap());
//       debugPrint('Room added to Firestore with ID: ${docRef.id}');

//       // Store image bytes in Hive using the Firestore generated room ID
//       if (_imageFile != null) {
//         final Uint8List imageBytes = await _imageFile!.readAsBytes();
//         final roomImagesBox =
//             Hive.box<Uint8List>('room_images'); // Use 'room_images' box
//         await roomImagesBox.put(docRef.id, imageBytes);
//         debugPrint('Room image bytes saved to Hive with key: ${docRef.id}');
//       } else {
//         debugPrint('No image selected for room ID: ${docRef.id}');
//       }

//       // No need to update 'roomId' field if you are using doc.id directly everywhere.
//       // If you specifically need a field named 'roomId' within the document, uncomment below:
//       // await docRef.update({'roomId': docRef.id});

//       _typeController.clear();
//       _priceController.clear();
//       _guestCountController.clear();

//       setState(() {
//         _selectedHotelId = null;
//         _startDate = null;
//         _endDate = null;
//         _totalPrice = null;
//         _imageFile = null; // Clear selected image
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Room added successfully!')));
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to add room: $e')));
//       debugPrint('Error adding room: $e');
//     }
//   }

//   Future<void> _pickStartDate() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _startDate ?? now,
//       firstDate: DateTime(now.year -
//           1), // Allow picking past dates for room listing (if needed)
//       lastDate: DateTime(now.year + 5),
//     );
//     if (picked != null) {
//       setState(() {
//         _startDate = picked;
//         if (_endDate != null && _endDate!.isBefore(picked)) {
//           _endDate = null; // Reset end date if it's before new start date
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
//           .add(const Duration(days: 1)), // Ensure end date is after start date
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
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Room', style: TextStyle(color: Colors.white)),
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
//                   labelText: 'Guest Count (optional)',
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
//                         ? 'Pick Start Date (optional)'
//                         : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickEndDate,
//                     child: Text(_endDate == null
//                         ? 'Pick End Date (optional)'
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
//             _imageFile == null
//                 ? const Text('No image selected for room.')
//                 : Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.image),
//               label: const Text('Pick Room Image (Optional)'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _addRoom,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Add Room', style: TextStyle(fontSize: 18)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io'; // Needed for File operations (picking image)
// import 'dart:typed_data'; // Needed for Uint8List
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart'; // For image picking
// import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
// import 'package:hotel_booking_app/model/hotel.dart';
// import 'package:hotel_booking_app/model/room.dart';

// class AddRoomPage extends StatefulWidget {
//   const AddRoomPage({super.key}); // Added Key parameter

//   @override
//   _AddRoomPageState createState() => _AddRoomPageState();
// }

// class _AddRoomPageState extends State<AddRoomPage> {
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _guestCountController = TextEditingController();

//   String? _selectedHotelId;
//   List<Hotel> _hotels = [];

//   // Note: startDate, endDate, totalPrice are typically for booking, not room definition.
//   // If you store them as initial availability for a room, it's fine,
//   // but true availability checks usually involve querying book_history.
//   DateTime? _startDate;
//   DateTime? _endDate;
//   double? _totalPrice;

//   Uint8List? _imageBytes; // Changed from File? to Uint8List? for direct memory image
//   final ImagePicker _picker = ImagePicker(); // Image picker instance

//   @override
//   void initState() {
//     super.initState();
//     _fetchHotels();
//     _guestCountController.addListener(_recalculateTotalPrice);
//     _priceController.addListener(_recalculateTotalPrice);
//     // You might also want to add listeners to _startDate and _endDate for recalculation
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
//         _hotels = snapshot.docs.map((doc) {
//           // Use Hotel.fromFirestore if available, or create manually
//           return Hotel(
//             id: doc.id,
//             name: doc['name'] ?? 'Unknown',
//             locationId: doc['locationId'] ?? 'Unknown',
//             rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
//             description: doc['description'] ?? '',
//             amenities: List<String>.from(doc['amenities'] ?? []),
//           );
//         }).toList();
//       });
//       debugPrint('AddRoomPage: Fetched ${_hotels.length} hotels.');
//     } catch (e) {
//       debugPrint('AddRoomPage: Error fetching hotels: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching hotels: $e')),
//       );
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
//         debugPrint('AddRoomPage: Recalculated total price: $_totalPrice');
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
//       debugPrint('AddRoomPage: Image picked from: ${pickedFile.path}, size: ${bytes.lengthInBytes} bytes');
//     } else {
//       debugPrint('AddRoomPage: Image picking cancelled.');
//     }
//   }

//   Future<void> _addRoom() async {
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

//     // `calculatedTotalPrice` is for a specific booking scenario, not for room definition
//     // It's better to omit it from the `Room` object directly unless it signifies
//     // a default price for a specific duration for the room itself, which is less common.
//     // For now, I'll keep the logic as it was, but note this point.
//     double? calculatedTotalPrice;
//     if (_startDate != null &&
//         _endDate != null &&
//         guestCount != null &&
//         guestCount > 0) {
//       final nights = _endDate!.difference(_startDate!).inDays;
//       if (nights > 0) {
//         calculatedTotalPrice = nights * price * guestCount;
//       }
//     }

//     final room = Room(
//       id: '', // ID will be generated by Firestore
//       hotelId: _selectedHotelId!,
//       type: type,
//       price: price,
//       // These are not typically part of the Room model itself, but booking data
//       // Keeping them here for consistency with your original code structure.
//       startDate: _startDate,
//       endDate: _endDate,
//       guestCount: guestCount,
//       totalPrice: calculatedTotalPrice,
//     );

//     try {
//       DocumentReference docRef = await FirebaseFirestore.instance
//           .collection('rooms')
//           .add(room.toMap());
//       final roomId = docRef.id;
//       debugPrint('AddRoomPage: Room added to Firestore with ID: $roomId');

//       // Store image bytes in Hive using the Firestore generated room ID
//       if (_imageBytes != null) { // Use _imageBytes
//         final roomImagesBox = Hive.box<Uint8List>('room_images'); // Use 'room_images' box
//         await roomImagesBox.put(roomId, _imageBytes!); // Save image bytes
//         debugPrint('AddRoomPage: Room image bytes saved to Hive with key: $roomId');
//       } else {
//         debugPrint('AddRoomPage: No image selected for room ID: $roomId. Skipping Hive storage.');
//       }

//       _typeController.clear();
//       _priceController.clear();
//       _guestCountController.clear();

//       setState(() {
//         _selectedHotelId = null;
//         _startDate = null;
//         _endDate = null;
//         _totalPrice = null;
//         _imageBytes = null; // Clear selected image bytes
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Room added successfully!')));
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to add room: $e')));
//       debugPrint('AddRoomPage: Error adding room: $e');
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
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Room', style: TextStyle(color: Colors.white)),
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
//                   labelText: 'Guest Capacity', // Changed from 'Guest Count (optional)'
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
//                         ? 'Pick Start Date (Optional Booking)' // Clarify this is for optional booking
//                         : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickEndDate,
//                     child: Text(_endDate == null
//                         ? 'Pick End Date (Optional Booking)' // Clarify this is for optional booking
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
//                 : Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover), // Use Image.memory
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.image),
//               label: const Text('Pick Room Image (Optional)'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _addRoom,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Add Room', style: TextStyle(fontSize: 18)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io'; // Needed for File operations (picking image)
import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/room.dart';

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key}); // Added Key parameter

  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController();

  String? _selectedHotelId;
  List<Hotel> _hotels = [];

  // Note: startDate, endDate, totalPrice are typically for booking, not room definition.
  // If you store them as initial availability for a room, it's fine,
  // but true availability checks usually involve querying book_history.
  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalPrice;

  Uint8List?
      _imageBytes; // Changed from File? to Uint8List? for direct memory image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _fetchHotels();
    _guestCountController.addListener(_recalculateTotalPrice);
    _priceController.addListener(_recalculateTotalPrice);
    // You might also want to add listeners to _startDate and _endDate for recalculation
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
        _hotels = snapshot.docs.map((doc) {
          // Use Hotel.fromFirestore if available, or create manually
          return Hotel(
            id: doc.id,
            name: doc['name'] ?? 'Unknown',
            locationId: doc['locationId'] ?? 'Unknown',
            rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
            description: doc['description'] ?? '',
            amenities: List<String>.from(doc['amenities'] ?? []),
          );
        }).toList();
      });
      debugPrint('AddRoomPage: Fetched ${_hotels.length} hotels.');
    } catch (e) {
      debugPrint('AddRoomPage: Error fetching hotels: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching hotels: $e')),
      );
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
        debugPrint('AddRoomPage: Recalculated total price: $_totalPrice');
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
      debugPrint(
          'AddRoomPage: Image picked from: ${pickedFile.path}, size: ${bytes.lengthInBytes} bytes');
    } else {
      debugPrint('AddRoomPage: Image picking cancelled.');
    }
  }

  Future<void> _addRoom() async {
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
    if (_startDate != null &&
        _endDate != null &&
        guestCount != null &&
        guestCount > 0) {
      final nights = _endDate!.difference(_startDate!).inDays;
      if (nights > 0) {
        calculatedTotalPrice = nights * price * guestCount;
      }
    }

    final room = Room(
      id: '', // ID will be generated by Firestore
      hotelId: _selectedHotelId!,
      type: type,
      price: price,
      guestCount: guestCount, // Make sure guestCount is saved
      startDate: _startDate,
      endDate: _endDate,
      totalPrice: calculatedTotalPrice,
    );

    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('rooms')
          .add(room.toMap());
      final roomId = docRef.id;
      debugPrint('AddRoomPage: Room added to Firestore with ID: $roomId');

      if (_imageBytes != null) {
        final roomImagesBox = Hive.box<Uint8List>('room_images');
        await roomImagesBox.put(roomId, _imageBytes!);
        debugPrint(
            'AddRoomPage: Room image bytes saved to Hive with key: $roomId');
      } else {
        debugPrint(
            'AddRoomPage: No image selected for room ID: $roomId. Skipping Hive storage.');
      }

      _typeController.clear();
      _priceController.clear();
      _guestCountController.clear();

      setState(() {
        _selectedHotelId = null;
        _startDate = null;
        _endDate = null;
        _totalPrice = null;
        _imageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room added successfully!')));

      // IMPORTANT: Pop with 'true' to indicate success
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add room: $e')));
      debugPrint('AddRoomPage: Error adding room: $e');
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
      firstDate: _startDate!.add(const Duration(days: 1)),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room', style: TextStyle(color: Colors.white)),
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
                  child: Text(
                    hotel.name,
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
                  labelText: 'Guest Capacity', border: OutlineInputBorder()),
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
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Room Image (Optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Room', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
