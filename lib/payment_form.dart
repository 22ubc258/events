import 'package:flutter/material.dart';

class PaymentForm extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  // Dummy method to simulate storing payment data
  void _submitPaymentDetails() {
    // You can use Firebase or other services to store data
    print("Payment details submitted:");
    print("Name: ${_nameController.text}");
    print("Mobile: ${_mobileController.text}");
    print("Email: ${_emailController.text}");

    // Simulate an email confirmation (can integrate with mailer package here)
    _sendConfirmationEmail(_emailController.text);
  }

  void _sendConfirmationEmail(String email) {
    // Simulate sending confirmation email
    print("Sending confirmation email to $email");
    // Add actual mail sending code here using your preferred service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _mobileController,
              decoration: InputDecoration(labelText: "Mobile Number"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email Address"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPaymentDetails,
              child: Text("Submit Payment Details"),
            ),
          ],
        ),
      ),
    );
  }
}
