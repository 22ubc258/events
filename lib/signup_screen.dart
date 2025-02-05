import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Text('Create', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('Account', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 40),

              // Full Name
              Text('Full Name', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              SizedBox(height: 8),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 20),

              // Date of Birth
              Text('Date of Birth', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              SizedBox(height: 8),
              TextField(
                controller: dobController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 20),

              // Email Field
              Text('Email', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 20),

              // Password Field
              Text('Password', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 20),

              // Confirm Password Field
              Text('Confirm Password', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 20),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Password Mismatch"),
                          content: Text("Passwords do not match."),
                          actions: [TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop())],
                        ),
                      );
                      return;
                    }

                    try {
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      
                      // Store user details in Firestore
                      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                        'fullName': fullNameController.text.trim(),
                        'dateOfBirth': dobController.text.trim(),
                        'email': emailController.text.trim(),
                        'uid': userCredential.user!.uid,
                        'role':'user',
                      });

                      // Navigate to LoginScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Signup Error"),
                          content: Text(e.toString()),
                          actions: [TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop())],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 20),

              // Already Have an Account? Login Button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                      children: [TextSpan(text: 'Log in', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold))],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
