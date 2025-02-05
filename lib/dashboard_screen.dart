import 'package:events/AdminEvent.dart';
import 'package:events/Reviewadmin.dart';
import 'package:flutter/material.dart';
import 'event_list_screen.dart';
import 'notification_screen.dart';
import 'review_screen.dart';
import 'contact_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
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
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.blue.shade900, // Dark blue sidebar
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "admin Dashboard",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _sidebarButton(context, "Request Management", EventListScreen()),
                _sidebarButton(context, "Events Management", AdminEventScreen()),
                _sidebarButton(context, "Reviews", AdminReviewScreen()),
                _sidebarButton(context, "Contact", ContactScreen()),
                Spacer(),
                _logoutButton(context),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              padding: EdgeInsets.all(20),
              child: Center(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/dashboard_image.jpg', // Ensure this image exists in assets
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarButton(BuildContext context, String title, Widget? page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.white),
        
        onTap: () => _logout(context),
      ),
    );
  }
}
