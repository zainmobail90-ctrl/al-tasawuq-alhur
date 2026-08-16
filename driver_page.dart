import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverPage extends StatelessWidget {
  const DriverPage({super.key});

  String statusText(String s) {
    switch (s) {
      case 'new': return 'جديد';
      case 'accepted': return 'مقبول';
      case 'shopping': return 'جاري شراء الطلب';
      case 'delivering': return 'بالطريق';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'ملغي';
      default: return s;
    }
  }

  Future<void> update(String id, String status) {
    return FirebaseFirestore.instance.collection('orders').doc(id).update({
      'status': status,
      'driverId': FirebaseAuth.instance.currentUser!.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = FirebaseFirestore.instance
        .collection('orders')
        .where('driverId', isEqualTo: uid)
        .where('status', whereIn: ['accepted', 'shopping', 'delivering']);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلبات السائق')),
        body: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text('خطأ: ${snap.error}'));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('لا توجد طلبات مسندة إليك حالياً'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i];
                final x = d.data() as Map<String, dynamic>;
                final status = x['status'] ?? 'accepted';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طلب #${d.id.substring(0, 8)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('الطلب: ${x['requestText'] ?? ''}'),
                        Text('العنوان: ${x['address'] ?? ''}'),
                        Text('الهاتف: ${x['customerPhone'] ?? ''}'),
                        Text('الدفع: ${x['paymentMethod'] == 'cash' ? 'نقدي' : 'إلكتروني'}'),
                        Text('الحالة: ${statusText(status)}'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (status == 'accepted')
                              FilledButton(
                                onPressed: () => update(d.id, 'shopping'),
                                child: const Text('بدأت شراء الطلب'),
                              ),
                            if (status == 'shopping')
                              FilledButton(
                                onPressed: () => update(d.id, 'delivering'),
                                child: const Text('أنا بالطريق'),
                              ),
                            if (status == 'delivering')
                              FilledButton(
                                onPressed: () => update(d.id, 'delivered'),
                                child: const Text('تم التسليم'),
                              ),
                          ],
                        )
                      ],
                    ),
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
