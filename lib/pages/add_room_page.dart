import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/room.dart';

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key});

  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController();

  String? _selectedHotelId;
  List<Hotel> _hotels = [];

  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalPrice;

  Uint8List?
      _imageBytes; 
  final ImagePicker _picker = ImagePicker(); 

  @override
  void initState() {
    super.initState();
    _fetchHotels();
    _guestCountController.addListener(_recalculateTotalPrice);
    _priceController.addListener(_recalculateTotalPrice);
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
        _imageBytes = bytes; 
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
        // guestCount != null &&
        guestCount > 0) {
      final nights = _endDate!.difference(_startDate!).inDays;
      if (nights > 0) {
        calculatedTotalPrice = nights * price * guestCount;
      }
    }

    final room = Room(
      id: '', 
      hotelId: _selectedHotelId!,
      type: type,
      price: price,
      guestCount: guestCount, 
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

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add room: $e')));
      debugPrint('AddRoomPage: Error adding room: $e');
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
