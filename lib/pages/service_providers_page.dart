import 'package:flutter/material.dart';
import 'api_service.dart';
import 'provider_details_page.dart'; // ⬅️ new page we’ll create

class ServiceProvidersPage extends StatefulWidget {
  final String serviceName;
  final String userId;

  const ServiceProvidersPage({
    super.key,
    required this.serviceName,
    required this.userId,
  });

  @override
  State<ServiceProvidersPage> createState() => _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends State<ServiceProvidersPage> {
  final TextEditingController searchCtrl = TextEditingController();
  List<Map<String, dynamic>> providers = [];
  List<Map<String, dynamic>> filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProviders();
    searchCtrl.addListener(() {
      final query = searchCtrl.text.toLowerCase();
      setState(() {
        filtered = providers
            .where((p) => p["name"].toLowerCase().contains(query))
            .toList();
      });
    });
  }

  Future<void> loadProviders() async {
    setState(() => isLoading = true);
    final data = await ApiService.getProvidersForService(widget.serviceName);
    setState(() {
      providers = data;
      filtered = data;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo + name
              Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 50,
                    width: 50,
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
              const SizedBox(height: 12),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                    hintText: "search for services",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Providers list
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? const Center(child: Text("No providers found"))
                    : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final provider = filtered[index];
                    return Card(
                      margin:
                      const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.person,
                            color: Colors.black, size: 32),
                        title: Text(provider["name"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.phone, size: 14),
                            const SizedBox(width: 4),
                            Text(provider["phone"]),
                          ],
                        ),
                        onTap: () {
                          // 👉 Navigate to detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProviderDetailPage(
                                provider: provider,
                                serviceName: widget.serviceName,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
