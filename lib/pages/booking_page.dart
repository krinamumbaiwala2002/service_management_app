// lib/pages/booking_page.dart
import 'package:flutter/material.dart';
import 'package:service_management_app/pages/api_service.dart';
import 'address_page.dart'; // contains AddressPage + SavedAddressesPage
import 'booking_details_page.dart';

class BookingPage extends StatefulWidget {
  final String userId;
  final String? providerId;
  final String? providerName;
  final String? serviceName;
  final String? preselectedDate;
  final String? preselectedTime;
  final bool fromProvider;

  const BookingPage({
    super.key,
    required this.userId,
    this.providerId,
    this.providerName,
    this.serviceName,
    this.preselectedDate,
    this.preselectedTime,
    this.fromProvider = false,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool loading = true;
  List<Map<String, dynamic>> bookings = [];
  Map<String, dynamic>? selectedAddress;
  bool loadingAddress = true;

  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();

  bool get isBookingFromProvider => widget.fromProvider;

  @override
  void initState() {
    super.initState();

    if (widget.preselectedDate != null) dateCtrl.text = widget.preselectedDate!;
    if (widget.preselectedTime != null) timeCtrl.text = widget.preselectedTime!;

    loadBookings();
    loadAddress();
  }

  Future<void> loadBookings() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getUserBookings(widget.userId);
      setState(() {
        bookings = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load bookings: $e")),
        );
      }
    }
  }

  Future<void> loadAddress() async {
    setState(() => loadingAddress = true);
    try {
      final addresses = await ApiService.getUserAddresses(widget.userId);
      setState(() {
        selectedAddress = addresses.isNotEmpty ? addresses.first : null;
        loadingAddress = false;
      });
    } catch (e) {
      setState(() => loadingAddress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load address: $e")),
        );
      }
    }
  }

  Future<void> _bookNow() async {
    if (widget.providerId == null ||
        widget.providerName == null ||
        widget.serviceName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No provider/service selected")),
      );
      return;
    }
    if (dateCtrl.text.isEmpty || timeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or add address")),
      );
      return;
    }

    try {
      final result = await ApiService.bookService(
        userId: widget.userId,
        providerId: widget.providerId!,
        providerName: widget.providerName!,
        serviceName: widget.serviceName!,
        date: dateCtrl.text,
        time: timeCtrl.text,
        address: selectedAddress!,
        addressId: selectedAddress!['id']?.toString() ?? '',
      );

      if (result["success"] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["message"] ?? "Booking successful ✅"),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(seconds: 1));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BookingPage(
                userId: widget.userId,
                fromProvider: false,
              ),
            ),
          );
        }
      } else {
        throw Exception("Booking failed");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: $e")),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dateCtrl.text) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateCtrl.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      timeCtrl.text = picked.format(context);
    }
  }

  Future<void> _openAddressPage() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SavedAddressesPage(userId: widget.userId)),
    );
    if (selected != null) {
      setState(() {
        selectedAddress = Map<String, dynamic>.from(selected);
      });
    }
  }

  Widget _buildAddressSection() {
    if (loadingAddress) return const Center(child: CircularProgressIndicator());
    if (selectedAddress == null) {
      return ListTile(
        leading: const Icon(Icons.location_on, color: Colors.red),
        title: const Text("No address found"),
        trailing: TextButton(
          onPressed: _openAddressPage,
          child: const Text("Add Address"),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.home, color: Colors.deepPurple),
        title: Text(selectedAddress!['name'] ?? "Unnamed"),
        subtitle: Text(
          "${selectedAddress!['street']}, ${selectedAddress!['city']}, ${selectedAddress!['state']} - ${selectedAddress!['zip']}\n📞 ${selectedAddress!['phone']}",
        ),
        trailing: TextButton(
          onPressed: _openAddressPage,
          child: const Text("Change"),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (bookings.isEmpty) {
      return const Center(child: Text("No bookings yet"));
    }
    return RefreshIndicator(
      onRefresh: loadBookings,
      child: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.book_online, color: Colors.blue),
              title: Text(b['service'] ?? ""),
              subtitle: Text(
                "Provider: ${b['provider']}\nDate: ${b['date']} | Time: ${b['time']}\nStatus: ${b['status'] ?? ''}",
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingDetailsPage(
                      booking: b,
                      userId: widget.userId,
                      onCancelled: loadBookings,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: (widget.providerName != null && widget.serviceName != null)
          ? Column(
        children: [
          _buildAddressSection(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Book ${widget.serviceName} with ${widget.providerName}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dateCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Select Date",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: timeCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Select Time",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: _pickTime,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _bookNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1C4E9),
                    ),
                    child: const Text("Proceed"),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : const Center(child: Text("No provider/service selected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/images/logo.png", height: 40, width: 40),
            const SizedBox(width: 8),
            Text(
              isBookingFromProvider ? "Book Service" : "My Bookings",
              style: const TextStyle(color: Colors.deepPurple),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD1C4E9),
      ),
      body: isBookingFromProvider ? _buildNewBookingForm() : _buildBookingsList(),
    );
  }
}
