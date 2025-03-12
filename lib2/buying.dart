import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals;

class BuyingPage extends StatefulWidget {
  @override
  _BuyingPageState createState() => _BuyingPageState();
}

class _BuyingPageState extends State<BuyingPage> {
  String selectedType = "all";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: Text('Buy Page', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.brown.shade100,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search keywords...',
                  prefixIcon: Icon(Icons.search, color: Colors.brown.shade700),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            // Banner Image
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Image.network(
                    'https://media.istockphoto.com/id/1264916978/photo/silkie-chickens-live-in-garden.jpg?s=612x612&w=0&k=20&c=J_y7_vMZn64w6bNBdx8jrahGyg3_R8L0qRskE2LKRpg=',
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Text(
                      'Best Seller!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lime,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            // Categories
            Container(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildCategoryIcon('all', 'All', Icons.storefront),
                  SizedBox(width: 35),
                  _buildCategoryIcon('chicken', 'Chicken', Icons.brightness_5),
                  SizedBox(width: 35),
                  _buildCategoryIcon('duck', 'Duck', Icons.radio_button_on),
                  SizedBox(width: 35),
                  _buildCategoryIcon('goose', 'Goose', Icons.brightness_4),
                  SizedBox(width: 35),
                  _buildCategoryIcon('egg', 'Egg', Icons.egg),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Featured Products
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chicken_table').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    final name = doc['name'].toString().toLowerCase();
                    final type = doc['type'].toString().toLowerCase();
                    return (selectedType == "all" || type == selectedType) &&
                        (searchQuery.isEmpty || name.contains(searchQuery));
                  }).toList();

                  return GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var doc = filteredDocs[index];
                      return _buildProductCard(doc);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildCategoryIcon(String type, String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: selectedType == type ? Colors.brown.shade700 : Colors.brown.shade300,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 5),
          Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProductCard(DocumentSnapshot doc) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.brown.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
          onTap: () => _showDescriptionDialog(context, doc),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(doc['urlimg'], width: double.infinity, height: 120, fit: BoxFit.cover),
          ),
        ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text(doc['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Cost: ฿${doc['cost']}', style: TextStyle(color: Colors.brown.shade700)),
              ],
            ),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade700),
            onPressed: () => _showQuantityDialog(context, doc),
            child: Text('Add to Cart', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showDescriptionDialog(BuildContext context, DocumentSnapshot doc) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(doc['name']),
        content: SingleChildScrollView(
          child: Text(doc['description'] ?? "No description available."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
  void _showQuantityDialog(BuildContext context, DocumentSnapshot doc) {
    print("Dialog Opened");

    int quantity = 1;
    double cost = (doc['cost'] as num).toDouble();
    double totalCost = cost * quantity;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.brown.shade700),
                        onPressed: quantity > 1
                            ? () {
                          setState(() {
                            quantity--;
                            totalCost = cost * quantity;
                          });
                          print("Quantity Decreased: $quantity, Total Cost: $totalCost");
                        }
                            : null,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '$quantity', // ✅ จะเปลี่ยนแปลงตามค่าที่กด
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.brown.shade700),
                        onPressed: () {
                          setState(() {
                            quantity++;
                            totalCost = cost * quantity;
                          });
                          print("Quantity Increased: $quantity, Total Cost: $totalCost");
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Total Cost: ฿${totalCost.toStringAsFixed(2)}")
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FirebaseFirestore.instance.collection('cart').add({
                      'username': globals.username,
                      'chickenid': doc.id,
                      'aniname': doc['name'],
                      'quantity': quantity,
                      'cost': cost,
                      'urlimg': doc['urlimg'],
                      'status': 'not paid',
                    });
                    print("Added to Cart: $quantity x ${doc['name']}");
                    Navigator.of(context).pop();
                  },
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
