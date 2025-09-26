// lib/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// -------------------------------
/// Dummy in-memory bookings list
/// -------------------------------
List<Map<String, dynamic>> _dummyBookings = [
  {
    "id": "BKG1",
    "service": "Plumber",
    "provider": "Ramesh Patel",
    "date": "2025-09-25",
    "time": "10:00 AM",
    "userId": "1",
  },
  {
    "id": "BKG2",
    "service": "Electrician",
    "provider": "Suresh Kumar",
    "date": "2025-09-26",
    "time": "02:30 PM",
    "userId": "1",
  },
];

class ApiService {
  static const String BASE_URL = "http://your-backend-url.com/api"; // 👈 replace later

  /// -------------------------------
  /// Dummy Login
  /// -------------------------------
  static Future<Map<String, dynamic>> login(
      String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    // ✅ Dummy credentials
    if (phone == "1234567890" && password == "password") {
      return {
        "token": "dummy_token_123",
        "id": "1",
        "name": "Demo User",
        "phone": phone,
        "email": "demo@example.com",
      };
    } else {
      throw Exception("Invalid phone or password");
    }
  }

  /// -------------------------------
  /// Dummy Signup
  /// -------------------------------
  static Future<Map<String, dynamic>> signup(
      Map<String, dynamic> userData, {File? profileImage}) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    return {
      "token": "dummy_signup_token_456",
      "id": "2",
      "name": userData['name'] ?? "New User",
      "phone": userData['phone'] ?? "0000000000",
      "email": userData['email'] ?? "new@example.com",
    };
  }

  /// -------------------------------
  /// Get User Profile
  /// -------------------------------
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate delay
    return {
      "id": userId,
      "name": "Demo User",
      "phone": "9999999999",
      "email": "demo@example.com",
    };
  }

  /// -------------------------------
  /// Get Services
  /// -------------------------------
  static Future<List<Map<String, dynamic>>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {"title": "Plumber", "icon": "plumbing.png"},
      {"title": "Electrician", "icon": "electrician.png"},
      {"title": "Carpenter", "icon": "carpentry.png"},
      {"title": "Painter", "icon": "painting.png"},
      {"title": "Electrician", "icon": "cleaning.png"},
      {"title": "Carpenter", "icon": "ac.png"},
      {"title": "Painter", "icon": "laundry.png"},
    ];
  }

  /// -------------------------------
  /// Get Providers for a Service
  /// -------------------------------
  static Future<List<Map<String, dynamic>>> getProvidersForService(
      String serviceName) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final dummy = {
      "Plumber": [
        {
          "id": "1",
          "name": "Ramesh Patel",
          "phone": "9876543210",
          "address": "Vesu, VIP Road, Surat, Gujarat",
          "available": true,
          "availableDate": "2025-09-24",
          "notAvailableTime": "6:30 PM",
          "rating": 4.5,
          "reviews": 47,
        },
        {
          "id": "2",
          "name": "Ankit Sharma",
          "phone": "9123456780",
          "address": "Adajan, Surat, Gujarat",
          "available": false,
          "availableDate": "2025-09-25",
          "notAvailableTime": "11:00 AM",
          "rating": 4.0,
          "reviews": 32,
        },
      ],
      "Electrician": [
        {
          "id": "3",
          "name": "Suresh Kumar",
          "phone": "9876501234",
          "address": "Nanpura, Surat, Gujarat",
          "available": true,
          "availableDate": "2025-09-24",
          "notAvailableTime": "5:00 PM",
          "rating": 4.2,
          "reviews": 20,
        },
        {
          "id": "4",
          "name": "Mukesh Singh",
          "phone": "9988776655",
          "address": "Athwa, Surat, Gujarat",
          "available": false,
          "availableDate": "2025-09-26",
          "notAvailableTime": "10:30 AM",
          "rating": 3.8,
          "reviews": 15,
        },
      ],
      "Carpenter": [
        {
          "id": "5",
          "name": "Rajiv Mehta",
          "phone": "9911223344",
          "address": "Varachha, Surat, Gujarat",
          "available": true,
          "availableDate": "2025-09-27",
          "notAvailableTime": "9:00 AM",
          "rating": 4.7,
          "reviews": 52,
        },
      ],
      "Painter": [
        {
          "id": "6",
          "name": "Vinod Gupta",
          "phone": "9001122334",
          "address": "Katargam, Surat, Gujarat",
          "available": false,
          "availableDate": "2025-09-28",
          "notAvailableTime": "2:00 PM",
          "rating": 4.3,
          "reviews": 28,
        },
      ],
    };

    return dummy[serviceName] ?? [];
  }

  /// -------------------------------
  /// Book Service
  /// -------------------------------
  static Future<Map<String, dynamic>> bookService({
    required String userId,
    required String providerName,
    required String serviceName,
    required String date,
    required String time,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newBooking = {
      "id": "BKG${_dummyBookings.length + 1}",
      "userId": userId,
      "provider": providerName,
      "service": serviceName,
      "date": date,
      "time": time,
    };
    _dummyBookings.add(newBooking);
    return {"success": true, "booking": newBooking};
  }

  /// -------------------------------
  /// Get User Bookings
  /// -------------------------------
  static Future<List<Map<String, dynamic>>> getUserBookings(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyBookings
        .where((b) => b["userId"] == userId) // ✅ filter by userId
        .toList();
  }

  /// -------------------------------
  /// Cancel Booking
  /// -------------------------------
  static Future<Map<String, dynamic>> cancelBooking(
      String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyBookings.removeWhere((b) => b["id"] == bookingId);
    return {
      "success": true,
      "cancelledBookingId": bookingId,
      "message": "Booking cancelled successfully",
    };
  }
}
