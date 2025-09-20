import 'package:flutter/material.dart';
import 'api_service.dart';
import 'booking_page.dart';

class ServiceProvidersPage extends StatefulWidget {
  final String serviceName;
  final String userId;
  const ServiceProvidersPage({super.key, required this.serviceName, required this.userId,});

  @override
  State<ServiceProvidersPage> createState() => _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends State<ServiceProvidersPage> {
  List<Map<String, dynamic>> providers = [];
  List<Map<String, dynamic>> filtered = [];
  bool isLoading = true;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProviders();
    searchCtrl.addListener(() => applySearch(searchCtrl.text));
  }

  void applySearch(String q) {
    final qLower = q.trim().toLowerCase();
    if (qLower.isEmpty) {
      setState(() => filtered = providers);
    } else {
      setState(() => filtered = providers
          .where((p) => (p['name'] as String).toLowerCase().contains(qLower))
          .toList());
    }
  }

  Future<void> loadProviders() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getProvidersForService(widget.serviceName);
      setState(() {
        providers = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading providers')));
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
      appBar: AppBar(title: Text("${widget.serviceName} Providers"), backgroundColor: const Color(
          0xffc5e3f4)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                  labelText: "Search provider",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search)
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(child: Text("No providers available.", style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final p = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text((p['name'] as String)[0].toUpperCase())),
                    title: Text(p['name']),
                    subtitle: Text("📞 ${p['phone']}"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPage(userId: widget.userId, providerName: p['name'], serviceName: widget.serviceName,),),);
                      },
                      child: const Text("Book"),
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
