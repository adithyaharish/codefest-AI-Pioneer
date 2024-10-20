import 'package:flutter/material.dart';
import 'package:marriotbuddy_application/Screens/Buddy.dart';
import 'package:marriotbuddy_application/Screens/ChatPage.dart';
import 'package:marriotbuddy_application/Screens/MatchDetails.dart';
import 'package:marriotbuddy_application/Screens/PersonalInfo.dart';
import 'package:marriotbuddy_application/Screens/ProfilePage.dart';

// Import the match detail screen


class LandingPage extends StatefulWidget {

  
  final Map<String, dynamic>? matchData; // Make matches optional

  LandingPage({this.matchData});
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _hasPreferences = false; // Simulate whether the user has preferences or not
  int _currentIndex = 0;
  late PageController _pageController; // Controller for PageView

  TextEditingController _codeController = TextEditingController(); // Controller for the 4-digit code

  final List<Map<String, dynamic>> _matches = [
    {
      'image': 'assets/W4.jpg',
      'name': 'Keely Joshh',
      'characteristics': ['Female', 'Software', 'Loves Badminton'],
      'gender': 'Female',
      'lgbtq': "true",
      'disability': "false"
    },
    {
      'image': 'assets/W5.jpg',
      'name': 'Keely Joshh',
      'characteristics': ['Female', 'Software', 'Loves Badminton'],
      'gender': 'Female',
      'lgbtq': "true",
      'disability': "false"
    },
    {
      'image': 'assets/W1.jpg',
      'name': 'Keely Joshh',
      'characteristics': ['Female', 'Software', 'Loves Badminton'],
      'gender': 'Female',
      'lgbtq': "true",
      'disability': "false"
    },
    {
      'image': 'assets/W2.jpg',
      'name': 'Jonnie Adagaskar',
      'characteristics': ['Female', 'Product Manager at Facebook', 'Avid Reader'],
      'gender': 'Female',
      'lgbtq': "true",
      'disability': "false"
    },
    {
      'image': 'assets/W3.jpg',
      'name': 'Sarah',
      'characteristics': ['Female', 'Data Scientist at Amazon', 'Enjoys Hiking'],
        'gender': 'Female',
      'lgbtq': "true",
      'disability': "false"
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize PageController
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose PageController
    _codeController.dispose(); // Dispose TextEditingController
    super.dispose();
  }

  void _onBottomNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index); // Navigate to selected page
  }

  // Show Authorization Dialog before navigating to BuddyScreen
  void _showAuthorizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your Authorization code'),
          content: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 4, // Limiting to 4 digits
            decoration: InputDecoration(
              hintText: 'Enter 4-digit code',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String enteredCode = _codeController.text;

                if (enteredCode == '1234') {
                  Navigator.of(context).pop(); // Close dialog
                  // Proceed to the BuddyScreen if authorized
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BuddyScreen()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Authorized'),backgroundColor: Colors.white,
                    ), 
                  );
                  setState(() {
                    _hasPreferences = true;
                  });
                } else {
                  // Show an error message if code is incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect code. Try again.'),
                    ),
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100, // Make the AppBar bigger
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to left
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                'assets/Ask.png', // Replace with your Marriott image icon path
              ),
            ),
            SizedBox(width: 10),
            const Text(
              'Marriott Buddy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30, // Increase the font size for the title
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe to change pages
        children: [
          _hasPreferences ? _buildSlidingMatches() : _buildAddPreferences(), // Home screen (Landing)
          ChatListScreen(), // Chat screen
          ProfilePage(), // Profile screen
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSlidingMatches() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Your Next Adventure Starts Here!!",
          style: TextStyle(color: Color(0xFFFFA500), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 50),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.48, // Adjust height as needed
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.8), // Show part of previous and next items
            scrollDirection: Axis.horizontal, // Enables horizontal sliding
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to MatchDetailScreen when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchDetailScreen(
                        name: _matches[index]['name'],
                        image: _matches[index]['image'],
                        characteristics: _matches[index]['characteristics'],
                        gender: _matches[index]['gender'],
                        isLgbtq: _matches[index]['lgbtq'],
                        hasDisability: _matches[index]['disability'],
                        linkedIn: _matches[index]['linkedIn'],
                        
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.grey[900], // Background color for the card
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image section
                          Image.asset(
                            _matches[index]['image'],
                            height: MediaQuery.of(context).size.height * 0.25, // Adjust as needed
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),

                          // Name section
                          Text(
                            _matches[index]['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Characteristics in row form using Wrap
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Wrap(
                              spacing: 6.0, // Space between each "button"
                              runSpacing: 5.0, // Space between rows if wrapped
                              children: _matches[index]['characteristics'].map<Widget>((characteristic) {
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.orange, width: 1.5),
                                  ),
                                  child: Text(
                                    characteristic,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // Action to update preferences
          },
          child: Text(
            'Update Preferences',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPreferences() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tagline text in orange
            const Text(
              "Your Next Adventure Starts Here! Add your preferences to match with fellow explorers.",
              style: TextStyle(
                color: Color(0xFFFFA500),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50), // Space between tagline and image

            // Image with circular edges
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0), // Rounded edges with radius 20
              child: Image.asset(
               
                'assets/DummImage.png', // Replace with a suitable dummy image path
                width: MediaQuery.of(context).size.width * 0.60, // Adjust width as needed
                height: MediaQuery.of(context).size.height * 0.30, // Adjust height as needed
                fit: BoxFit.cover, // Ensure the image fits within the rounded rectangle
              ),
            ),
            SizedBox(height: 20), // Space between image and button

            // Add Preferences button with authorization
            ElevatedButton(
              onPressed: () {
                _showAuthorizationDialog(context); // Show the authorization dialog
              },
              child: Text(
                'Add Preferences',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Color(0xFFFFA500),
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: _onBottomNavBarTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

