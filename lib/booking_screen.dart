import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final String eventCategory;
  final List<Map<String, String>> themes;

  BookingScreen({required this.eventCategory, required this.themes});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for user input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _numSeatsController = TextEditingController();
  final TextEditingController _customThemeController = TextEditingController();

  // For Wedding Combo: Store multiple selected themes
  List<String> _selectedComboThemes = [];

  // For Wedding: Store single selected theme
  String _selectedWeddingTheme = '';

  // Venue, Catering, and Serving selection
  String _selectedVenueType = 'Indoor'; // Default
  String _selectedCateringType = 'Veg'; // Default
  String _selectedServingType = 'Buffet'; // Default

  // Controllers for Date and Time fields
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      // Save the form data
      _formKey.currentState!.save();

      try {
        // Determine the theme value based on event category and user selection
        String? theme;
        if (widget.eventCategory == 'Wedding Combo') {
          theme = _selectedComboThemes.isNotEmpty ? _selectedComboThemes.join(', ') : null;
        } else if (widget.eventCategory == 'Weddings') {
          theme = _selectedWeddingTheme.isNotEmpty ? _selectedWeddingTheme : null;
        } else {
          theme = null; // Default for other event categories
        }

        // Check if a custom theme is entered
        String? customTheme = _customThemeController.text.isNotEmpty ? _customThemeController.text : null;

        // Save data to Firebase
        await FirebaseFirestore.instance.collection('bookings').add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'eventCategory': widget.eventCategory,
          'eventDate': _eventDateController.text,
          'eventTime': _eventTimeController.text,
          'eventLocation': _eventLocationController.text,
          'numSeats': _numSeatsController.text,
          'theme': theme, // Save selected theme
          'customTheme': customTheme, // Save custom theme separately
          'venueType': _selectedVenueType,
          'cateringType': _selectedCateringType,
          'servingType': _selectedServingType,
          'timestamp': FieldValue.serverTimestamp(),
          'user': FirebaseAuth.instance.currentUser!.uid,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking successful!")),
        );

        // Navigate back to the previous screen
        Navigator.pop(context);
      } catch (e) {
        // Show error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save booking: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book Event - ${widget.eventCategory}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Section: Customer Details
              _buildSectionTitle("Customer Details"),
              _buildTextField("Full Name", _nameController, "Enter your name"),
              _buildTextField("Phone Number", _phoneController, "Enter phone number", inputType: TextInputType.phone),
              _buildTextField("Email", _emailController, "Enter email", inputType: TextInputType.emailAddress),

              SizedBox(height: 20),

              // Section: Event Details
              _buildSectionTitle("Event Details"),
              _buildDateField("Event Date", _eventDateController),
              _buildTimeField("Event Time", _eventTimeController),
              _buildTextField("Event Location", _eventLocationController, "Enter event location"),
              _buildTextField("Number of Seats", _numSeatsController, "Enter number of seats", inputType: TextInputType.number),

              // Venue Type Radio Buttons
              _buildSectionTitle("Venue Type"),
              _buildRadioButtons(
                title: "Venue Type",
                groupValue: _selectedVenueType,
                onChanged: (value) {
                  setState(() {
                    _selectedVenueType = value!;
                  });
                },
                values: ['Indoor', 'Outdoor'],
              ),

              // Catering Type Radio Buttons
              _buildSectionTitle("Catering Type"),
              _buildRadioButtons(
                title: "Catering Type",
                groupValue: _selectedCateringType,
                onChanged: (value) {
                  setState(() {
                    _selectedCateringType = value!;
                  });
                },
                values: ['Veg', 'Non-Veg', 'Both'],
              ),

              // Serving Type Radio Buttons (Buffet, Serving, Both)
              _buildSectionTitle("Serving Type"),
              _buildRadioButtons(
                title: "Serving Type",
                groupValue: _selectedServingType,
                onChanged: (value) {
                  setState(() {
                    _selectedServingType = value!;
                  });
                },
                values: ['Buffet', 'Serving', 'Both'],
              ),

              SizedBox(height: 20),

              // Section: Theme Selection (Conditional Rendering)
              if (widget.eventCategory == 'Weddings' || widget.eventCategory == 'Wedding Combo')
                _buildSectionTitle("Theme Selection"),

              if (widget.eventCategory == 'Wedding Combo')
                _buildComboThemeCards() // For Wedding Combo: Multiple selection
              else if (widget.eventCategory == 'Weddings')
                _buildWeddingThemeCards() // For Weddings: Single selection
              else
                _buildImageGallery(), // For Baptism, Birthday Parties, and First Holy Communion

              // Custom Theme Text Box (Always Displayed)
             _buildTextField("Custom Theme (Optional)", _customThemeController, "", isRequired: false),


              SizedBox(height: 20),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text("Book Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  // Text Field
  Widget _buildTextField(
  String label,
  TextEditingController controller,
  String validationMessage, {
  TextInputType inputType = TextInputType.text,
  bool isRequired = true, // Add this parameter
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      keyboardType: inputType,
      validator: (value) {
        if (isRequired && value!.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    ),
  );
}


  // Date Picker Field
  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format: YYYY-MM-DD
            });
          }
        },
      ),
    );
  }

  // Time Picker Field
  Widget _buildTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        readOnly: true,
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              controller.text = pickedTime.format(context); // Format: HH:MM AM/PM
            });
          }
        },
      ),
    );
  }

  // Build Wedding Theme Cards (Single Selection)
  Widget _buildWeddingThemeCards() {
    return Column(
      children: widget.themes.map((theme) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedWeddingTheme = theme['title']!;
            });
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: _selectedWeddingTheme == theme['title'] ? Colors.blue : Colors.grey,
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      theme['image']!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme['title']!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          theme['description']!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Build Combo Theme Cards (Multiple Selection)
  Widget _buildComboThemeCards() {
    return Column(
      children: widget.themes.map((theme) {
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedComboThemes.contains(theme['title'])) {
                _selectedComboThemes.remove(theme['title']);
              } else {
                _selectedComboThemes.add(theme['title']!);
              }
            });
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: _selectedComboThemes.contains(theme['title']) ? Colors.blue : Colors.grey,
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      theme['image']!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme['title']!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          theme['description']!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedComboThemes.contains(theme['title']))
                    Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Build Image Gallery for Baptism, Birthday Parties, and First Holy Communion
  Widget _buildImageGallery() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.themes.map((theme) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                theme['image']!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Build Radio Buttons for Venue, Catering, and Serving Types
  Widget _buildRadioButtons({
    required String title,
    required String groupValue,
    required Function(String?) onChanged,
    required List<String> values,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...values.map((value) {
          return Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
              ),
              Text(value),
            ],
          );
        }).toList(),
      ],
    );
  }
}
