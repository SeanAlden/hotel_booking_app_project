import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/user.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();

    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists) {
          try {
            final userData = AppUser.fromMap(doc.data()!);
            setState(() {
              addressController.text = userData.address;
            });
          } catch (e) {
            debugPrint("Error loading user data: $e");
          }
        }
      });
    }
  }

  Future<void> updateAddress() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user == null) return;

      try {
        await _firestore.collection('users').doc(user.uid).update({
          'address': addressController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: updateAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 32,
                  ),
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
