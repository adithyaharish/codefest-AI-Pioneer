import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marriotbuddy_application/Screens/landingPage.dart';
import 'package:marriotbuddy_application/Screens/landingPage2.dart';
import 'package:marriotbuddy_application/utlis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuddyScreen extends StatefulWidget {
  @override
  _BuddyScreenState createState() => _BuddyScreenState();
}

class _BuddyScreenState extends State<BuddyScreen> {
  bool sameGender = false;
  bool noGenderPreference = false;
  bool smoking = false;
  bool drinking = false;
  bool agePreference = false;
  String selectedAgeRange = '';
  String roomShareSpecialRequests = '';

  List<String> mealPreferences = [];
  List<String> dietaryRestrictions = [];
  List<String> recreationalActivities = [];
  List<String> socialActivities = [];
  List<String> selectedProfessionalInterests = [];
  String companyName = '';
  String jobTitle = '';
  String linkedIn = '';
  List<String> outsideExperiences = [];
  bool groupActivities = false;
  String itineraryFlexibility = '';
  List<String> transportationOptions = [];
  bool shareTransportation = false;
  bool personalizedRecommendations = false;
  List<String> recommendationTypes = [];

  List<String> mealOptions = ['Casual dining', 'Fine dining', 'Food tours', 'Group meals', 'Solo dining'];
  List<String> dietaryOptions = ['Vegetarian', 'Vegan', 'Gluten-free', 'Kosher', 'Halal', 'None', 'Other'];
  List<String> recreationalOptions = ['Gym workouts', 'Swimming', 'Games', 'Yoga', 'Sports', 'Adventure sports', 'Walking tours'];
  List<String> socialOptions = ['Casual meetups', 'Professional networking events', 'Group activities', 'Local cultural events', 'Volunteering or charity work', 'Other'];
  List<String> professionalInterestsOptions = ['Technology and Coding', 'Marketing and Business', 'Finance and Investments', 'Design and Creativity', 'Healthcare and Medicine', 'Education and Learning'];
  bool agreeToShare = false;
    List<Map<String, dynamic>> matches = [];
     bool isLoading = true;

  // Fetch matches from API

Future<Map<String, dynamic>> fetchMatches() async {
  final url = Uri.parse('${BASE_URL}/api/matches');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the entire matches data as a Map<String, dynamic>
      final Map<String, dynamic> matchData = json.decode(response.body);
      print('matchdata is :${matchData}');
      return matchData; // Return the entire match data
    } else {
      throw Exception('Failed to load matches');
    }
  } catch (e) {
    print('Error fetching matches: $e');
    return {}; // Return an empty map if there's an error
  }
}


  // Function to extract characteristics from common_features
  List<String> _getCharacteristics(Map<String, dynamic> features) {
    List<String> characteristics = [];

    features.forEach((key, value) {
      characteristics.add(value.toString());
    });

    return characteristics;
  }


   Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Retrieve token
  }
  Future<void> _submitRoomSharingData() async {
  // Construct request body
  //  String? token = await _getToken(); 
  final requestBody = {
    "drinking": drinking.toString(), // Converts to "true" or "false"
    "smoking": smoking.toString(),   // Converts to "true" or "false"
    "special_request": roomShareSpecialRequests.isEmpty ? "None" : roomShareSpecialRequests,
    "age_preference": agePreference.toString(), // Converts to "true" or "false"
    "age_category": agePreference ? selectedAgeRange : "None",
    "gender_preference": sameGender
        ? "Same gender only"
        : noGenderPreference
            ? "No gender preference"
            : "None",
  };

  print('Request Body: $requestBody');

  // Call the API with the constructed request body
  final url = Uri.parse('${BASE_URL}/api/room_sharing'); // Replace with your actual URL
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $token", // Replace $token with the actual token
    },
    body: json.encode(requestBody),
  );

  if (response.statusCode == 200) {
    print('Room sharing data submitted successfully');
  } else {
    print('Failed to submit room sharing data: ${response.statusCode}, ${response.body}');
  }
}

Future<void> _submitMealBuddyData() async {
  // String? token = await _getToken();
  // Construct request body for the Meal Buddy Preferences
  final requestBody = {
    "dietary_preference": dietaryRestrictions.isNotEmpty ? dietaryRestrictions.join(", ") : "None",
    "dining_type": mealPreferences.isNotEmpty ? mealPreferences.join(", ") : "None",
  };

  print('Request Body: $requestBody');

  // Call the API with the constructed request body
  final url = Uri.parse('${BASE_URL}/api/mealbuddy'); // Replace with your actual URL
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $token", // Replace $token with the actual token
    },
    body: json.encode(requestBody),
  );

  if (response.statusCode == 200) {
    print('Meal Buddy data submitted successfully');
  } else {
    print('Failed to submit meal buddy data: ${response.statusCode}, ${response.body}');
  }
}

Future<void> _submitNetworkingData() async {
    // String? token = await _getToken();
  // Construct request body for Networking Information
  final requestBody = {
    "company": companyName.isNotEmpty ? companyName : "None", // Default to "None" if not provided
    "linkedin": linkedIn.isNotEmpty ? linkedIn : "None", // Default to "None" if not provided
    "professional_interest": selectedProfessionalInterests.isNotEmpty 
        ? selectedProfessionalInterests.join(", ") 
        : "None", // Joining professional interests
    "role": jobTitle.isNotEmpty ? jobTitle : "None", // Default to "None" if not provided
  };

  print('Request Body: $requestBody');

  // Call the API with the constructed request body
  final url = Uri.parse('${BASE_URL}/api/networking'); // Replace with your actual URL
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $token", // Replace $token with the actual token
    },
    body: json.encode(requestBody),
  );

  if (response.statusCode == 200) {
    print('Networking data submitted successfully');
  } else {
    print('Failed to submit networking data: ${response.statusCode}, ${response.body}');
  }
}


Future<void> _submitRecreationalData() async {
  // String? token = await _getToken();  // Get the saved token

  // Construct request body for Recreational Buddy Preferences
  final requestBody = {
    "activity_options": recreationalActivities.isNotEmpty ? recreationalActivities.join(", ") : "None",
    "social_activity": socialActivities.isNotEmpty ? socialActivities.join(", ") : "None",
    "outside_hotel": outsideExperiences.isNotEmpty ? outsideExperiences.join(", ") : "None",
    "group_activity": groupActivities ? "Yes" : "No",
    "flexibility": itineraryFlexibility.isNotEmpty ? itineraryFlexibility : "None",
    "transportation": transportationOptions.isNotEmpty ? transportationOptions.join(", ") : "None",
    "share_transport": shareTransportation ? "Yes" : "No",
    "recommendation": personalizedRecommendations ? "Yes" : "No",
    "kind_of_recommendation": recommendationTypes.isNotEmpty ? recommendationTypes.join(", ") : "None"
  };

  print('Request Body: $requestBody');

  // Call the API with the constructed request body
  final url = Uri.parse('${BASE_URL}/api/recreational');  // Replace with your actual URL
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      // "Authorization": "Bearer $token",  // Replace $token with the actual token
    },
    body: json.encode(requestBody),
  );

  if (response.statusCode == 200) {
    print('Recreational data submitted successfully');
  } else {
    print('Failed to submit recreational data: ${response.statusCode}, ${response.body}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Buddy Matching',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Find Your Perfect Travel Buddy!',
                style: TextStyle(
                  color: Color(0xFFFFA500),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildBuddySection('Room Share Buddy', _buildRoomShareBuddyContent()),
            SizedBox(height: 20),
            _buildBuddySection('Food Buddy', _buildFoodBuddyContent()),
            SizedBox(height: 20),
            _buildBuddySection('Recreational Buddy', _buildRecreationalBuddyContent()),
            SizedBox(height: 20),
            _buildBuddySection('Networking Buddy', _buildNetworkingBuddyContent()),
            SizedBox(height: 40),

                        // Checkbox for agreeing to share preferences
            CheckboxListTile(
              value: agreeToShare,
              title: Text(
                'I agree to share my preferences and basic information with other travelers for buddy matching',
                style: TextStyle(color: Colors.white),
              ),
              
              onChanged: (bool? value) {
                setState(() {
                  agreeToShare = value ?? false; // Update the checkbox state
                });
              },
              activeColor: Colors.orange,
              checkColor: Colors.black,
            ),SizedBox(height: 30,),
            Center(
              child: ElevatedButton(
                onPressed: agreeToShare ? _submitForm : null, // Disable button if not agreed
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA500),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Submit', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuddySection(String title, Widget content) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        collapsedIconColor: Colors.orange,
        iconColor: Colors.orange,
        children: [Padding(padding: EdgeInsets.all(16), child: content)],
      ),
    );
  }

  // Room Share Buddy Content
  Widget _buildRoomShareBuddyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🛌 Room Sharing Preferences'),
        _buildNumberedText('1) What are your preferences for room sharing?'),
        _buildCheckboxOption('Same gender only', sameGender, (value) {
          setState(() {
            sameGender = value!;
          });
        }),
        _buildCheckboxOption('No gender preference', noGenderPreference, (value) {
          setState(() {
            noGenderPreference = value!;
          });
        }),
        SizedBox(height: 10),
        _buildNumberedText('2) Age preference (please specify):'),
        _buildYesNoOption('Age Preference', agePreference, (value) {
          setState(() {
            agePreference = value!;
            selectedAgeRange = '';
          });
        }),
        if (agePreference) _buildAgeRangeOptions(),
        SizedBox(height: 10),
        _buildNumberedText('3) Smoking'),
        _buildYesNoOption('Smoking', smoking, (value) {
          setState(() {
            smoking = value!;
          });
        }),
        _buildNumberedText('4) Drinking'),
        _buildYesNoOption('Drinking', drinking, (value) {
          setState(() {
            drinking = value!;
          });
        }),
        _buildNumberedText('5) Any special requests for room sharing?'),
        _buildTextField('Please share your requests', roomShareSpecialRequests, (value) {
          setState(() {
            roomShareSpecialRequests = value;
          });
        }),
      ],
    );
  }

  // Food Buddy Content
  Widget _buildFoodBuddyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🍽 Meal Preferences'),
        _buildNumberedText('1) What type of dining experiences are you interested in?'),
        ...mealOptions.map((option) {
          return CheckboxListTile(
            title: Text(option, style: TextStyle(color: Colors.white)),
            value: mealPreferences.contains(option),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  mealPreferences.add(option);
                } else {
                  mealPreferences.remove(option);
                }
              });
            },
            activeColor: Colors.orange,
          );
        }).toList(),
        SizedBox(height: 10),
        _buildNumberedText('2) Do you have any dietary restrictions or preferences?'),
        ...dietaryOptions.map((option) {
          return CheckboxListTile(
            title: Text(option, style: TextStyle(color: Colors.white)),
            value: dietaryRestrictions.contains(option),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  dietaryRestrictions.add(option);
                } else {
                  dietaryRestrictions.remove(option);
                }
              });
            },
            activeColor: Colors.orange,
          );
        }).toList(),
      ],
    );
  }
// Helper method to build Radio options
Widget _buildRadioOption(String title, List<String> options, String groupValue, Function(String) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: options.map((option) {
      return ListTile(
        title: Text(option, style: TextStyle(color: Colors.white)),
        leading: Radio<String>(
          value: option,
          groupValue: groupValue,
          onChanged: (value) {
            onChanged(value!);
          },
          activeColor: Colors.orange,
        ),
      );
    }).toList(),
  );
}


Widget _buildRecreationalBuddyContent() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionTitle('🎉 Recreational Activities'),
      
      _buildNumberedText('1) What recreational activities are you interested in during your stay?'),
      ...recreationalOptions.map((option) {
        return CheckboxListTile(
          title: Text(option, style: TextStyle(color: Colors.white)),
          value: recreationalActivities.contains(option),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                recreationalActivities.add(option);
              } else {
                recreationalActivities.remove(option);
              }
            });
          },
          activeColor: Colors.orange,
        );
      }).toList(),
      
      _buildNumberedText('2) What kind of social activities would you like to join?'),
      ...socialOptions.map((option) {
        return CheckboxListTile(
          title: Text(option, style: TextStyle(color: Colors.white)),
          value: socialActivities.contains(option),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                socialActivities.add(option);
              } else {
                socialActivities.remove(option);
              }
            });
          },
          activeColor: Colors.orange,
        );
      }).toList(),

      _buildNumberedText('3) What experiences would you like outside the hotel? (Check all that apply)'),
      ...['Local cultural experiences (e.g., museums, art galleries)', 'Adventure activities (e.g., hiking, biking)', 'City tours', 'Shopping trips', 'Nightlife (bars, clubs)', 'Beach or outdoor activities', 'Day trips to nearby attractions']
          .map((option) {
        return CheckboxListTile(
          title: Text(option, style: TextStyle(color: Colors.white)),
          value: outsideExperiences.contains(option),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                outsideExperiences.add(option);
              } else {
                outsideExperiences.remove(option);
              }
            });
          },
          activeColor: Colors.orange,
        );
      }).toList(),

      _buildNumberedText('4) Would you like to plan group activities with fellow travelers?'),
      _buildYesNoOption('Group Activities', groupActivities, (value) {
        setState(() {
          groupActivities = value!;
        });
      }),

      _buildNumberedText('5) How much flexibility do you prefer in your trip itinerary?'),
      _buildRadioOption('Itinerary Flexibility', ['Fully planned and scheduled', 'Mostly planned with some flexibility', 'Completely flexible'], itineraryFlexibility, (newValue) {
        setState(() {
          itineraryFlexibility = newValue;
        });
      }),

      _buildNumberedText('6) What type of transportation will you use during your stay? (Check all that apply)'),
      ...['Rental car', 'Taxi or ride-share', 'Public transportation', 'Hotel shuttle', 'Biking or walking'].map((option) {
        return CheckboxListTile(
          title: Text(option, style: TextStyle(color: Colors.white)),
          value: transportationOptions.contains(option),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                transportationOptions.add(option);
              } else {
                transportationOptions.remove(option);
              }
            });
          },
          activeColor: Colors.orange,
        );
      }).toList(),

      _buildNumberedText('7) Would you like to share transportation with other travelers?'),
      _buildYesNoOption('Share Transportation', shareTransportation, (value) {
        setState(() {
          shareTransportation = value!;
        });
      }),

      _buildNumberedText('8) Would you like personalized recommendations for local experiences based on your preferences?'),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Expanded(
          child: Text('Personalized Recommendations:', style: TextStyle(color: Colors.white)),
        ),
        Radio<bool>(
          value: true,
          groupValue: personalizedRecommendations,
          onChanged: (value) {
            setState(() {
              personalizedRecommendations = value!;
            });
          },
          activeColor: Colors.orange,
        ),
        Text('Yes', style: TextStyle(color: Colors.white)),
        Radio<bool>(
          value: false,
          groupValue: personalizedRecommendations,
          onChanged: (value) {
            setState(() {
              personalizedRecommendations = value!;
            });
          },
          activeColor: Colors.orange,
        ),
        Text('No', style: TextStyle(color: Colors.white)),
      ],
    ),
  ],
),

      _buildNumberedText('9) What kind of recommendations are you looking for?'),
      ...['Restaurants and cafes', 'Local tours and activities', 'Shopping recommendations', 'Entertainment (e.g., concerts, shows)', 'Historical or cultural sites'].map((option) {
        return CheckboxListTile(
          title: Text(option, style: TextStyle(color: Colors.white)),
          value: recommendationTypes.contains(option),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                recommendationTypes.add(option);
              } else {
                recommendationTypes.remove(option);
              }
            });
          },
          activeColor: Colors.orange,
        );
      }).toList(),
    ],
  );
}

  // Networking Buddy Content
  Widget _buildNetworkingBuddyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('💼 Professional Interests'),
        _buildNumberedText('1) What are your professional interests?'),
        ...professionalInterestsOptions.map((option) {
          return CheckboxListTile(
            title: Text(option, style: TextStyle(color: Colors.white)),
            value: selectedProfessionalInterests.contains(option),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedProfessionalInterests.add(option);
                } else {
                  selectedProfessionalInterests.remove(option);
                }
              });
            },
            activeColor: Colors.orange,
          );
        }).toList(),
        SizedBox(height: 10),
        _buildNumberedText('2) Current Company'),
        _buildTextField('Enter your company name', companyName, (value) {
          setState(() {
            companyName = value;
          });
        }),
        _buildNumberedText('3) Job Title'),
        _buildTextField('Enter your job title', jobTitle, (value) {
          setState(() {
            jobTitle = value;
          });
        }),
        _buildNumberedText('4) LinkedIn Profile'),
        _buildTextField('Enter your LinkedIn URL', linkedIn, (value) {
          setState(() {
            linkedIn = value;
          });
        }),
      ],
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18));
  }

  // Helper method to build numbered questions
  Widget _buildNumberedText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  // Helper method to build checkbox options
  Widget _buildCheckboxOption(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.orange,
    );
  }

  // Helper method to build Yes/No options
  Widget _buildYesNoOption(String title, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Text('$title:', style: TextStyle(color: Colors.white)),
        Radio<bool>(
          value: true,
          groupValue: value,
          onChanged: onChanged,
          activeColor: Colors.orange,
        ),
        Text('Yes', style: TextStyle(color: Colors.white)),
        Radio<bool>(
          value: false,
          groupValue: value,
          onChanged: onChanged,
          activeColor: Colors.orange,
        ),
        Text('No', style: TextStyle(color: Colors.white)),
      ],
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String hint, String value, Function(String) onChanged) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange),
        ),
        filled: true,
        fillColor: Colors.grey[850],
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15), // Adjust height
      ),
      style: TextStyle(color: Colors.white),
      onChanged: onChanged,
    );
  }

  // Helper method to build age range options
  Widget _buildAgeRangeOptions() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 5.0,
      children: ['18-25', '26-35', '36-45', '46-55', '56-65', '65+'].map((ageRange) {
        return ChoiceChip(
          label: Text(ageRange, style: TextStyle(color: selectedAgeRange == ageRange ? Colors.black : Colors.white)),
          selected: selectedAgeRange == ageRange,
          selectedColor: Colors.orange,
          backgroundColor: Colors.grey[800],
          onSelected: (selected) {
            setState(() {
              selectedAgeRange = ageRange;
            });
          },
        );
      }).toList(),
    );
  }

Future<void> _submitForm() async {
  if (agreeToShare) {
    _submitRoomSharingData();
    _submitMealBuddyData();
    _submitRecreationalData();
    _submitNetworkingData();

    Map<String, dynamic> matchData = await fetchMatches();

    if (matchData.isNotEmpty) {
      // You can navigate to the LandingPage or any other page here
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LandingPage2(
            matchData: matchData, // Pass the whole matchData map to LandingPage
          ),
        ),
      );
    }
}
  print('--- Room Share Buddy ---');
  print('Same Gender Preference: $sameGender');
  print('No Gender Preference: $noGenderPreference');
  print('Age Preference: $agePreference');
  print('Selected Age Range: $selectedAgeRange');
  print('Smoking: $smoking');
  print('Drinking: $drinking');
  print('Special Requests: $roomShareSpecialRequests');

  print('\n--- Food Buddy ---');
  print('Meal Preferences: $mealPreferences');
  print('Dietary Restrictions: $dietaryRestrictions');

  print('\n--- Recreational Buddy ---');
  print('Recreational Activities: $recreationalActivities');
  print('Social Activities: $socialActivities');

  print('\n--- Networking Buddy ---');
  print('Professional Interests: $selectedProfessionalInterests');
  print('Company Name: $companyName');
  print('Job Title: $jobTitle');
  print('LinkedIn Profile: $linkedIn');
}
}
