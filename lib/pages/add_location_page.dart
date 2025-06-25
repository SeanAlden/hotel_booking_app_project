// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/location.dart';

// class AddLocationPage extends StatefulWidget {
//   @override
//   _AddLocationPageState createState() => _AddLocationPageState();
// }

// class _AddLocationPageState extends State<AddLocationPage> {
//   final TextEditingController _nameController = TextEditingController();

//   Future<void> _addLocation() async {
//     final name = _nameController.text;
//     if (name.isNotEmpty) {
//       final location = Location(id: '', name: name);
//       await FirebaseFirestore.instance
//           .collection('locations')
//           .add(location.toMap());
//       _nameController.clear();
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Location added successfully!')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Location')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Location Name'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _addLocation,
//               child: Text('Add Location'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key}); // Added const and super.key

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _addLocation() async {
    final name = _nameController.text.trim(); // Trim whitespace
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
        title: const Text('Add Location', style: TextStyle(color: Colors.white)), // Added style
        backgroundColor: Colors.blue, // Added color
        iconTheme: const IconThemeData(color: Colors.white), // Added icon color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Location Name', border: OutlineInputBorder()), // Added border
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50), // Full width button
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
