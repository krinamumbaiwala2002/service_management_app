import 'package:flutter/material.dart';
import 'api_service.dart';

class BookingPage extends StatefulWidget {
  final String userId;
  final String? providerName;
  final String? serviceName; // logged in user
  const BookingPage({super.key, required this.userId, this.providerName, this.serviceName,});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool loading = true;
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getUserBookings(widget.userId);
      setState(() {
        bookings = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load bookings: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xff284a79),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text("No bookings yet"))
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.book_online,
                  color: Colors.blue),
              title: Text(b['service']),
              subtitle: Text(
                  "Provider: ${b['provider']}\nDate: ${b['date']} | Time: ${b['time']}"),
            ),
          );
        },
      ),
    );
  }
}
