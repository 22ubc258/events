import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEventScreen extends StatefulWidget {
  @override
  _AdminEventScreenState createState() => _AdminEventScreenState();
}

class _AdminEventScreenState extends State<AdminEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Map<String, String>> _dynamicFields = [];

  void _addDynamicField() {
    setState(() {
      _dynamicFields.add({'label': '', 'value': ''});
    });
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final eventData = {
        'category': _categoryController.text,
        'description': _descriptionController.text,
        'dynamicFields': _dynamicFields,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('events').add(eventData);
      _categoryController.clear();
      _descriptionController.clear();
      _dynamicFields.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event added successfully!')));
      Navigator.of(context).pop();
    }
  }

  void _showEventForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(labelText: 'Category'),
                        validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                      ),
                      SizedBox(height: 16),
                      ..._dynamicFields.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'Label'),
                                onChanged: (value) {
                                  setModalState(() {
                                    _dynamicFields[index]['label'] = value;
                                  });
                                },
                                validator: (value) => value!.isEmpty ? 'Please enter a label' : null,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'Value'),
                                onChanged: (value) {
                                  setModalState(() {
                                    _dynamicFields[index]['value'] = value;
                                  });
                                },
                                validator: (value) => value!.isEmpty ? 'Please enter a value' : null,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setModalState(() {
                                  _dynamicFields.removeAt(index);
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setModalState(() {
                            _dynamicFields.add({'label': '', 'value': ''});
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveEvent,
                        child: Text('Save Event'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Event Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found.'));
          }
          final events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final category = event['category'] as String;
              final description = event['description'] as String;
              final dynamicFields = (event['dynamicFields'] as List<dynamic>)
                  .map((field) => Map<String, String>.from(field))
                  .toList();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    category,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    description,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(
                          category: category,
                          description: description,
                          dynamicFields: dynamicFields,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEventForm,
        child: Icon(Icons.add),
      ),
    );
  }
}



class EventDetailsScreen extends StatelessWidget {
  final String category;
  final String description;
  final List<Map<String, String>> dynamicFields;

  EventDetailsScreen({
    required this.category,
    required this.description,
    required this.dynamicFields,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Dynamic Fields:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ...dynamicFields.map((field) {
              final label = field['label'] ?? '';
              final value = field['value'] ?? '';

              // Check if the label is 'image' to display the image
              if (label.toLowerCase() == 'image' && value.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label:',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // Optional: for rounded corners
                      child: Container(
                        width: 150, // Set the width for the image
                        height: 150, // Set the height for the image
                        child: Image.network(
                          value,
                          fit: BoxFit.cover, // Ensures the image covers the entire container
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text('Failed to load image'),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$label: $value',
                    style: TextStyle(fontSize: 16.0),
                  ),
                );
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}