import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'home.dart'; // go to Home after logout

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required String userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? userId;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> bookings = [];
  bool loadingProfile = true;
  bool loadingBookings = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  /// Load userId from SharedPreferences then load profile + bookings
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('userId');
    setState(() {
      userId = storedId;
    });

    if (storedId != null) {
      loadProfile(storedId);
      loadBookings(storedId);
    }
  }

  // Load user profile from API
  Future<void> loadProfile(String id) async {
    setState(() => loadingProfile = true);
    try {
      final data = await ApiService.getUserProfile(id);
      setState(() {
        profile = data;
        loadingProfile = false;
      });
    } catch (e) {
      setState(() => loadingProfile = false);
      debugPrint("Error loading profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
        );
      }
    }
  }

  // Load user bookings from API
  Future<void> loadBookings(String id) async {
    setState(() => loadingBookings = true);
    try {
      final data = await ApiService.getUserBookings(id);
      setState(() {
        bookings = data;
        loadingBookings = false;
      });
    } catch (e) {
      setState(() => loadingBookings = false);
      debugPrint("Error loading bookings: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load bookings')),
        );
      }
    }
  }

  // Logout function: clears saved login info and redirects to Home
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Remove all saved login/session info

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile & Bookings"),
        backgroundColor: const Color(0xffc5e3f4),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text("No user logged in"))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile info
              const Text("Profile",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              loadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : profile == null
                  ? const Text("No profile data")
                  : Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(profile!['name']?[0] ?? "U"),
                  ),
                  title:
                  Text(profile!['name'] ?? "Unknown User"),
                  subtitle:
                  Text(profile!['email'] ?? "No Email"),
                ),
              ),
              const SizedBox(height: 16),

              // User Bookings
              const Text("My Bookings",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              loadingBookings
                  ? const Center(child: CircularProgressIndicator())
                  : bookings.isEmpty
                  ? const Text("No bookings yet")
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 6),
                    child: ListTile(
                      title: Text(
                          "${b['service']} - ${b['provider']}"),
                      subtitle: Text(
                          "Date: ${b['date']} | Time: ${b['time']}\nAddress: ${b['address']}"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
