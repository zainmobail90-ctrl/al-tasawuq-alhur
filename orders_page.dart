import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  String statusText(String s) {
    switch (s) {
      case 'new': return 'طلب جديد';
      case 'accepted': return 'تم قبول الطلب';
      case 'shopping': return 'جاري شراء الطلب';
      case 'delivering': return 'بالطريق';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'ملغي';
      default: return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلباتي')),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('customerId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasError) return Center(child: Text('خطأ: ${snap.error}'));
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('ما عندك طلبات حالياً'));
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(d['requestText'] ?? ''),
                    subtitle: Text(statusText(d['status'] ?? '')),
                    trailing: const Icon(Icons.local_shipping),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
