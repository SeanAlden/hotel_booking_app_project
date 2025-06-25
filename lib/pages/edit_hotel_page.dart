import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotel_booking_app/model/location.dart';

class EditHotelPage extends StatefulWidget {
  final String hotelId;

  const EditHotelPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  _EditHotelPageState createState() => _EditHotelPageState();
}

class _EditHotelPageState extends State<EditHotelPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();
  String? _selectedLocationId;
  List<Location> _locations = [];
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _loadExistingHotelData();
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

  Future<void> _loadExistingHotelData() async {
    try {
      DocumentSnapshot hotelDoc = await FirebaseFirestore.instance
          .collection('hotels')
          .doc(widget.hotelId)
          .get();

      if (hotelDoc.exists) {
        final data = hotelDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _ratingController.text = (data['rating'] as num?)?.toString() ?? '';
        _descriptionController.text = data['description'] ?? '';
        _amenitiesController.text =
            List<String>.from(data['amenities'] ?? []).join(', ');
        _selectedLocationId = data['locationId'];

        final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
        final Uint8List? existingImageBytes =
            hotelImagesBox.get(widget.hotelId);
        setState(() {
          _imageBytes = existingImageBytes;
        });
        debugPrint('Existing hotel data loaded for ID: ${widget.hotelId}');
        debugPrint(
            'Image loaded from Hive: ${existingImageBytes != null ? 'Yes' : 'No'}');
      } else {
        debugPrint('Hotel with ID ${widget.hotelId} not found in Firestore.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel data not found!')),
        );
      }
    } catch (e) {
      debugPrint('Error loading existing hotel data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading hotel data: $e')),
      );
    } finally {
      setState(() {
        _isLoadingData = false;
      });
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
          'New image picked from: ${pickedFile.path}, size: ${bytes.lengthInBytes} bytes');
    } else {
      debugPrint('Image picking cancelled.');
    }
  }

  Future<void> _updateHotel() async {
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
      final hotelData = {
        'name': name,
        'locationId': _selectedLocationId!,
        'rating': rating,
        'description': description,
        'amenities': amenities,
      };

      await FirebaseFirestore.instance
          .collection('hotels')
          .doc(widget.hotelId)
          .update(hotelData);
      debugPrint('Hotel ID ${widget.hotelId} updated in Firestore.');

      final hotelImagesBox = Hive.box<Uint8List>('hotel_images');
      if (_imageBytes != null) {
        await hotelImagesBox.put(widget.hotelId, _imageBytes!);
        debugPrint('Image bytes updated in Hive for key: ${widget.hotelId}');
      } else {
        await hotelImagesBox.delete(widget.hotelId);
        debugPrint('Image removed from Hive for key: ${widget.hotelId}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel updated successfully!')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update hotel: $e')),
      );
      debugPrint('Error updating hotel: $e');

      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Edit Hotel', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Hotel', style: TextStyle(color: Colors.white)),
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
                  if (_imageBytes != null) const SizedBox(width: 8),
                  if (_imageBytes != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _imageBytes = null;
                          });
                          debugPrint('Image cleared by user.');
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
                onPressed: _updateHotel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    const Text('Update Hotel', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
