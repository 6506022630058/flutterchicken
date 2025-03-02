import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals;
import 'addcard.dart';

class CardPage extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Card Page"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_table')
            .where('username', isEqualTo: globals.username)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var userDoc = snapshot.data!.docs.isNotEmpty ? snapshot.data!.docs.first : null;
          String cardNumber = userDoc?['card_number'] ?? "0";

          return Center(
            child: cardNumber == "0"
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddCardPage()),
                      ).then((_) {
                        setState(() {}); // Refresh page after returning
                      });
                    },
                    child: Text("Add Card"),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Card Number: $cardNumber", style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddCardPage()),
                          ).then((_) {
                            setState(() {}); // Refresh page after returning
                          });
                        },
                        child: Text("Edit Card"),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
