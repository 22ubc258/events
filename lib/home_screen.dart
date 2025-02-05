import 'package:flutter/material.dart';
import 'event_list_screen.dart';
import 'notification_screen.dart';
import 'review_screen.dart';
import 'contact_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue background for the AppBar
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "EventPlannerApp",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white, // White text for AppBar
              ),
            ),
            Row(
              children: [
                _navButton(context, "Events", EventListScreen()),
                _navButton(context, "Contact Us", ContactScreen()),
                _navButton(context, "Review", ReviewScreen()),
                _navButton(context, "Notification", NotificationScreen()),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white), // White logout icon
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // White background for the body
        child: Center(
          child: Text(
            "Welcome to EventPlannerApp",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Black text for welcome message
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String title, Widget page) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white, // White text for navigation buttons
          fontSize: 16,
        ),
      ),
    );
  }
}
