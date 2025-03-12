import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals; // Import global.dart for username

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade100, // ✅ เปลี่ยนสีพื้นหลังเป็นน้ำตาลอ่อน
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700, // ✅ เปลี่ยนสี AppBar เป็นน้ำตาลเข้ม
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Cart', style: TextStyle(color: Colors.white)), // ✅ เปลี่ยนชื่อให้ดูดีขึ้น
            Text(globals.username, style: TextStyle(color: Colors.white)), // ✅ เปลี่ยนสีให้เข้ากับธีม
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('username', isEqualTo: globals.username) // ✅ ค้นหาข้อมูลของผู้ใช้คนปัจจุบัน
            .where('status', isEqualTo: 'not paid')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown.shade700),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              return Card(
                color: Colors.brown.shade50, // ✅ เปลี่ยนพื้นหลังของสินค้า
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(doc['urlimg'], width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(doc['aniname'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Quantity: ${doc['quantity']}   Total: ฿${(doc['cost'] * doc['quantity']).toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.brown.shade700),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade700), // ✅ เปลี่ยนปุ่มลบเป็นสีแดง
                    onPressed: () {
                      FirebaseFirestore.instance.collection('cart').doc(doc.id).delete();
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}