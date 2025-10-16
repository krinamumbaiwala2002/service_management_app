import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPage extends StatefulWidget {
  final String userId;

  const ChangePasswordPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  Future<void> _updatePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New and confirm passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('https://yourapi.com/api/change-password');
    final response = await http.post(
      url,
      body: {
        'userId': widget.userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Password updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F7),
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildPasswordField('Current Password', currentPasswordController, showCurrent, () {
              setState(() => showCurrent = !showCurrent);
            }),
            const SizedBox(height: 15),
            _buildPasswordField('New Password', newPasswordController, showNew, () {
              setState(() => showNew = !showNew);
            }),
            const SizedBox(height: 15),
            _buildPasswordField('Confirm Password', confirmPasswordController, showConfirm, () {
              setState(() => showConfirm = !showConfirm);
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _updatePassword,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool visible, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
