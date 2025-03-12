import 'package:flutter/material.dart';
import 'global.dart' as globals;
import 'login.dart';

class UserPage extends StatelessWidget {
  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300], // Light grey background
              child: Icon(
                Icons.person, // Profile icon
                size: 60,
                color: Colors.grey[700], // Darker grey for contrast
              ),
            ),
            SizedBox(height: 20),
            Text("Username: ${globals.username}", style: TextStyle(fontSize: 20)),
            Text("Email: ${globals.email}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => logout(context),
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
