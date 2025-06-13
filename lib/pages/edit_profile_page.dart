// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   late TextEditingController nameController;

//   @override
//   void initState() {
//     super.initState();
//     final user = _auth.currentUser;
//     nameController = TextEditingController(text: user?.displayName ?? '');
//   }

//   Future<void> updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       final user = _auth.currentUser;

//       try {
//         // Update displayName jika berbeda
//         if (nameController.text.trim() != user?.displayName) {
//           await user?.updateDisplayName(nameController.text.trim());
//         }

//         await user?.reload();
//         setState(() {}); // Refresh tampilan jika perlu

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );

//         Navigator.pop(context); // Kembali ke halaman sebelumnya
//       } on FirebaseAuthException catch (e) {
//         String error = e.message ?? 'An error occurred';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update: $error')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Full Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Name is required' : null,
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: updateProfile,
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 32)),
//                 child: const Text(
//                   'Save Changes',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;

    nameController = TextEditingController(text: user?.displayName ?? '');
    phoneController = TextEditingController();

    if (user != null) {
      _firestore.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists) {
          final userData = AppUser.fromMap(doc.data()!);
          setState(() {
            phoneController.text = userData.phone;
            selectedGender = userData.gender;
          });
        }
      });
    }
  }

  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user == null) return;

      try {
        // Update display name in FirebaseAuth
        if (nameController.text.trim() != user.displayName) {
          await user.updateDisplayName(nameController.text.trim());
        }

        // Update data in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'gender': selectedGender,
        });

        await user.reload();
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
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
        title: const Text('Edit Profile'),
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
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a gender' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 32,
                  ),
                ),
                child: const Text(
                  'Save Changes',
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
