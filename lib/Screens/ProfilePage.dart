import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marriotbuddy_application/utlis.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variables to store profile data
  String? fullName;
  String? email;
  String? dateOfBirth;
  String? gender;
  String? disability;
  String? password; // Avoid displaying the password in plaintext in a real app
  String? profileImageBase64;

  // Variables to store reservation details
  List<Map<String, dynamic>> reservations = [];

  // Function to get the token and fetch the profile info from the API
  Future<void> _fetchProfileData() async {
    final url = Uri.parse('${BASE_URL}/api/users');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          fullName = data['full_name'];
          email = data['email'];
          dateOfBirth = data['date_of_birth'];
          gender = data['gender'];
          disability = data['disability'];
          profileImageBase64 = data['profile_image'];
        });
      } else {
        print('Failed to fetch profile info: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile info: $e');
    }
  }

  // Function to fetch reservation details from the API
  Future<void> _fetchReservationData() async {
    final url = Uri.parse('${BASE_URL}/api/reservations');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reservations = List<Map<String, dynamic>>.from(data); // Assuming data is a list of reservations
        });
      } else {
        print('Failed to fetch reservation details: ${response.body}');
      }
    } catch (e) {
      print('Error fetching reservation details: $e');
    }
  }

  // Helper method to decode base64 image string into bytes
  Uint8List _decodeBase64Image(String base64String) {
    return base64Decode(base64String.split(',').last); // Ensure proper base64 decoding
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); // Fetch profile data on page load
    _fetchReservationData(); // Fetch reservation data on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFFFFA500), // Set text color to orange
            fontSize: 25, // Adjust font size if necessary
            fontWeight: FontWeight.bold, // Optionally make the text bold
          ),
        ),
        centerTitle: true, // Center the title
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: Colors.black, // No different background, black color
      ),
      backgroundColor: Colors.black,
      body: fullName == null
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image and Basic Details in Card
                    _buildProfileCard(),
                    SizedBox(height: 40),

                    // Reservation Section
                    _buildReservationSection(),

                    // Log Out Button
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // Build Profile Card with image and basic details
  Widget _buildProfileCard() {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (profileImageBase64 != null)
              CircleAvatar(
                radius: 150,
                backgroundImage: MemoryImage(_decodeBase64Image(profileImageBase64!)), // Load image from base64 string
              ),
            SizedBox(height: 20),
            _buildProfileItem('Name', fullName, Icons.person),
            _buildProfileItem('Email', email, Icons.email),
            _buildProfileItem('Date of Birth', dateOfBirth, Icons.cake),
            _buildProfileItem('Gender', gender, Icons.male),
            _buildProfileItem('Disability', disability, Icons.accessibility),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile items with icons
  Widget _buildProfileItem(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFFA500), size: 28),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: ${value ?? ''}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Reservation Section
  Widget _buildReservationSection() {
    if (reservations.isEmpty) {
      return Container(); // Return empty container if no reservations
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservation Details',
          style: TextStyle(
            color: Color(0xFFFFA500),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ...reservations.map((reservation) {
          return _buildReservationItem(reservation);
        }).toList(),
      ],
    );
  }

  // Helper method to build each reservation item
  Widget _buildReservationItem(Map<String, dynamic> reservation) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hotel: ${reservation['hotel_name'] ?? ''}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              'Date: ${reservation['reservation_date'] ?? ''}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Status: ${reservation['status'] ?? ''}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Build Log Out Button
  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Log out functionality or any other action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFA500), // Orange button color
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text('Log Out'),
      ),
    );
  }
}
