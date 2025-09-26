// lib/provider_detail_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class ProviderDetailPage extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String serviceName;
  final String userId;

  const ProviderDetailPage({
    super.key,
    required this.provider,
    required this.serviceName,
    required this.userId,
  });

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void _bookService() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time first")),
      );
      return;
    }

    final bookingDate = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    final bookingTime = "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    final result = await ApiService.bookService(
      userId: widget.userId,
      providerName: widget.provider["name"],
      serviceName: widget.serviceName,
      date: bookingDate,
      time: bookingTime,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Service booked with ${widget.provider["name"]}")),
      );
      Navigator.pop(context, result["booking"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final bool available = provider["available"] ?? false;
    final double rating = (provider["rating"] ?? 0).toDouble();
    final int reviews = provider["reviews"] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider["name"]),
        backgroundColor: const Color(0xFFD1C4E9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Icon + Name
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider["name"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.black54),
                const SizedBox(width: 8),
                Text(provider["phone"]),
              ],
            ),
            const SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(provider["address"] ?? "No address available"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Availability
            Row(
              children: [
                Icon(
                  available ? Icons.check_circle : Icons.cancel,
                  color: available ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  available
                      ? "Available Today"
                      : "Available on ${provider["availableDate"]} at ${provider["notAvailableTime"]}",
                  style: TextStyle(
                    color: available ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating + Reviews
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index < rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("($reviews reviews)"),
              ],
            ),
            const Spacer(),

            if (available) ...[
              // Pick Date & Time
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(selectedTime == null
                          ? "Select Time"
                          : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Book Now button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1C4E9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _bookService,
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ] else ...[
              // Disabled message
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "⚠️ Provider not available today.\nNext available: ${provider["availableDate"]} at ${provider["notAvailableTime"]}",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
