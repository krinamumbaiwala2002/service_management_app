import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'home.dart';
import 'api_service.dart';
import 'address_page.dart';
import 'booking_page.dart';
import 'payment_history_page.dart';
import 'change_password_page.dart';
import 'my_rating_page.dart';
import 'chat_screen.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String role;
  const UserProfilePage({super.key, required this.userId, required this.role});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);
    try {
      profile = widget.role == "worker"
          ? await ApiService.getWorkerProfile(widget.userId)
          : await ApiService.getUserProfile(widget.userId);
    } catch (e) {
      debugPrint("Error: $e");
    }
    setState(() => loading = false);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
            (route) => false,
      );
    }
  }

  Widget _option(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final name = profile?['name'] ?? '';
    final email = profile?['email'] ?? '';
    final isWorker = widget.role == "worker";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Image.asset("assets/images/logo.png", height: 60, width: 60),
            const Text("WorkNest",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
            const SizedBox(height: 20),

            // =========================
            // Worker Layout
            // =========================
            if (isWorker) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("Hello, $name",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(email,
                              style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        ]),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (profile == null) return;
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(profile: profile!),
                              ),
                            );
                            if (updated != null) setState(() => profile = updated);
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _option(Icons.credit_card, "Payment history",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PaymentHistoryPage(userId: '',)))),
                    _option(Icons.location_on, "Address",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddressPage(userId: widget.userId)))),
                    _option(Icons.history, "Booking history",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BookingPage(userId: widget.userId)))),
                    _option(Icons.star, "My rating",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyRatingPage(workerId: '',)))),
                    _option(Icons.lock, "Password",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangePasswordPage(userId: '',)))),
                    _option(Icons.logout, "Logout", onTap: logout),
                  ],
                ),
              ),
            ],

            // =========================
            // Normal User Layout
            // =========================
            if (!isWorker) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("Hello, $name",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(email,
                              style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        ]),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (profile == null) return;
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(profile: profile!),
                              ),
                            );
                            if (updated != null) setState(() => profile = updated);
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _option(Icons.credit_card, "Payment history",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PaymentHistoryPage(userId: '',)))),
                    _option(Icons.location_on, "Address",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddressPage(userId: widget.userId)))),
                    _option(Icons.history, "Booking history",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BookingPage(userId: widget.userId)))),
                    _option(Icons.star, "My rating",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyRatingPage(workerId: '',)))),
                    _option(Icons.lock, "Password",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangePasswordPage(userId: '',)))),
                    _option(Icons.chat, "Help & Support",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatScreen()))),
                    _option(Icons.logout, "Logout", onTap: logout),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
