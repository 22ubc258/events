import 'package:flutter/material.dart';

class EventListScreen extends StatelessWidget {
  final List<Map<String, String>> eventCategories = [
    {'category': 'Weddings', 'description': 'A beautiful wedding event with all the traditional ceremonies.'},
    {'category': 'Wedding Combo', 'description': 'Combo includes Bachelor\'s Party, Bride-To-Be, Sangeet, and Haldi.'},
    {'category': 'Baptism', 'description': 'A special day for a child\'s baptism ceremony.'},
    {'category': 'Birthday Parties', 'description': 'Celebrate a fun-filled birthday with games, food, and entertainment.'},
    {'category': 'First Holy Communion', 'description': 'A religious event marking a child\'s first communion.'},
  ];

  final Map<String, List<Map<String, String>>> eventThemes = {
    'Weddings': [
      {'title': 'Muslim Wedding', 'description': 'Traditional Muslim wedding style', 'image': 'assets/download.jpg'},
      {'title': 'Hindu Wedding', 'description': 'Traditional Hindu wedding style', 'image': 'assets/hindy.jpg'},
      {'title': 'Christian Wedding', 'description': 'Traditional Christian wedding style', 'image': 'assets/pexels1.jpg'},
      {'title': 'Garden Wedding', 'description': 'Beautiful outdoor garden setup', 'image': 'assets/garden.jpg'},
      {'title': 'Beach Wedding', 'description': 'A romantic beachside wedding', 'image': 'assets/beach.jpg'},
    ],
    'Wedding Combo': [
      {'title': 'mehendi', 'description': 'A colorful, festive setup with henna art, floral décor, and traditional vibes.', 'image': 'assets/meh.jpg'},
      {'title': 'Bride-To-Be', 'description': 'Elegant and sophisticated bride-to-be theme', 'image': 'assets/images/bride_to_be.jpg'},
      {'title': 'Sangeet', 'description': 'Traditional and vibrant sangeet theme', 'image': 'assets/images/sangeet.jpg'},
      {'title': 'Haldi', 'description': 'Bright and cheerful haldi theme', 'image': 'assets/images/haldi.jpg'},
    ],
    'Baptism': [
      {'title': '', 'description': '','image': 'assets/bap.jpg'},
      {'title': '', 'description': '','image': 'assets/bap2.jpg'},
    ],
    'Birthday Parties': [
      {'image': 'assets/images/kids_birthday.jpg'},
      {'image': 'assets/images/adult_birthday.jpg'},
    ],
    'First Holy Communion': [
      {'image': 'assets/images/traditional_communion.jpg'},
      {'image': 'assets/images/modern_communion.jpg'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue AppBar background
        elevation: 0,
        title: Text(
          "Event Categories",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: eventCategories.length,
          itemBuilder: (context, index) {
            final event = eventCategories[index];
            final eventCategory = event['category']!;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4.0,
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                title: Text(
                  eventCategory,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                subtitle: Text(
                  event['description']!,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/booking',
                    arguments: {
                      'eventCategory': eventCategory,
                      'themes': eventThemes[eventCategory],
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
