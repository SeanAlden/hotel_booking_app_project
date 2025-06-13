import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/pages/change_password_page.dart';
import 'package:hotel_booking_app/pages/edit_address_page.dart';
import 'package:hotel_booking_app/pages/edit_profile_page.dart';
import 'package:hotel_booking_app/pages/guest_home_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? profileImageUrl;
  File? _localImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadLocalProfileImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLocalProfileImage();
  }

  // Load image dari local storage
  Future<void> _loadLocalProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_image.png');
    if (await file.exists()) {
      setState(() {
        _localImage = file;
      });
    }
  }

  // Fungsi untuk memilih dan menyimpan gambar
  Future<void> _pickAndSaveImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      final dir = await getApplicationDocumentsDirectory();
      final localImage = await image.copy('${dir.path}/profile_image.png');

      setState(() {
        _localImage = localImage;
      });

      // Tambahan agar file benar-benar di-reload dari storage
      await _loadLocalProfileImage();
    }
  }

  void _loadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;
      setState(() {
        user = currentUser;
        profileImageUrl = doc.data()?['photoUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'No Name';
    final email = user?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickAndSaveImage,
                    child: ClipOval(
                      child: _localImage != null
                          ? Image.file(
                              _localImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Settings Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfilePage()),
                      ).then((_) {
                        _loadUser();
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Address'),
                    onTap: () {
                      // Address action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditAddressPage()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Out',
                        style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => GuestHomePage()));
                      // Redirect to login screen if needed
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
