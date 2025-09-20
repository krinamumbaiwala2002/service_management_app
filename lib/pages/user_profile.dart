import 'package:flutter/material.dart';
import 'api_service.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> bookings = [];
  bool loadingProfile = true;
  bool loadingBookings = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadBookings();
  }

  Future<void> loadProfile() async {
    setState(() => loadingProfile = true);
    try {
      final data = await ApiService.getUserProfile(widget.userId);
      setState(() {
        profile = data;
        loadingProfile = false;
      });
    } catch (e) {
      setState(() => loadingProfile = false);
      debugPrint("Error loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  Future<void> loadBookings() async {
    setState(() => loadingBookings = true);
    try {
      final data = await ApiService.getUserBookings(widget.userId);
      setState(() {
        bookings = data;
        loadingBookings = false;
      });
    } catch (e) {
      setState(() => loadingBookings = false);
      debugPrint("Error loading bookings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load bookings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile & Bookings"),
        backgroundColor: const Color(0xffc5e3f4),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile info
              const Text("Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  title: Text(profile!['name'] ?? "Unknown"),
                  subtitle: Text(profile!['email'] ?? "No Email"),
                ),
              ),
              const SizedBox(height: 16),

              // User Bookings
              const Text("My Bookings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title:
                      Text("${b['service']} - ${b['provider']}"),
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
