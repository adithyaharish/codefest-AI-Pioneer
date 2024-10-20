import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> people = [
    {
      'image': 'assets/W1.jpg',
      'name': 'Ayesha Pawar',
      'message': 'Video',
      'icon': Icons.videocam,
      'iconColor': Colors.blue,
    },
    {
      'image': 'assets/W2.jpg',
      'name': 'Coffee & Consoles',
      'message': 'Dario: Who’s up for playing?',
      'icon': Icons.mic_off,
      'iconColor': Colors.grey,
    },
    {
      'image': 'assets/W3.jpg',
      'name': 'Jihoon Seo',
      'message': 'Hey, tried to call...',
      'icon': Icons.check,
      'iconColor': Colors.blue,
    },
    // {
    //   'image': 'assets/person4.jpg',
    //   'name': 'Shannon Brown',
    //   'message': 'GIF',
    //   'icon': Icons.gif,
    //   'iconColor': Colors.green,
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(
            color: Color(0xFFFFA500),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: people.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(people[index]['image']),
              radius: 25,
            ),
            title: Text(
              people[index]['name'],
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Icon(
                  people[index]['icon'],
                  color: people[index]['iconColor'],
                  size: 16,
                ),
                SizedBox(width: 5),
                Text(
                  people[index]['message'],
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    name: people[index]['name'],
                    image: people[index]['image'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String image;

  ChatDetailScreen({required this.name, required this.image});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<String> messages = [];
  TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using SafeArea or Padding to add space from the top
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0), // Add space from the top
              child: AppBar(
                backgroundColor: Colors.black,
                automaticallyImplyLeading: true,
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(widget.image),
                      radius: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Color(0xFFFFA500),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerRight, // Aligns sent messages to the right
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.orange[300], // Bubble color for sent messages
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          messages[index],
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter a message...',
                        filled: true,
                        fillColor: Colors.grey[800], // Input field background color
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xFFFFA500)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
