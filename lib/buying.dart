import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals;

class BuyingPage extends StatefulWidget {
  @override
  _BuyingPageState createState() => _BuyingPageState();
}

class _BuyingPageState extends State<BuyingPage> {
  String selectedType = "all";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BuyPage'),
            Text(globals.username),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // Dropdown for filtering
            DropdownButton<String>(
              value: selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              items: ["all", "chicken", "duck", "goose", "egg"].map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
            ),
            
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chicken_table').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Filter items based on selected type
                  var filteredDocs = selectedType == "all"
                      ? snapshot.data!.docs
                      : snapshot.data!.docs.where((doc) => doc['type'] == selectedType).toList();
                  
                  return ListView(
                    children: filteredDocs.map((doc) {
                      return ListTile(
                        title: Text(doc['name']),
                        subtitle: Text('Cost: \$${doc['cost']}'),
                        leading: Image.network(doc['urlimg'], width: 50, height: 50),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            _showQuantityDialog(context, doc);
                          },
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(doc['name']),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(doc['urlimg'], width: 200, height: 200),
                                  Text(doc['description']),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, DocumentSnapshot doc) {
    TextEditingController quantityController = TextEditingController(text: '1');
    double totalCost = doc['cost'] * 1.0;
    String costtext = "Total Cost: \$${totalCost.toStringAsFixed(2)}";
    bool isValidQuantity = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Number of ${doc['name']} to buy'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter quantity',
                      errorText: isValidQuantity ? null : 'Please enter a valid quantity (>= 1)',
                    ),
                    onChanged: (value) {
                      if (int.tryParse(value) != null && int.parse(value) > 0) {
                        setState(() {
                          totalCost = doc['cost'] * int.parse(value).toDouble();
                          costtext = "Total Cost: \$${totalCost.toStringAsFixed(2)}";
                          isValidQuantity = true;
                        });
                      } else {
                        setState(() {
                          isValidQuantity = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Text(costtext),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isValidQuantity
                      ? () {
                          int quantity = int.tryParse(quantityController.text) ?? 1;
                          FirebaseFirestore.instance.collection('cart').add({
                            'username': globals.username,
                            'chickenid': doc['id'],
                            'aniname': doc['name'],
                            'quantity': quantity,
                            'cost': doc['cost'],
                            'urlimg': doc['urlimg'],
                            'status': 'not paid',
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text('Add to Cart'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
