import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals; // Import global.dart for username

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('CartPage'),  // Display the current page's title
            Text(globals.username),  // Display the username from global.dart on the right
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('username', isEqualTo: globals.username) // Query to filter by current user
            .where('status', isEqualTo: 'not paid')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                leading: Image.network(doc['urlimg'], width: 50, height: 50),
                title: Text(doc['aniname']),
                subtitle: Text('Quantity: ${doc['quantity']} Total Cost: ${doc['cost'] * doc['quantity']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Deleting the item from the current user's cart
                    FirebaseFirestore.instance.collection('cart').doc(doc.id).delete();
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
