import 'dart:io';
import 'package:flutter/material.dart';
import 'package:service_management_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key}); // ✅ No args needed

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Common controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  // Worker-specific controllers
  final TextEditingController serviceCtrl = TextEditingController();
  final TextEditingController experienceCtrl = TextEditingController();
  final TextEditingController chargesCtrl = TextEditingController();

  String role = "customer"; // default role
  bool loading = false;
  File? profileImage;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  Future<void> signup() async {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        locationCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty ||
        passCtrl.text.isEmpty ||
        (role == "worker" &&
            (serviceCtrl.text.isEmpty ||
                experienceCtrl.text.isEmpty ||
                chargesCtrl.text.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final Map<String, dynamic> body = {
        "name": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "location": locationCtrl.text.trim(),
        "address": addressCtrl.text.trim(),
        "password": passCtrl.text.trim(),
        "role": role,
      };

      if (role == "worker") {
        body.addAll({
          "service": serviceCtrl.text.trim(),
          "experience": experienceCtrl.text.trim(),
          "charges": chargesCtrl.text.trim(),
        });

        if (profileImage != null) {
          body["profileImage"] = profileImage!.path; // send file path
        }
      }

      final data = await ApiService.signup(body, profileImage: profileImage);

      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['id'].toString());
        await prefs.setString('role', role);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      } else {
        throw "Invalid response from server";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Logo + App name
                Column(
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "WorkNest",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Role selector chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1C4E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Customer"),
                        selected: role == "customer",
                        selectedColor: Colors.deepPurple,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: role == "customer" ? Colors.white : Colors.black,
                        ),
                        onSelected: (_) => setState(() => role = "customer"),
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text("Worker"),
                        selected: role == "worker",
                        selectedColor: Colors.deepPurple,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: role == "worker" ? Colors.white : Colors.black,
                        ),
                        onSelected: (_) => setState(() => role = "worker"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Purple card form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1C4E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Common fields
                      TextField(
                        controller: nameCtrl,
                        decoration: _inputDecoration("Full name"),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration("Phone number"),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: locationCtrl,
                        decoration: _inputDecoration("Location"),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: addressCtrl,
                        decoration: _inputDecoration("Address"),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: _inputDecoration("Password"),
                      ),
                      const SizedBox(height: 14),

                      // Worker-only fields
                      if (role == "worker") ...[
                        TextField(
                          controller: serviceCtrl,
                          decoration: _inputDecoration("Service Category"),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: experienceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Experience (years)"),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: chargesCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Charges per hour"),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ✅ Already have an account link
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Log in",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
