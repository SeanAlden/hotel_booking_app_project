import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _addLocation() async {
    final name = _nameController.text.trim(); 
    if (name.isNotEmpty) {
      final location = Location(id: '', name: name);
      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('locations')
            .add(location.toMap());
        debugPrint('AddLocationPage: Location added to Firestore with ID: ${docRef.id}');
        _nameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location added successfully!')));
      } catch (e) {
        debugPrint('AddLocationPage: Error adding location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add location: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location name cannot be empty!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location', style: TextStyle(color: Colors.white)), 
        backgroundColor: Colors.blue, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Location Name', border: OutlineInputBorder()), 
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Location', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
