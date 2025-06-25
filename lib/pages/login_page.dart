// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hotel_booking_app/pages/forgot_password_page.dart';
// import 'package:hotel_booking_app/pages/register_page.dart';
// import 'package:hotel_booking_app/services/check_auth.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void login() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         await _auth.signInWithEmailAndPassword(
//           email: emailController.text.trim(),
//           password: passwordController.text.trim(),
//         );

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Login berhasil!"), backgroundColor: Colors.green,),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const CheckAuth()),
//         );
//       } on FirebaseAuthException catch (e) {
//         String errorMessage;

//         if (e.code == 'user-not-found' || e.code == 'wrong-password') {
//           errorMessage = "Email atau Password Anda salah";
//         } else {
//           errorMessage = "Login gagal: ${e.message}";
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
//         );
//       }
//     }
//   }

//   String? emailValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email wajib diisi';
//     }
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value)) {
//       return 'Format email tidak valid';
//     }
//     return null;
//   }

//   String? passwordValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password wajib diisi';
//     }
//     if (value.length < 6) {
//       return 'Minimal 6 karakter';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Login",
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme: IconThemeData(
//           color: Colors.white, // Ubah warna ikon back ke putih
//         ),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Hotel Book App",
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "If you have an account, let’s sign in. Else, go to sign up for create your new account",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email',
//                           hintText: 'Enter Email Address',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: emailValidator,
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: passwordController,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           hintText: 'Enter Password',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: passwordValidator,
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: login,
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue),
//                         child: const Text("Login",
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                       const SizedBox(height: 10),
//                       TextButton(
//                         onPressed: () {
//                           // Implement password reset functionality here if needed
//                         },
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         ForgotPasswordPage()));
//                           },
//                           child: const Text(
//                             "Forgot Password?",
//                             style: TextStyle(color: Colors.blue),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("DON’T HAVE AN ACCOUNT?"),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           const RegisterPage()));
//                             },
//                             child: const Text("Sign-up",
//                                 style: TextStyle(color: Colors.blue)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// import 'package:hotel_booking_app/pages/forgot_password_page.dart';
// import 'package:hotel_booking_app/pages/register_page.dart';
// import 'package:hotel_booking_app/services/check_auth.dart';
// import 'package:hotel_booking_app/pages/admin_home_page.dart'; // Import AdminHomePage
// import 'package:hotel_booking_app/pages/home_page.dart'; // Assuming you have a HomePage for regular users

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance; // Initialize Firestore

//   void login() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: emailController.text.trim(),
//           password: passwordController.text.trim(),
//         );

//         // Fetch user data from Firestore to get the userType
//         if (userCredential.user != null) {
//           DocumentSnapshot userDoc = await _firestore
//               .collection('users')
//               .doc(userCredential.user!.uid)
//               .get();

//           if (userDoc.exists) {
//             String userType = userDoc['userType'] ??
//                 'user'; // Get userType, default to 'user'

//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("Login successful!"),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             if (userType == 'admin') {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) =>
//                         const AdminHomePage()), // Navigate to AdminHomePage
//               );
//             } else {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) =>
//                         const HomePage()), // Navigate to HomePage for regular users
//               );
//             }
//           } else {
//             // User document not found in Firestore, handle as a regular user or show an error
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content:
//                     Text("User data not found, logging in as a regular user."),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => const HomePage()), // Default to HomePage
//             );
//           }
//         }
//       } on FirebaseAuthException catch (e) {
//         String errorMessage;

//         if (e.code == 'user-not-found' || e.code == 'wrong-password') {
//           errorMessage = "Email atau Password Anda salah";
//         } else {
//           errorMessage = "Login failed: ${e.message}";
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
//         );
//       }
//     }
//   }

//   String? emailValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email wajib diisi';
//     }
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value)) {
//       return 'Format email tidak valid';
//     }
//     return null;
//   }

//   String? passwordValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password wajib diisi';
//     }
//     if (value.length < 6) {
//       return 'Minimal 6 karakter';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Login",
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(
//           color: Colors.white, // Ubah warna ikon back ke putih
//         ),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Hotel Book App",
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "If you have an account, let’s sign in. Else, go to sign up for create your new account",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: emailController,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                           hintText: 'Enter Email Address',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: emailValidator,
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: passwordController,
//                         obscureText: true,
//                         decoration: const InputDecoration(
//                           labelText: 'Password',
//                           hintText: 'Enter Password',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: passwordValidator,
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: login,
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue),
//                         child: const Text("Login",
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                       const SizedBox(height: 10),
//                       TextButton(
//                         onPressed: () {
//                           // Implement password reset functionality here if needed
//                         },
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         ForgotPasswordPage()));
//                           },
//                           child: const Text(
//                             "Forgot Password?",
//                             style: TextStyle(color: Colors.blue),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("DON’T HAVE AN ACCOUNT?"),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           const RegisterPage()));
//                             },
//                             child: const Text("Sign-up",
//                                 style: TextStyle(color: Colors.blue)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Removed direct Firestore import for userType here, CheckAuth will handle it.
// Removed direct imports for AdminHomePage and HomePage as CheckAuth now handles routing.
import 'package:hotel_booking_app/pages/forgot_password_page.dart';
import 'package:hotel_booking_app/pages/register_page.dart';
import 'package:hotel_booking_app/services/check_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // On successful login, always navigate to CheckAuth.
        // CheckAuth will then determine the user's role and navigate appropriately.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CheckAuth()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = "Email atau Password Anda salah";
        } else {
          errorMessage = "Login failed: ${e.message}";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
        );
      }
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Minimal 6 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Ubah warna ikon back ke putih
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hotel Book App",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "If you have an account, let’s sign in. Else, go to sign up for create your new account",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: emailValidator,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: passwordValidator,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text("Login",
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // Implement password reset functionality here if needed
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordPage()));
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: const Text("DON’T HAVE AN ACCOUNT?")),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()));
                            },
                            child: const Text("Sign-up",
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}