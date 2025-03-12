import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as globals;

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade100, // ✅ เปลี่ยนสีพื้นหลังเป็นน้ำตาลอ่อน
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700, // ✅ เปลี่ยนสี AppBar เป็นน้ำตาลเข้ม
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment', style: TextStyle(color: Colors.white)), // ✅ เปลี่ยนชื่อและสีให้ดูดีขึ้น
            Text(globals.username, style: TextStyle(color: Colors.white)), // ✅ เปลี่ยนสีให้เข้ากับธีม
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('username', isEqualTo: globals.username)
            .where('status', isEqualTo: 'not paid')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading cart items', style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown.shade700),
              ),
            );
          }

          // คำนวณราคารวม
          double totalCost = snapshot.data!.docs.fold(0, (sum, doc) {
            double cost = (doc['cost'] ?? 0).toDouble();
            double quantity = (doc['quantity'] ?? 0).toDouble();
            return sum + (cost * quantity);
          });

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ✅ แสดงรายการสินค้าในตะกร้า
                Expanded(
                  child: ListView(
                    children: snapshot.data!.docs.map((doc) {
                      double cost = (doc['cost'] ?? 0).toDouble();
                      double quantity = (doc['quantity'] ?? 0).toDouble();

                      return Card(
                        color: Colors.brown.shade50, // ✅ เปลี่ยนพื้นหลังของสินค้า
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              doc['urlimg'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, size: 60),
                            ),
                          ),
                          title: Text(doc['aniname'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Quantity: ${doc['quantity']}',
                            style: TextStyle(color: Colors.brown.shade700),
                          ),
                          trailing: Text(
                            '฿${(cost * quantity).toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade800),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ✅ แสดงราคารวม
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Cost: ฿${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown.shade900),
                  ),
                ),

                // ✅ ปุ่มชำระเงิน
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700, // ✅ เปลี่ยนสีปุ่มเป็นน้ำตาลเข้ม
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // ✅ ปรับขอบโค้ง
                  ),
                  onPressed: () async {
                    if (globals.card_number == "0") {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('No Credit Card', style: TextStyle(color: Colors.brown.shade900)), // ✅ เปลี่ยนสีข้อความ
                          content: Text('Please add a credit card to proceed to payment',
                              style: TextStyle(color: Colors.brown.shade700)), // ✅ เปลี่ยนสีข้อความ
                          actions: [
                            TextButton(
                              child: Text('OK', style: TextStyle(color: Colors.brown.shade700)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final cartItems = snapshot.data!.docs;
                      for (var item in cartItems) {
                        await FirebaseFirestore.instance.collection('cart').doc(item.id).update({'status': 'paid'});
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Payment Successful!'),
                        backgroundColor: Colors.green.shade700, // ✅ สีเขียวเพื่อแสดงความสำเร็จ
                      ));
                    }
                  },
                  child: Text('Proceed to Payment', style: TextStyle(color: Colors.white)), // ✅ เปลี่ยนสีข้อความปุ่ม
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
