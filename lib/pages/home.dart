import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'service_providers_page.dart';
import 'login.dart';

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
  String userName = "Guest";
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadServices();
    searchCtrl.addListener(() => applySearch(searchCtrl.text));
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("userId");

    setState(() {
      currentUserId = id;
      userName = id != null ? "Kinjal" : "Guest";
    });
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
    } catch (_) {
      final dummy = [
        {"title": "Plumber", "icon": "plumbing.png"},
        {"title": "Electrician", "icon": "electrician.png"},
        {"title": "Tailor", "icon": "ac.png"},
        {"title": "Dry Cleaning", "icon": "cleaning.png"},
        {"title": "Painter", "icon": "painting.png"},
        {"title": "Carpenter", "icon": "carpentry.png"},
      ];
      setState(() {
        services = dummy;
        filtered = dummy;
        isLoading = false;
      });
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
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
                top: 50, left: 20, right: 20, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFD1C4E9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hello, $userName",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    /// 👉 App Logo on Right Side
                    Image.asset(
                      "assets/images/logo.png", // replace with your logo path
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Which service do\nyou need?",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Services",
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.deepPurple,
                      ),
                    ),
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
                childAspectRatio: 1.1,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                final icon = s['icon'] as String? ?? '';
                final title = s['title'] as String? ?? '';
                return InkWell(
                  onTap: () {
                    if (currentUserId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceProvidersPage(
                            serviceName: title,
                            userId: currentUserId!,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage()),
                      ).then((_) => loadUser());
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon.isNotEmpty)
                          Image.asset(
                            "assets/images/$icon",
                            height: 56,
                            width: 56,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.build,
                              size: 48,
                              color: Colors.deepPurple,
                            ),
                          )
                        else
                          const Icon(
                            Icons.build,
                            size: 48,
                            color: Colors.deepPurple,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xff284a79),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
