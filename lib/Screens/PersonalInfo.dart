import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image picker package
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marriotbuddy_application/Screens/landingPage.dart';
import 'package:marriotbuddy_application/utlis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  // Form key and controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  bool _isLoading = false;

  // Variables for image picking
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Dropdown values
  String _gender = '';
  String _lgbtq = '';
  String _disability = '';

  @override
  void dispose() {
    // Dispose controller when not in use
    _dobController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Retrieve token
  }

  // Function to pick an image from the gallery or take a photo
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to make the API call on form submission
  Future<void> _submitPersonalInfo() async {
    String? token = await _getToken();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final url = Uri.parse('${BASE_URL}/api/personal_info');

      final body = json.encode({
        'date_of_birth': _dobController.text,
        'gender': _gender,
        'lgbtq': _lgbtq,
        'disability': _disability,
        // You can also send image data if needed in the API
        'profile_image': _selectedImage != null ? base64Encode(_selectedImage!.readAsBytesSync()) : null,
      });

      print(body);

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'insomnia/10.1.0',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          // If the API call is successful, navigate to the next page (LandingPage)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LandingPage()),
          );
        } else {
          print('Failed to submit personal info: ${response.body}');
        }
      } catch (e) {
        print('Error submitting personal info: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo/Icon at the top
                Center(
                  child: Image.asset(
                    'assets/Ask.png', // Replace with your logo icon image path
                    width: 80, // Adjust size as needed
                    height: 80,
                  ),
                ),
                SizedBox(height: 20),

                // Personal Info title
                Center(
                  child: Text(
                    'Personal Info',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFA500), // Orange color for text
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Image Upload Section
                Center(
                  child: Column(
                    children: [
                      _selectedImage != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(_selectedImage!),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[800],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: Icon(Icons.camera, color: Colors.white,),
                            label: Text('Take Photo',style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFA500),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: Icon(Icons.photo, color: Colors.white,),
                            label: Text('Upload Photo',style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFA500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Date of Birth field with Date Picker
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.white), // Calendar icon
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode()); // Prevents the keyboard from showing
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      String formattedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      setState(() {
                        _dobController.text = formattedDate; // Set the selected date in the text field
                      });
                    }
                  },
                ),
                SizedBox(height: 20),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _gender.isNotEmpty ? _gender : null,
                  items: ['Male', 'Female', 'Non-Binary']
                      .map((gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender, style: TextStyle(color: Colors.white)), // White text in dropdown options
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  dropdownColor: Colors.grey[900], // Light black dropdown background
                  style: TextStyle(color: Colors.white), // White text for selected value
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                  iconEnabledColor: Colors.white, // Dropdown arrow color
                ),
                SizedBox(height: 20),

                // LGBTQ+ Dropdown
                DropdownButtonFormField<String>(
                  value: _lgbtq.isNotEmpty ? _lgbtq : null,
                  items: ['Yes', 'No']
                      .map((lgbtq) => DropdownMenuItem<String>(
                            value: lgbtq,
                            child: Text(lgbtq, style: TextStyle(color: Colors.white)), // White text in dropdown options
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Do you belong to LGBTQ+?',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  dropdownColor: Colors.grey[900], // Light black dropdown background
                  style: TextStyle(color: Colors.white), // White text for selected value
                  onChanged: (value) {
                    setState(() {
                      _lgbtq = value!;
                    });
                  },
                  iconEnabledColor: Colors.white, // Dropdown arrow color
                ),
                SizedBox(height: 20),

                // Disability Dropdown
                DropdownButtonFormField<String>(
                  value: _disability.isNotEmpty ? _disability : null,
                  items: ['Yes', 'No', 'Do not want to answer']
                      .map((disability) => DropdownMenuItem<String>(
                            value: disability,
                            child: Text(disability, style: TextStyle(color: Colors.white)), // White text in dropdown options
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Do you have a disability?',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  dropdownColor: Colors.grey[900], // Light black dropdown background
                  style: TextStyle(color: Colors.white), // White text for selected value
                  onChanged: (value) {
                    setState(() {
                      _disability = value!;
                    });
                  },
                  iconEnabledColor: Colors.white, // Dropdown arrow color
                ),
                SizedBox(height: 40), // Space for form submission or further fields

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPersonalInfo, // Trigger the API call on submit
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFA500), // Orange button color
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Submit', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
