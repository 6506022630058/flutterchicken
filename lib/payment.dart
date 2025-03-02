import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals; // Import global.dart for username

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PaymentPage'),  // Display the current page's title
            Text(globals.username),  // Display the username from global.dart on the right
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('username', isEqualTo: globals.username) // Filter by current user
            .where('status', isEqualTo: 'not paid')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Calculate total cost
          double totalCost = 0;
          snapshot.data!.docs.forEach((doc) {
            double cost = doc['cost'] is int ? (doc['cost'] as int).toDouble() : doc['cost'] as double;
            double quantity = doc['quantity'] is int ? (doc['quantity'] as int).toDouble() : doc['quantity'] as double;

            double itemCost = cost * quantity; // Multiply cost by quantity
            totalCost += itemCost; // Add to the total cost
          });

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display cart items and calculate total cost
                Expanded(
                  child: ListView(
                    children: snapshot.data!.docs.map((doc) {
                      double cost = doc['cost'] is int ? (doc['cost'] as int).toDouble() : doc['cost'] as double;
                      double quantity = doc['quantity'] is int ? (doc['quantity'] as int).toDouble() : doc['quantity'] as double;
                      return ListTile(
                        leading: Image.network(doc['urlimg']),
                        title: Text(doc['aniname']),
                        subtitle: Text('Quantity: ${doc['quantity']}'),
                        trailing: Text('\$${(cost * quantity).toStringAsFixed(2)}'),
                      );
                    }).toList(),
                  ),
                ),
                // Display the total cost
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Proceed to payment button (optional)
                ElevatedButton(
                  onPressed: () async {
                    // credit card is stored in the firestore collection 'user_table' with the field 'card_number'
                    // if the user does not have a credit card, then the field 'card_number' is "0"
                    // if the user has a credit card, then the field 'card_number' is somethingelse
                    // if the user has a credit card, then update the status to 'paid'
                    // if the user does not have a credit card, then show a dialog to the user to add a credit card

                    if (globals.card_number == "0") {
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: Text('No Credit Card'),
                        content: Text('Please add a credit card to proceed to payment'),
                      ));
                    }
                    else {
                      final cartItems = snapshot.data!.docs;
                      for (var item in cartItems) {
                        await FirebaseFirestore.instance
                          .collection('cart')
                          .doc(item.id)
                          .update({'status': 'paid'}); // Mark the item as paid
                      }
                    }
                  },
                  child: Text('Proceed to Payment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
