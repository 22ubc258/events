import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Submit message to Firestore
  Future<void> submitMessage() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {
      // Store message in Firestore
      await FirebaseFirestore.instance.collection('contactMessages').add({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'user':FirebaseAuth.instance.currentUser!.uid
      });

      // Clear the fields after submission
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your message has been submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit message: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue app bar
        title: Text(
          "Contact Us",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // White text
        ),
      ),
      body: Container(
        color: Colors.white, // White background for the body
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Title
              Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black text color for titles
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              _buildInputField(
                controller: _nameController,
                labelText: "Name",
              ),
              SizedBox(height: 16),

              // Email Field
              _buildInputField(
                controller: _emailController,
                labelText: "Email",
              ),
              SizedBox(height: 16),

              // Phone Field
              _buildInputField(
                controller: _phoneController,
                labelText: "Phone Number",
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),

              // Message Field
              _buildInputField(
                controller: _messageController,
                labelText: "Message",
                maxLines: 5,
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: submitMessage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Blue text color
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable function for input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 14, color: Colors.black54), // Light color for labels
        filled: true,
        fillColor: Colors.white, // White background for inputs
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blue), // Blue border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blue), // Blue focus border
        ),
      ),
    );
  }
}
