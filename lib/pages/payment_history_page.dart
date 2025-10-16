import 'package:flutter/material.dart';
import 'api_service.dart';

class PaymentHistoryPage extends StatefulWidget {
  final dynamic userId; // Can be int or String

  const PaymentHistoryPage({super.key, required this.userId});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<Map<String, dynamic>> payments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      final response = await ApiService.getPaymentHistory(widget.userId);

      // ✅ Normalize response: sometimes list, sometimes map
      if (response is List) {
        payments = List<Map<String, dynamic>>.from(response);
      } else if (response is Map &&
          response.containsKey('payments') &&
          response['payments'] is List) {
        payments = List<Map<String, dynamic>>.from(response['payments']);
      } else {
        payments = [];
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
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
              // 🔹 Header
              Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 50),
                  const SizedBox(width: 6),
                  const Text(
                    "WorkNest",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Payment History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : payments.isEmpty
                    ? const Center(child: Text("No payment yet"))
                    : ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, i) {
                    final p = payments[i];
                    return Card(
                      color: const Color(0xFFD1C4E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin:
                      const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text("Service: ${p['service']}"),
                            Text("Date: ${p['date']}"),
                            Text("Amount: ₹${p['amount']}"),
                            Text(
                                "Method: ${p['paymentMethod'] ?? 'N/A'}"),
                            Row(
                              children: [
                                const Text("Status: "),
                                Text(
                                  p['status'] ?? 'Pending',
                                  style: TextStyle(
                                    color: (p['status'] ?? '')
                                        .toLowerCase()
                                        .contains('success')
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
