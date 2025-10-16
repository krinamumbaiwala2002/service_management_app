// lib/api_service.dart
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

/// -------------------------------
/// In-Memory Dummy Data
/// -------------------------------
List<Map<String, dynamic>> _dummyBookings = [];
List<Map<String, dynamic>> _dummyAddresses = [];
List<Map<String, dynamic>> _dummyPayments = [
  {
    "id": "pay001",
    "service": "AC Repair",
    "amount": 600,
    "date": "2025-10-02 3:45 PM",
    "method": "COD",
    "status": "Successful",
  },
  {
    "id": "pay002",
    "service": "Painting",
    "amount": 1600,
    "date": "2025-10-01 2:00 PM",
    "method": "COD",
    "status": "Pending",
  },
  {
    "id": "pay003",
    "service": "Tiling",
    "amount": 350,
    "date": "2025-09-30 2:00 PM",
    "method": "COD",
    "status": "Cancelled",
  },
];

final Map<String, dynamic> _dummyWorkerProfile = {
  "id": "101",
  "name": "PipePros Plumber",
  "phone": "9876543210",
  "email": "pipepros@example.com",
  "password": "worker@123",
  "aadhaar": "1234-5678-9123",
  "address": "Vesu, VIP Road, Surat, Gujarat",
  "skills": "Plumbing, Leak Repair, Drain Cleaning",
  "available": true,
  "availableDate": "2025-09-24",
  "notAvailableTime": "6:30 PM",
  "rating": 4.6,
  "reviews": 120,
};

class ApiService {
  static const String BASE_URL = "http://your-backend-url.com/api";
  static String get baseUrl => BASE_URL;

  /// -------------------------------
  /// Authentication (dummy login)
  /// -------------------------------
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // User login
    if (phone == "1234567890" && password == "password") {
      return {
        "token": "dummy_token_123",
        "id": "1",
        "role": "user",
        "name": "Demo User",
        "phone": phone,
        "email": "demo@example.com",
      };
    }

    // Worker login
    if (phone == _dummyWorkerProfile["phone"] &&
        password == _dummyWorkerProfile["password"]) {
      return {
        "token": "worker_token_999",
        "id": _dummyWorkerProfile["id"],
        "role": "worker",
        "name": _dummyWorkerProfile["name"],
        "phone": _dummyWorkerProfile["phone"],
        "email": _dummyWorkerProfile["email"],
      };
    }

    throw Exception("Invalid phone or password");
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> userData, {File? profileImage}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      "token": "dummy_signup_token_456",
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "role": "user",
      "name": userData['name'] ?? "New User",
      "phone": userData['phone'] ?? "0000000000",
      "email": userData['email'] ?? "new@example.com",
    };
  }

  /// -------------------------------
  /// Password change
  /// -------------------------------
  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (userId == _dummyWorkerProfile["id"] &&
        currentPassword == _dummyWorkerProfile["password"]) {
      _dummyWorkerProfile["password"] = newPassword;
      return {"success": true, "message": "Password updated successfully"};
    }

    if (userId == "1" && currentPassword == "password") {
      return {"success": true, "message": "Password updated successfully"};
    }

    return {"success": false, "message": "Incorrect current password"};
  }

  /// -------------------------------
  /// Profiles
  /// -------------------------------
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      "id": userId,
      "name": "Demo User",
      "phone": "9999999999",
      "email": "demo@example.com",
    };
  }

  /// ✅ Fixed: getWorkerProfile no longer requires workerId
  static Future<Map<String, dynamic>> getWorkerProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Map<String, dynamic>.from(_dummyWorkerProfile);
  }

  /// ✅ Fixed: updateWorkerProfile now safely updates dummy data
  static Future<bool> updateWorkerProfile(Map<String, dynamic> updated) async {
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      _dummyWorkerProfile.addAll(updated);
      debugPrint("Updated worker profile: $_dummyWorkerProfile");
      return true;
    } catch (e) {
      debugPrint("Error updating worker profile: $e");
      return false;
    }
  }

  /// -------------------------------
  /// My Rating
  /// -------------------------------
  static Future<Map<String, dynamic>> getWorkerRatings(String workerId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      "average": _dummyWorkerProfile["rating"],
      "total": _dummyWorkerProfile["reviews"],
      "count": {
        5: 20,
        4: 5,
        3: 2,
        2: 1,
        1: 0,
      },
    };
  }

  /// -------------------------------
  /// Payment History
  /// -------------------------------
  static Future<dynamic> getPaymentHistory(dynamic userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyPayments;
  }

  /// -------------------------------
  /// Services & Providers
  /// -------------------------------
  static Future<List<Map<String, dynamic>>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {"title": "Plumber", "icon": "plumbing.png"},
      {"title": "Electrician", "icon": "electrician.png"},
      {"title": "Carpenter", "icon": "carpentry.png"},
      {"title": "Painter", "icon": "painting.png"},
      {"title": "Cleaning", "icon": "cleaning.png"},
      {"title": "AC Service", "icon": "ac.png"},
      {"title": "Laundry", "icon": "laundry.png"},
    ];
  }

  static Future<List<Map<String, dynamic>>> getProvidersForService(String serviceName) async {
    await Future.delayed(const Duration(milliseconds: 400));
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
      ],
    };
    return dummy[serviceName] ?? [];
  }

  /// -------------------------------
  /// Address
  /// -------------------------------
  static Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _dummyAddresses.where((a) => a["userId"] == userId).toList();
  }

  static Future<void> addAddress({
    required String userId,
    required String name,
    required String phone,
    required String street,
    required String city,
    required String state,
    required String zip,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final newAddress = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "userId": userId,
      "name": name,
      "phone": phone,
      "street": street,
      "city": city,
      "state": state,
      "zip": zip,
    };
    _dummyAddresses.add(newAddress);
  }

  /// -------------------------------
  /// Booking
  /// -------------------------------
  static Future<Map<String, dynamic>> bookService({
    required String userId,
    required String providerId,
    required String providerName,
    required String serviceName,
    required String date,
    required String time,
    required Map<String, dynamic> address,
    required String addressId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final booking = {
      "id": "BKG${DateTime.now().millisecondsSinceEpoch}",
      "service": serviceName,
      "providerId": providerId,
      "provider": providerName,
      "date": date,
      "time": time,
      "userId": userId,
      "addressId": addressId,
      "address": address,
      "status": "Upcoming",
      "createdAt": DateTime.now().toString(),
    };
    _dummyBookings.add(booking);
    return {"success": true, "booking": booking, "message": "Booking successful"};
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyBookings.where((b) => b["userId"] == userId).toList().reversed.toList();
  }

  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _dummyBookings.indexWhere((b) => b["id"] == bookingId);
    if (idx != -1) {
      _dummyBookings[idx]["status"] = "Cancelled";
      return {"success": true, "cancelledBookingId": bookingId, "message": "Booking cancelled successfully"};
    } else {
      return {"success": false, "message": "Booking not found"};
    }
  }

  static Future<void> updateAddress({required addressId, required String name, required String phone, required String street, required String city, required String state, required String zip}) async {}
}
