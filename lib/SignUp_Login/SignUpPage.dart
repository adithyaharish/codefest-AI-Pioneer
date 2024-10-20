import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marriotbuddy_application/Screens/PersonalInfo.dart';
import 'dart:convert';

import 'package:marriotbuddy_application/Screens/landingPage.dart';
import 'package:marriotbuddy_application/SignUp_Login/LoginPage.dart';
import 'package:marriotbuddy_application/utlis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Toggles password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Toggles confirm password visibility
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }
  Future<void> _validateAndSignup() async {
    if (_formKey.currentState!.validate()) {
      final response = await _signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
      print(response?.statusCode);
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        print('Signup Successful');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PersonalInfoPage()),
        );
      } else {
        print('Signup Failed: ${response?.body}');
      }
    }
  }

  // Signup API Call
  Future<http.Response?> _signup(String fullName, String email, String password, String confirmPassword) async {
    final url = Uri.parse('${BASE_URL}/api/signup');

    final body = json.encode({
      'full_name': fullName,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'insomnia/8.4.5',
        },
        body: body,
      );
      print(response);
      return response;
    } catch (e) {
      print('Error during signup: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/LOGOLogin.jpg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 50,
                    offset: Offset(0, -20),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Password Field with eye toggle
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              } else if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),

                          // Signup Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: 
                                _validateAndSignup,
      //                           Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => LandingPage()),
      // );},
                             // _validateAndSignup, // Trigger signup on arrow button press
                               style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFFA500), // Orange color
                                  padding: const EdgeInsets.all(20), // Adjust padding as needed
                                  shape: const CircleBorder(), // Circular button shape
                                  elevation: 5, // Optional, adjust if needed
                                ),
                                child: const Icon(Icons.arrow_forward, color: Colors.white),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          
                          // Go back to Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                  );
                                },
                                child: const Text(
                                  'Go back to Login',
                                   style: TextStyle(color: Color(0xFFFFA500),fontWeight: FontWeight.bold,fontSize: 16), 
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
