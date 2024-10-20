import 'package:flutter/material.dart';
import 'package:marriotbuddy_application/SignUp_Login/LoginPage.dart';

void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marriott Buddy App',
      theme: ThemeData(
        primarySwatch: Colors.orange, // Define the primary color as orange
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _navigateToLoginPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLoginPage() {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Marriott Buddy logo image
                  Image.asset(
                    'assets/Ask.png', // Replace with your splash image path
                    height: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  // App Name in white and orange
                  Text(
                    'Marriott Buddy',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for "Marriott"
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Tagline
                  Text(
                    'Connecting You with Fellow Travelers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.orange, // Orange tagline text
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
