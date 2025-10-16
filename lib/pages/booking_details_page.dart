// lib/pages/booking_details_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class BookingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onCancelled;

  const BookingDetailsPage({
    super.key,
    required this.booking,
    this.onCancelled, required String userId,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool cancelling = false;

  Future<void> cancelBooking() async {
    setState(() => cancelling = true);
    try {
      final result =
      await ApiService.cancelBooking(widget.booking['id'].toString());

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Booking cancelled successfully"),
            backgroundColor: Colors.redAccent,
          ),
        );

        widget.onCancelled?.call();
        Navigator.pop(context, true); // go back to list after cancel
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to cancel booking"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isCompleted = booking['status']?.toString().toLowerCase() == 'completed';
    final isCancelled = booking['status']?.toString().toLowerCase() == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C4E9),
        title: Row(
          children: [
            Image.asset("assets/images/logo.png", height: 40, width: 40),
            const SizedBox(width: 8),
            const Text("WorkNest", style: TextStyle(color: Colors.deepPurple)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Booking", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _infoRow("Service:", booking['service']),
                _infoRow("Provider:", booking['provider']),
                _infoRow("Date:", booking['date']),
                _infoRow("Time:", booking['time']),
                _infoRow("Amount:", booking['amount']?.toString() ?? "₹5000"),
                _infoRow("Status:", booking['status'] ?? "Upcoming"),
                if (booking['address'] != null)
                  _infoRow("Address:", booking['address']['street'] ?? ""),

                const SizedBox(height: 24),
                if (!isCancelled)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isCompleted)
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Reschedule feature coming soon"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Reschedule"),
                        ),
                      ElevatedButton(
                        onPressed: cancelling ? null : cancelBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: cancelling
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text("Cancel", style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
