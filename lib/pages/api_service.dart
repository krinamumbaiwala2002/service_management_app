import 'dart:async';

/// Mock API Service for testing frontend without backend.
/// Later you can replace these with real API calls using http.
class ApiService {
  /// -------- Authentication --------
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      "token": "dummy_token_123",
      "id": "user_001",
      "email": data['email'],
      "name": data['name'] ?? "New User"
    };
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email == "test@example.com" && password == "123456") {
      return {"token": "dummy_token_123", "id": "user_001", "email": email};
    } else {
      throw Exception("Invalid credentials (use test@example.com / 123456)");
    }
  }

  /// -------- Services --------
  static Future<List<Map<String, dynamic>>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      {"id": "s1", "title": "Plumbing", "icon": "plumbing.png"},
      {"id": "s2", "title": "Laundry", "icon": "laundry.png"},
      {"id": "s3", "title": "Painting", "icon": "painting.png"},
      {"id": "s4", "title": "Electrician", "icon": "electrician.png"},
      {"id": "s5", "title": "Cleaning", "icon": "cleaning.png"},
      {"id": "s6", "title": "AC Service", "icon": "ac.png"},
      {"id": "s7", "title": "Carpentry", "icon": "carpentry.png"},
      {"id": "s8", "title": "Repairing", "icon": "repairing.png"},
    ];
  }

  /// -------- Providers --------
  static Future<List<Map<String, dynamic>>> getProvidersForService(
      String serviceName) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final allProviders = [
      {"service": "Plumbing", "name": "WaterFix Plumbers", "phone": "9222222222"},
      {"service": "Laundry", "name": "Quick Wash Laundry", "phone": "9876512345"},
      {"service": "Painting", "name": "Royal Colors", "phone": "9777777777"},
      {"service": "Electrician", "name": "PowerUp Electricians", "phone": "9777771234"},
      {"service": "Cleaning", "name": "Superfast Cleaning", "phone": "9100071234"},
      {"service": "AC Service", "name": "CoolCare AC", "phone": "9888881234"},
      {"service": "Carpentry", "name": "Unique Carpentry", "phone": "9555571234"},
      {"service": "Repairing", "name": "Solution Repairing", "phone": "9733771234"},
    ];

    return allProviders.where((p) => p['service'] == serviceName).toList();
  }

  /// -------- Bookings --------
  static Future<bool> bookService(Map<String, dynamic> bookingData) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true; // Always success for now
  }

  /// -------- User Profile --------
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      "id": userId,
      "name": "Kinjal Mumbaiwala",
      "email": "kinjal@example.com",
      "phone": "9876543210"
    };
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        "service": "Plumbing",
        "provider": "WaterFix Plumbers",
        "date": "2025-09-20",
        "time": "10:00 AM"
      },
      {
        "service": "Laundry",
        "provider": "Quick Wash Laundry",
        "date": "2025-09-22",
        "time": "2:00 PM"
      },
    ];
  }
}
