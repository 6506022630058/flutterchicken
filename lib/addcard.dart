import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals;

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController _cardNumberController = TextEditingController();

  void _saveCard() async {
    String cardNumber = _cardNumberController.text.trim();
    
    if (cardNumber.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('user_table')
          .where('username', isEqualTo: globals.username)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'card_number': cardNumber});
        }
      });

      Navigator.pop(context);  // Go back without removing the navbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add New Card",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Card Number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                globals.card_number = _cardNumberController.text.trim();
                _saveCard();
              },
              child: Text("Save Card"),
            ),
          ],
        ),
      ),
    );
  }
}
