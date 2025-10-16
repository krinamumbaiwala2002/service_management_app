import 'package:flutter/material.dart';
import 'api_service.dart';

class MyRatingPage extends StatefulWidget {
  final String workerId; // ✅ pass workerId when navigating
  const MyRatingPage({super.key, required this.workerId});

  @override
  State<MyRatingPage> createState() => _MyRatingPageState();
}

class _MyRatingPageState extends State<MyRatingPage> {
  double avgRating = 0;
  int totalRatings = 0;
  Map<int, int> ratingCount = {};

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    try {
      final response = await ApiService.getWorkerRatings(widget.workerId);
      setState(() {
        avgRating = (response['average'] ?? 0).toDouble();
        totalRatings = response['total'] ?? 0;
        ratingCount = Map<int, int>.from(response['count'] ?? {});
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 50),
                  const SizedBox(width: 6),
                  const Text("WorkNest",
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1C4E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("My Rating",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("⭐ $avgRating / 5.0",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text("Based on $totalRatings ratings"),
                    const SizedBox(height: 15),
                    for (int i = 5; i >= 1; i--)
                      Row(
                        children: [
                          Text("$i ★ "),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: totalRatings == 0
                                  ? 0
                                  : (ratingCount[i] ?? 0) / totalRatings,
                              color: Colors.deepPurple,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text("${ratingCount[i] ?? 0}"),
                        ],
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

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "Booking"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
