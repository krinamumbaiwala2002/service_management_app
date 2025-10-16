import 'package:flutter/material.dart';
import 'api_service.dart';
import 'booking_page.dart';

/// --------------------
/// Add/Edit Address Page
/// --------------------
class AddressPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? existing;

  const AddressPage({super.key, required this.userId, this.existing});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController streetCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController zipCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.existing?["name"] ?? "");
    phoneCtrl = TextEditingController(text: widget.existing?["phone"] ?? "");
    streetCtrl = TextEditingController(text: widget.existing?["street"] ?? "");
    cityCtrl = TextEditingController(text: widget.existing?["city"] ?? "");
    stateCtrl = TextEditingController(text: widget.existing?["state"] ?? "");
    zipCtrl = TextEditingController(text: widget.existing?["zip"] ?? "");
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.existing == null) {
      await ApiService.addAddress(
        userId: widget.userId,
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        street: streetCtrl.text,
        city: cityCtrl.text,
        state: stateCtrl.text,
        zip: zipCtrl.text,
      );
    } else {
      await ApiService.updateAddress(
        addressId: widget.existing!["id"],
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        street: streetCtrl.text,
        city: cityCtrl.text,
        state: stateCtrl.text,
        zip: zipCtrl.text,
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Address")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone"),
                validator: (v) => v!.isEmpty ? "Enter phone" : null,
              ),
              TextFormField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: "Street"),
                validator: (v) => v!.isEmpty ? "Enter street" : null,
              ),
              TextFormField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: "City"),
                validator: (v) => v!.isEmpty ? "Enter city" : null,
              ),
              TextFormField(
                controller: stateCtrl,
                decoration: const InputDecoration(labelText: "State"),
                validator: (v) => v!.isEmpty ? "Enter state" : null,
              ),
              TextFormField(
                controller: zipCtrl,
                decoration: const InputDecoration(labelText: "Zip Code"),
                validator: (v) => v!.isEmpty ? "Enter zip" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD1C4E9)),
                onPressed: _save,
                child: const Text("Save Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------------
/// Saved Addresses Page
/// ----------------------
class SavedAddressesPage extends StatefulWidget {
  final String userId;
  const SavedAddressesPage({super.key, required this.userId});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  List<Map<String, dynamic>> addresses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getUserAddresses(widget.userId);
    setState(() {
      addresses = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  void _addNew() async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressPage(userId: widget.userId),
      ),
    );
    if (saved == true) _load();
  }

  void _edit(Map<String, dynamic> addr) async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressPage(userId: widget.userId, existing: addr),
      ),
    );
    if (saved == true) _load();
  }

  void _select(Map<String, dynamic> addr) {
    Navigator.pop(context, addr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Addresses")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? const Center(child: Text("No addresses saved"))
          : ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, i) {
          final a = addresses[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("${a["street"]}, ${a["city"]}"),
              subtitle: Text("${a["state"]}, ${a["zip"]}\n${a["phone"]}"),
              isThreeLine: true,
              onTap: () => _select(a),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _edit(a),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNew,
        child: const Icon(Icons.add),
      ),
    );
  }
}
