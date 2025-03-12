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

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Card"),
        backgroundColor: Colors.brown, // สีของแอปบาร์
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add New Card",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.brown, // สีข้อความหัวข้อ
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Card Number",
                labelStyle: TextStyle(color: Colors.brown),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown.shade100, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.credit_card, color: Colors.brown),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                globals.card_number = _cardNumberController.text.trim();
                _saveCard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown, // สีปุ่ม
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4, // เพิ่มเงาให้ปุ่มดูเด่น
              ),
              child: Text(
                "Save Card",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
