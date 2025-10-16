import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/chat_screen.dart';
import 'pages/booking_page.dart';
import 'pages/user_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String? currentUserId;
  String? role;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString("userId");
      role = prefs.getString("role") ?? "user";
    });
  }

  void _onItemTapped(int index) async {
    if ((index == 1 || index == 2 || index == 3) && currentUserId == null) {
      final loggedIn = await Navigator.push<bool?>(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      await loadUser();
      if (currentUserId == null) return;
    }
    setState(() => _selectedIndex = index);
  }

  Widget _buildPage(int idx) {
    switch (idx) {
      case 0:
        return const Home();
      case 1:
        return BookingPage(userId: currentUserId ?? "", fromProvider: false);
      case 2:
        return currentUserId != null
            ? UserProfilePage(userId: currentUserId!, role: role ?? "user")
            : const LoginPage();
      case 3:
        return currentUserId != null ? const ChatScreen() : const LoginPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
}
