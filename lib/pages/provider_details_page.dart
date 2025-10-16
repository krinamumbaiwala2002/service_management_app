// lib/pages/provider_detail_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'booking_page.dart';

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

  // Pick date
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  // Pick time
  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  // Proceed to Booking Page (with preselected date & time)
  void _proceedToBookingPage() {
    // If date & time are not picked, auto fill with current
    final now = DateTime.now();
    final date = selectedDate ?? now;
    final time = selectedTime ?? TimeOfDay.now();

    final bookingDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final bookingTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPage(
          userId: widget.userId,
          providerId: widget.provider["id"]?.toString(),
          providerName: widget.provider["name"]?.toString(),
          serviceName: widget.serviceName,
          preselectedDate: bookingDate,
          preselectedTime: bookingTime,
         // initialTabIndex: 0, // open "New Booking" tab only
          fromProvider: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final bool available = (provider["available"] ?? false) == true;
    final double rating = (provider["rating"] ?? 0).toDouble();
    final int reviews = provider["reviews"] ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C4E9),
        title: Row(
          children: [
            Image.asset("assets/images/logo.png", height: 40, width: 40),
            const SizedBox(width: 8),
            const Text(
              "WorkNest",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            CircleAvatar(radius: 32, child: Icon(Icons.person, size: 40)),
            SizedBox(width: 12),
          ]),
          const SizedBox(height: 8),
          Text(
            provider["name"] ?? "",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.phone),
            const SizedBox(width: 8),
            Text(provider["phone"] ?? ""),
          ]),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.location_on),
            const SizedBox(width: 8),
            Expanded(
                child:
                Text(provider["address"] ?? "No address available")),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Icon(
              available ? Icons.check_circle : Icons.cancel,
              color: available ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                available
                    ? "Available Today"
                    : "Available on ${provider["availableDate"]} at ${provider["notAvailableTime"]}",
                style:
                TextStyle(color: available ? Colors.green : Colors.red),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < rating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text("($reviews reviews)"),
          ]),
          const Spacer(),

          // Booking UI
          if (available) ...[
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    selectedDate == null
                        ? "Select Date"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickTime,
                  child: Text(
                    selectedTime == null
                        ? "Select Time"
                        : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1C4E9),
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _proceedToBookingPage,
                child: const Text(
                  "Book Now",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "⚠️ Provider not available today.\nNext available: ${provider["availableDate"]} at ${provider["notAvailableTime"]}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
