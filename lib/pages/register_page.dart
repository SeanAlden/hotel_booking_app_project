import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/model/user.dart';
import 'package:hotel_booking_app/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedGender;

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void register() async {
    if (_formKey.currentState!.validate()) {
      if (selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a gender")),
        );
        return;
      }

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await userCredential.user
            ?.updateDisplayName(nameController.text.trim());
        await userCredential.user?.reload();

        AppUser newUser = AppUser(
          uid: userCredential.user!.uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
          gender: selectedGender!,
          createdAt: DateTime.now(),
          userType: 'user',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}")),
        );
      }
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Minimum 6 characters';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hotel Book App",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Looks like you don’t have an account. Let’s create a new account for you.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Phone number is required' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedGender,
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select your gender' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
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
                        border: OutlineInputBorder(),
                      ),
                      validator: passwordValidator,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: confirmPasswordValidator,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text('Create Account',
                          style: TextStyle(color: Colors.white)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: const Text("ALREADY HAVE ACCOUNT?")),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          },
                          child: const Text("Sign-in",
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
