import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({Key? key}) : super(key: key);

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  // Function to fetch user details from the users collection
  Future<String> _fetchUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['fullName'] ?? 'Unknown User'; // Fetch the 'name' field
    } catch (e) {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue app bar
        title: const Text(
          'Admin Review Dashboard',
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
              // Title
              const Text(
                'User Reviews',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black text color for titles
                ),
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

                      // Fetch user name asynchronously
                      return FutureBuilder<String>(
                        future: _fetchUserName(review['user']),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final userName = userSnapshot.data ?? 'Unknown User';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User: $userName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
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
}