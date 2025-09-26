import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'home.dart';
import 'home.dart' show AppHeader; // ✅ Import reusable header

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

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile(widget.userId);
    loadBookings(widget.userId);
  }

  // Load user profile
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

  // Load bookings
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

  // Logout: clear saved data and go Home
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

  Widget _buildProfileAvatar() {
    if (profile != null && profile!['name'] != null) {
      return CircleAvatar(
        child: Text(profile!['name'][0]),
      );
    }
    return const CircleAvatar(child: Icon(Icons.person_outline));
  }

  void _onProfileTap() {
    // Already on profile, maybe show logout menu or refresh
    logout();
  }

  void _applySearch(String q) {
    // You may later filter bookings based on search
    debugPrint("Search query: $q");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // /// ✅ Reusable Header
          // AppHeader(
          //   userName: profile?['name'] ?? "User",
          //   onProfileTap: _onProfileTap,
          //   profileAvatar: _buildProfileAvatar(),
          //   searchCtrl: searchCtrl,
          //   onSearchChanged: _applySearch,
          // ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Info
                  const Text("Profile",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      title: Text(profile!['name'] ?? "Unknown User"),
                      subtitle:
                      Text(profile!['email'] ?? "No Email"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bookings
                  const Text("My Bookings",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        margin:
                        const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                              "${b['service']} - ${b['provider']}"),
                          subtitle: Text(
                              "Date: ${b['date']} | Time: ${b['time']}\nAddress: ${b['address'] ?? 'N/A'}"),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Logout Button
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
