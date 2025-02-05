import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _reviewTextController = TextEditingController();
  double _rating = 0.0; // Star rating (double)

  // Function to submit the review
  void _submitUserReview(BuildContext context) async {
    String reviewText = _reviewTextController.text.trim();

    if (reviewText.isEmpty || _rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    try {
      // Save review to Firebase Firestore
      await FirebaseFirestore.instance.collection('userReviews').add({
        'reviewText': reviewText,
        'rating': _rating, // Save rating as a double
        'timestamp': DateTime.now(),
        'user': FirebaseAuth.instance.currentUser!.uid,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your review!')),
      );

      // Clear input fields
      _reviewTextController.clear();
      setState(() {
        _rating = 0.0; // Reset rating
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to fetch user's name
  Future<String> _fetchUserName(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['fullName']; // Assuming the user document has a 'name' field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue app bar
        title: const Text(
          'Submit Your Review',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // White text
        ),
      ),
      body: Container(
        color: Colors.white, // White background for the body
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Title
              const Text(
                'We value your feedback!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black text color for titles
                ),
              ),
              const SizedBox(height: 20),

              // Review Field
              _buildInputField(
                controller: _reviewTextController,
                labelText: 'Write your review here',
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              // Rating Section
              const Text(
                'Rating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () => _submitUserReview(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Blue text color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),

              // Previous Reviews Title
              const Text(
                'Previous Reviews',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // StreamBuilder to fetch and display reviews
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('userReviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No reviews yet.');
                  }
                  final reviews = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];

                      // Gracefully handle old rating field stored as String
                      double rating = 0.0;
                      if (review['rating'] is num) {
                        rating = review['rating'].toDouble();
                      } else if (review['rating'] is String) {
                        rating = double.tryParse(review['rating']) ?? 0.0;
                      }

                      return FutureBuilder<String>(
                        future: _fetchUserName(review['user']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final userName = snapshot.data ?? 'Unknown User';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        starIndex < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Review: ${review['reviewText']}'),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Date: ${(review['timestamp'] as Timestamp).toDate()}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black54), // Light color for labels
        filled: true,
        fillColor: Colors.white, // White background for inputs
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue), // Blue border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue), // Blue focus border
        ),
      ),
    );
  }
}