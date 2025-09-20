import 'package:flutter/material.dart';
import 'api_service.dart';
import 'service_providers_page.dart';
import 'chat_screen.dart';
import 'user_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filtered = [];
  bool isLoading = true;
  final TextEditingController searchCtrl = TextEditingController();
  String userName = "User";

  @override
  void initState() {
    super.initState();
    loadUser();
    loadServices();
    searchCtrl.addListener(() => applySearch(searchCtrl.text));
  }

  Future<void> loadUser() async {
    setState(() => userName = "Kinjal"); // Mocked user name
  }

  Future<void> loadServices() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getServices();
      setState(() {
        services = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error loading services: $e");
    }
  }

  void applySearch(String q) {
    final qLower = q.trim().toLowerCase();
    if (qLower.isEmpty) {
      setState(() => filtered = services);
    } else {
      setState(() => filtered = services
          .where((s) => (s['title'] as String).toLowerCase().contains(qLower))
          .toList());
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff69cae8),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        child: const Icon(Icons.chat),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding:
            const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe1e8eb), Color(0xffc5e3f4)],
                begin: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Hello, $userName",
                        style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const UserProfilePage(userId: "123"),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/images/girl.jpg",
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Text("Which service do\nyou need?",
                    style: TextStyle(
                        color: Color(0xff284a79),
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search service or provider",
                        suffixIcon:
                        Icon(Icons.search, color: Color(0xff284a79))),
                  ),
                ),
              ],
            ),
          ),

          // Services grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                final icon = s['icon'] as String? ?? '';
                final title = s['title'] as String? ?? '';
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceProvidersPage(
                          serviceName: title, // ✅ fixed
                          userId: "user_001", // ✅ temp hardcoded
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2))
                        ]),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon.isNotEmpty)
                            Image.asset(
                              "assets/images/$icon",
                              height: 56,
                              width: 56,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.build,
                                  size: 48, color: Colors.blue),
                            )
                          else
                            const Icon(Icons.build,
                                size: 48, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xff284a79),
                                  fontWeight: FontWeight.bold)),
                        ]),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
