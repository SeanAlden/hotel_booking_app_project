import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/pages/change_password_page.dart';
import 'package:hotel_booking_app/pages/edit_address_page.dart';
import 'package:hotel_booking_app/pages/edit_profile_page.dart';
import 'package:hotel_booking_app/pages/faq_page.dart';
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

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;
  String? profileImageUrl;
  File? _localImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUser();
    _loadLocalProfileImage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUser();
      _loadLocalProfileImage();
    }
  }

  Future<void> _loadLocalProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_image.png');
    if (await file.exists()) {
      setState(() {
        _localImage = file;
      });
    } else {
      setState(() {
        _localImage = null;
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      final dir = await getApplicationDocumentsDirectory();

      final tempImagePath =
          '${dir.path}/temp_profile_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempSaved = await image.copy(tempImagePath);

      final oldFile = File('${dir.path}/profile_image.png');
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      final newImage = await tempSaved.copy('${dir.path}/profile_image.png');

      setState(() {
        _localImage = newImage;
      });

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
            Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickAndSaveImage,
                    child: ClipOval(
                      child: _localImage != null
                          ? Image.file(
                              _localImage!,
                              key: ValueKey(_localImage!.path),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditAddressPage()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('FAQ'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FaqPage()),
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => GuestHomePage()));
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
