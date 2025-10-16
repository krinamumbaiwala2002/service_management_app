import 'package:flutter/material.dart';
import 'api_service.dart';

class WorkerEditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const WorkerEditProfilePage({super.key, required this.profileData});

  @override
  State<WorkerEditProfilePage> createState() => _WorkerEditProfilePageState();
}

class _WorkerEditProfilePageState extends State<WorkerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController passwordController;
  late TextEditingController aadhaarController;
  late TextEditingController skillsController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profileData['name'] ?? '');
    passwordController = TextEditingController(text: widget.profileData['password'] ?? '');
    aadhaarController = TextEditingController(text: widget.profileData['aadhaar'] ?? '');
    skillsController = TextEditingController(text: widget.profileData['skills'] ?? '');
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    final updatedData = {
      'name': nameController.text.trim(),
      'password': passwordController.text.trim(),
      'aadhaar': aadhaarController.text.trim(),
      'skills': skillsController.text.trim(),
    };

    final success = await ApiService.updateWorkerProfile(updatedData);
    setState(() => isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Worker Profile")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildInput("Full name", nameController),
                _buildInput("Password", passwordController, isPassword: true),
                _buildInput("Aadhaar card no.", aadhaarController),
                _buildInput("Skills", skillsController),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: isSaving ? null : saveChanges,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.edit),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? "Required field" : null,
      ),
    );
  }
}
