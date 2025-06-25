// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hotel_booking_app/pages/change_password_page.dart';
// import 'package:hotel_booking_app/pages/edit_address_page.dart';
// import 'package:hotel_booking_app/pages/edit_profile_page.dart';
// import 'package:hotel_booking_app/pages/faq_page.dart';
// import 'package:hotel_booking_app/pages/guest_home_page.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   User? user = FirebaseAuth.instance.currentUser;
//   String? profileImageUrl;
//   File? _localImage;

//   @override
//   void initState() {
//     super.initState();
//     _loadUser();
//     _loadLocalProfileImage();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadLocalProfileImage();
//   }

//   // Load image dari local storage
//   Future<void> _loadLocalProfileImage() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/profile_image.png');
//     if (await file.exists()) {
//       setState(() {
//         _localImage = file;
//       });
//     }
//   }

//   // Fungsi untuk memilih dan menyimpan gambar
//   Future<void> _pickAndSaveImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final File image = File(pickedFile.path);
//       final dir = await getApplicationDocumentsDirectory();
//       final localImage = await image.copy('${dir.path}/profile_image.png');

//       setState(() {
//         _localImage = localImage;
//       });

//       // Tambahan agar file benar-benar di-reload dari storage
//       await _loadLocalProfileImage();
//     }
//   }

//   void _loadUser() async {
//     await FirebaseAuth.instance.currentUser?.reload();
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser != null) {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();

//       if (!mounted) return;
//       setState(() {
//         user = currentUser;
//         profileImageUrl = doc.data()?['photoUrl'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayName = user?.displayName ?? 'No Name';
//     final email = user?.email ?? 'No Email';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(
//               fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Profile Header
//             Center(
//               child: Column(
//                 children: [
//                   InkWell(
//                     onTap: _pickAndSaveImage,
//                     child: ClipOval(
//                       child: _localImage != null
//                           ? Image.file(
//                               _localImage!,
//                               width: 100,
//                               height: 100,
//                               fit: BoxFit.cover,
//                             )
//                           : Container(
//                               width: 100,
//                               height: 100,
//                               color: Colors.grey.shade300,
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 size: 40,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                         fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     email,
//                     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Settings Section
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Settings',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               elevation: 2,
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.edit),
//                     title: const Text('Edit Profile'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const EditProfilePage()),
//                       ).then((_) {
//                         _loadUser();
//                       });
//                     },
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.lock),
//                     title: const Text('Change Password'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const ChangePasswordPage()),
//                       );
//                     },
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.home),
//                     title: const Text('Address'),
//                     onTap: () {
//                       // Address action
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const EditAddressPage()),
//                       );
//                     },
//                   ),
//                   const Divider(height: 1),
//                   // --- START: New FAQ ListTile ---
//                   ListTile(
//                     leading: const Icon(Icons.help_outline),
//                     title: const Text('FAQ'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const FaqPage()),
//                       );
//                     },
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.logout, color: Colors.red),
//                     title: const Text('Log Out',
//                         style: TextStyle(color: Colors.red)),
//                     onTap: () async {
//                       await FirebaseAuth.instance.signOut();
//                       // Navigator.of(context).popUntil((route) => route.isFirst);
//                       Navigator.push(
//                           context, MaterialPageRoute(builder: (_) => GuestHomePage()));
//                       // Redirect to login screen if needed
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    WidgetsBinding.instance.addObserver(this); // Add observer
    _loadUser();
    _loadLocalProfileImage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  // This method is called when the app lifecycle changes (e.g., returning from another page)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUser(); // Reload user data and image when the app is resumed
      _loadLocalProfileImage();
    }
  }

  // Load image from local storage
  Future<void> _loadLocalProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_image.png');
    if (await file.exists()) {
      setState(() {
        _localImage = file;
      });
    } else {
      // If the local file doesn't exist, clear the local image
      setState(() {
        _localImage = null;
      });
    }
    // await _loadLocalProfileImage(); // Setelah menyimpan gambar
  }

  // Function to pick and save image
  // Future<void> _pickAndSaveImage() async {
  //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     final File image = File(pickedFile.path);
  //     final dir = await getApplicationDocumentsDirectory();
  //     final localImage = await image.copy('${dir.path}/profile_image.png');

  //     setState(() {
  //       _localImage = localImage; // Directly update the state with the new image
  //     });

  //     // You can also consider updating Firebase Firestore with the new image URL here if needed.
  //     // For now, we are focusing on local image display.
  //   }
  // }

  // Future<void> _pickAndSaveImage() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     final File image = File(pickedFile.path);
  //     final dir = await getApplicationDocumentsDirectory();

  //     // Gunakan nama file yang dinamis agar cache tidak digunakan
  //     final String newPath =
  //         '${dir.path}/profile_image_${DateTime.now().millisecondsSinceEpoch}.png';
  //     final savedImage = await image.copy(newPath);

  //     // Hapus file lama jika ada
  //     final oldFile = File('${dir.path}/profile_image.png');
  //     if (await oldFile.exists()) {
  //       await oldFile.delete();
  //     }

  //     // Simpan ulang dengan nama standar agar tetap bisa diload ulang
  //     await savedImage.copy('${dir.path}/profile_image.png');

  //     setState(() {
  //       _localImage = File('${dir.path}/profile_image.png');
  //     });
  //   }
  // }

  Future<void> _pickAndSaveImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      final dir = await getApplicationDocumentsDirectory();

      // Buat nama sementara agar cache tidak digunakan
      final tempImagePath =
          '${dir.path}/temp_profile_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempSaved = await image.copy(tempImagePath);

      // Hapus file lama
      final oldFile = File('${dir.path}/profile_image.png');
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      // Salin sebagai file utama
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
            // Profile Header
            Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickAndSaveImage,
                    child: ClipOval(
                      child: _localImage != null
                          ?
                          // Image.file(
                          //     _localImage!,
                          //     width: 100,
                          //     height: 100,
                          //     fit: BoxFit.cover,
                          //   )
                          Image.file(
                              _localImage!,
                              key: ValueKey(_localImage!
                                  .path), // penting agar widget tahu file sudah berubah
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
                        _loadUser(); // Reload user data after returning from EditProfilePage
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

// class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
//   User? user = FirebaseAuth.instance.currentUser;
//   String? profileImageUrl;
//   File? _localImage;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _loadUser();
//     _loadLocalProfileImage();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _loadUser();
//       _loadLocalProfileImage();
//     }
//   }

//   Future<void> _loadLocalProfileImage() async {
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final file = File('${dir.path}/profile_image.png');
//       if (await file.exists()) {
//         // Tambahkan key unik untuk memaksa reload jika file sama tapi kontennya beda
//         final reloadedFile = await file.copy('${file.path}_temp');
//         await reloadedFile.copy(file.path);
//         await reloadedFile.delete();

//         if (mounted) {
//           setState(() {
//             _localImage = file;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _localImage = null;
//           });
//         }
//       }
//     } catch (e) {
//       // Handle potential errors, e.g., permissions
//       print("Error loading local profile image: $e");
//     }
//   }

//   // --- FUNGSI YANG DIPERBAIKI ---
//   // Fungsi ini akan mengambil gambar, menyimpannya secara lokal, dan me-refresh UI.
//   Future<void> _pickAndSaveImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);

//     // Kode di bawah ini hanya berjalan SETELAH ImagePicker ditutup.
//     if (pickedFile != null) {
//       final File image = File(pickedFile.path);
//       final dir = await getApplicationDocumentsDirectory();
//       final imagePath = '${dir.path}/profile_image.png';

//       // Salin file yang baru dipilih ke path yang ditentukan
//       final File newImage = await image.copy(imagePath);

//       // Panggil setState untuk memberitahu Flutter agar me-refresh UI dengan gambar baru.
//       // Penggunaan `ValueKey` di widget Image.file juga penting untuk memastikan
//       // widget mengenali bahwa file telah berubah.
//       setState(() {
//         _localImage = newImage;
//       });
//     }
//   }

//   void _loadUser() async {
//     await FirebaseAuth.instance.currentUser?.reload();
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser != null) {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();

//       if (!mounted) return;
//       setState(() {
//         user = currentUser;
//         profileImageUrl = doc.data()?['photoUrl'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayName = user?.displayName ?? 'No Name';
//     final email = user?.email ?? 'No Email';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(
//               fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   InkWell(
//                     onTap:
//                         _pickAndSaveImage, // Panggil fungsi yang sudah diperbaiki
//                     child: ClipOval(
//                       child: _localImage != null
//                           ? Image.file(
//                               _localImage!,
//                               // Kunci ini sangat penting untuk memberi tahu Flutter bahwa
//                               // widget ini perlu dibangun ulang ketika path (atau objek) berubah.
//                               key: ValueKey(_localImage!.path +
//                                   DateTime.now()
//                                       .millisecondsSinceEpoch
//                                       .toString()),
//                               width: 100,
//                               height: 100,
//                               fit: BoxFit.cover,
//                             )
//                           : Container(
//                               width: 100,
//                               height: 100,
//                               color: Colors.grey.shade300,
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 size: 40,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                         fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     email,
//                     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             // Settings Section
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Settings',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               elevation: 2,
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.edit),
//                     title: const Text('Edit Profile'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const EditProfilePage()),
//                       ).then((_) {
//                         _loadUser(); // Reload user data after returning from EditProfilePage
//                       });
//                     },
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.lock),
//                     title: const Text('Change Password'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const ChangePasswordPage()),
//                       );
//                     },
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.home),
//                     title: const Text('Address'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const EditAddressPage()),
//                       );
//                     },
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.help_outline),
//                     title: const Text('FAQ'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const FaqPage()),
//                       );
//                     },
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.logout, color: Colors.red),
//                     title: const Text('Log Out',
//                         style: TextStyle(color: Colors.red)),
//                     onTap: () async {
//                       await FirebaseAuth.instance.signOut();
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => GuestHomePage()));
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
