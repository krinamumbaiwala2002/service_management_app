import 'package:flutter/material.dart';
// import 'api_service.dart'; // 🔒 Keep commented until backend is ready

class BookingPage extends StatefulWidget {
  final String userId;
  final String? providerName;
  final String? serviceName;

  const BookingPage({
    super.key,
    required this.userId,
    this.providerName,
    this.serviceName,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  List<Map<String, dynamic>> bookings = [];

  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadBookings() async {
    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate API delay

    // ✅ Dummy data for testing
    final dummy = [
      {
        "service": "Plumber",
        "provider": "John Doe",
        "date": "2025-09-28",
        "time": "10:30 AM"
      },
      {
        "service": "Electrician",
        "provider": "Jane Smith",
        "date": "2025-09-29",
        "time": "2:00 PM"
      }
    ];

    setState(() {
      bookings = dummy;
      loading = false;
    });

    // 🔓 Later you can re-enable this
    /*
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
    */
  }

  Future<void> _bookNow() async {
    if (widget.providerName == null || widget.serviceName == null) {
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

    // ✅ Add to dummy list
    final newBooking = {
      "service": widget.serviceName!,
      "provider": widget.providerName!,
      "date": dateCtrl.text,
      "time": timeCtrl.text,
    };

    setState(() {
      bookings.add(newBooking);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking successful ✅"),
        backgroundColor: Colors.green,
      ),
    );

    // reload bookings list
    _tabController.animateTo(1); // switch to history tab

    // 🔓 Later enable API
    /*
    try {
      await ApiService.bookService(
        userId: widget.userId,
        providerName: widget.providerName!,
        serviceName: widget.serviceName!,
        date: dateCtrl.text,
        time: timeCtrl.text,
      );
      loadBookings();
      _tabController.animateTo(1);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }
    */
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateCtrl.text = "${picked.year}-${picked.month}-${picked.day}";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings"),
        backgroundColor: const Color(0xFFD1C4E9),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "New Booking", icon: Icon(Icons.add_circle_outline)),
            Tab(text: "My Bookings", icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: New Booking
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: widget.providerName != null && widget.serviceName != null
                ? Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Book ${widget.serviceName} with ${widget.providerName}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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
                        backgroundColor: const Color(0xff284a79),
                      ),
                      child: const Text("Book Now"),
                    ),
                  ],
                ),
              ),
            )
                : const Center(
              child: Text("No provider/service selected"),
            ),
          ),

          // Tab 2: Booking History
          loading
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
                    "Provider: ${b['provider']}\nDate: ${b['date']} | Time: ${b['time']}",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
