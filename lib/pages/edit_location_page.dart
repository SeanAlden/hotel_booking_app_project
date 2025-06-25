import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';

class EditLocationPage extends StatefulWidget {
  final String locationId; // Pass the locationId to be edited

  const EditLocationPage({Key? key, required this.locationId}) : super(key: key);

  @override
  _EditLocationPageState createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoadingData = true; // To show loading while fetching existing data

  @override
  void initState() {
    super.initState();
    _loadExistingLocationData(); // Load data of the location to be edited
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingLocationData() async {
    try {
      DocumentSnapshot locationDoc = await FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.locationId)
          .get();

      if (locationDoc.exists) {
        final data = locationDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        debugPrint('EditLocationPage: Existing location data loaded for ID: ${widget.locationId}');
      } else {
        debugPrint('EditLocationPage: Location with ID ${widget.locationId} not found in Firestore.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location data not found!')),
        );
      }
    } catch (e) {
      debugPrint('EditLocationPage: Error loading existing location data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading location data: $e')),
      );
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _updateLocation() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter location name.')),
      );
      return;
    }

    try {
      final locationData = {
        'name': name,
      };

      await FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.locationId)
          .update(locationData);
      debugPrint('EditLocationPage: Location ID ${widget.locationId} updated in Firestore.');

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully!')));

      Navigator.pop(context, true); // Pop back and indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update location: $e')),
      );
      debugPrint('EditLocationPage: Error updating location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Location', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Location', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Location Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Update Location', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
