import 'package:flutter/material.dart';
import 'api_service.dart';
import 'worker_edit_profile_page.dart';

class WorkerProfilePage extends StatefulWidget {
  const WorkerProfilePage({super.key});

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  Map<String, dynamic>? workerData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkerProfile();
  }

  Future<void> fetchWorkerProfile() async {
    try {
      final data = await ApiService.getWorkerProfile('');
      setState(() {
        workerData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching worker profile: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WorkNest")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : workerData == null
            ? const Center(child: Text("Failed to load profile"))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.person, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${workerData!['name'] ?? 'Worker'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            workerData!['email'] ?? "",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkerEditProfilePage(
                              profileData: workerData!,
                            ),
                          ),
                        );
                        fetchWorkerProfile(); // Refresh profile after edit
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem(
                      icon: Icons.history,
                      text: "Payment history",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on,
                      text: "Address",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.list_alt,
                      text: "Booking history",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.star,
                      text: "My rating",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.lock,
                      text: "Password",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      text: "Log out",
                      onTap: () {
                        // TODO: implement logout logic
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
