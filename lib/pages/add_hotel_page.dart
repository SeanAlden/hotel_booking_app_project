import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotel_booking_app/model/hotel.dart';
import 'package:hotel_booking_app/model/location.dart';

class AddHotelPage extends StatefulWidget {
  const AddHotelPage({super.key});

  @override
  _AddHotelPageState createState() => _AddHotelPageState();
}

class _AddHotelPageState extends State<AddHotelPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();
  String? _selectedLocationId;
  List<Location> _locations = [];
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ratingController.dispose();
    _descriptionController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('locations').get();
      setState(() {
        _locations = snapshot.docs
            .map((doc) => Location(id: doc.id, name: doc['name']))
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching locations: $e')),
      );
    }
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
          'Image picked from: ${pickedFile.path}, size: ${bytes.lengthInBytes} bytes');
    } else {
      debugPrint('Image picking cancelled.');
    }
  }

  Future<void> _addHotel() async {
    final name = _nameController.text.trim();
    final rating = double.tryParse(_ratingController.text) ?? 0.0;
    final description = _descriptionController.text.trim();
    final amenitiesRaw = _amenitiesController.text.trim();
    final List<String> amenities = amenitiesRaw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (name.isEmpty || _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in hotel name and select a location.')),
      );
      return;
    }

    try {
      final hotel = Hotel(
        id: '',
        name: name,
        locationId: _selectedLocationId!,
        rating: rating,
        description: description,
        amenities: amenities,
      );

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('hotels')
          .add(hotel.toMap());
      final hotelFirestoreId = docRef.id;
      debugPrint('Hotel added to Firestore with ID: $hotelFirestoreId');

      if (_imageBytes != null) {
        final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
        await hotelImagesBox.put(hotelFirestoreId, _imageBytes!);
        debugPrint('Image bytes saved to Hive with key: $hotelFirestoreId');
      } else {
        debugPrint(
            'No image selected for hotel ID: $hotelFirestoreId. Skipping Hive storage.');
      }

      _nameController.clear();
      _ratingController.clear();
      _descriptionController.clear();
      _amenitiesController.clear();
      setState(() {
        _selectedLocationId = null;
        _imageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel added successfully!')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add hotel: $e')),
      );
      debugPrint('Error adding hotel: $e');

      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hotel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Location',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Location'),
                value: _selectedLocationId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocationId = newValue;
                  });
                },
                items: _locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location.id,
                    child: Text(location.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Hotel Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ratingController,
                decoration: const InputDecoration(
                    labelText: 'Rating (e.g., 4.5)',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amenitiesController,
                decoration: const InputDecoration(
                    labelText: 'Amenities (comma-separated, e.g., Wi-Fi, Pool)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              _imageBytes == null
                  ? const Text('No image selected.')
                  : Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Hotel Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addHotel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Hotel', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
