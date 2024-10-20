import 'package:flutter/material.dart';

class MatchDetailScreen extends StatelessWidget {
  final String name;
  final String image;
  final List<String> characteristics;
  final String hasDisability;
  final String isLgbtq;
  final String gender;
  final String linkedIn;

  MatchDetailScreen({
    required this.name,
    required this.image,
    required this.characteristics,
    required this.hasDisability,
    required this.isLgbtq,
    required this.gender,
    required this.linkedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: TextStyle(
            color: Color(0xFFFFA500),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context); // Navigate back when the back button is pressed
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Profile Image with Circular Border
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    image,
                    height: 260, // Profile image size
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Name and Basic Info Card
              Card(
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileInfoRow(Icons.person, 'Name', name),
                      _buildProfileInfoRow(Icons.male, 'Gender', gender),
                      _buildProfileInfoRow(Icons.favorite, 'LGBTQ+', isLgbtq),
                      _buildProfileInfoRow(Icons.accessibility_new, 'Disability', hasDisability),
                      _buildProfileInfoRow(Icons.link, 'LinkedIn URL', linkedIn),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Characteristics Section with Icon
              Text(
                'Characteristics',
                style: TextStyle(
                  color: Color(0xFFFFA500),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ...characteristics.map((char) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    SizedBox(width: 10),
                    Text(
                      char,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )),

              // Button Section for Interaction
              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality like starting a chat or sending a request
                  },
                  icon: Icon(Icons.chat, color: Colors.black),
                  label: Text(
                    'Start Chat',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFA500), // Button color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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

  // Helper function to build profile info rows with icons
  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFFA500), size: 24),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              color: Color(0xFFFFA500),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
