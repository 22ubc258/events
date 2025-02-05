import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  // Replace this with your server key from Firebase Project Settings > Cloud Messaging
  final String _serverKey = 'YOUR_FIREBASE_SERVER_KEY';

  // Function to send notification
  Future<void> sendNotification(String userId, String title, String body) async {
    try {
      // Get the user's FCM token from Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String? userToken = userDoc.data()?['fcmToken']; // Ensure `fcmToken` exists

      if (userToken != null) {
        // Build the notification payload
        final Map<String, dynamic> notificationPayload = {
          'to': userToken,
          'notification': {
            'title': title,
            'body': body,
          },
        };

        // Send the HTTP POST request to Firebase FCM API
        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$_serverKey',
          },
          body: jsonEncode(notificationPayload),
        );

        if (response.statusCode == 200) {
          print("Notification sent successfully");
        } else {
          print("Failed to send notification: ${response.body}");
        }
      } else {
        print("User does not have a valid FCM token.");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
