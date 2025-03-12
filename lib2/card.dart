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
      backgroundColor: Colors.brown.shade100,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: Text("My Card", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_table')
            .where('username', isEqualTo: globals.username)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading card details', style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: Colors.brown.shade700),
            );
          }

          var userDoc = snapshot.data!.docs.first;
          globals.card_number = userDoc['card_number'];
          String cardNumber = userDoc['card_number'] ?? "0";
          String maskedCardNumber = _maskCardNumber(cardNumber); // ✅ ปิดเลขบัตร

          return Center(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: cardNumber == "0"
                  ? _buildAddCardButton(context)
                  : _buildCardInfo(context, maskedCardNumber, userDoc.id),
            ),
          );
        },
      ),
    );
  }

  // ✅ ปิดเลขบัตรโดยให้แสดงแค่ 4 ตัวท้าย
  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return "****";
    return "**** **** **** ${cardNumber.substring(cardNumber.length - 4)}";
  }

  // ✅ ปุ่มเพิ่มบัตรเครดิต
  Widget _buildAddCardButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown.shade700,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCardPage()),
        ).then((_) {
          setState(() {}); // Refresh หลังจากเพิ่มบัตร
        });
      },
      icon: Icon(Icons.add, color: Colors.white),
      label: Text("Add Card", style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  // ✅ แสดงข้อมูลบัตร พร้อมปุ่มแก้ไขและลบ
  Widget _buildCardInfo(BuildContext context, String maskedCardNumber, String docId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.brown.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.credit_card, size: 50, color: Colors.brown.shade700),
                SizedBox(height: 10),
                Text(
                  "Card Number",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown.shade800),
                ),
                SizedBox(height: 5),
                Text(
                  maskedCardNumber, // ✅ แสดงเลขบัตรแบบปิดบางส่วน
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.brown.shade900),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),

        // ✅ ปุ่มแก้ไขบัตร
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade700,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCardPage()),
            ).then((_) {
              setState(() {}); // Refresh หลังจากแก้ไขบัตร
            });
          },
          icon: Icon(Icons.edit, color: Colors.white),
          label: Text("Edit Card", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),

        SizedBox(height: 10),

        // ✅ ปุ่มลบบัตร
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _showDeleteDialog(context, docId), // ✅ แสดง Dialog ยืนยันก่อนลบ
          icon: Icon(Icons.delete, color: Colors.white),
          label: Text("Delete Card", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  // ✅ แสดง Dialog ยืนยันการลบบัตร
  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Card"),
        content: Text("Are you sure you want to delete your card?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.brown.shade700)),
          ),
          TextButton(
            onPressed: () async {
              globals.card_number = "0";
              await FirebaseFirestore.instance
                  .collection('user_table')
                  .doc(docId)
                  .update({'card_number': "0"}); // ✅ ลบบัตรโดยตั้งค่าเป็น "0"

              Navigator.pop(context);
              setState(() {}); // Refresh หลังจากลบ
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
