import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'driver_page.dart';
import 'new_order_page.dart';
import 'orders_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<bool> isDriver() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
    return doc.exists && (doc.data()?['active'] == true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التسوق الحر'),
          actions: [
            FutureBuilder<bool>(
              future: isDriver(),
              builder: (_, s) {
                if (s.data != true) return const SizedBox.shrink();
                return IconButton(
                  tooltip: 'وضع السائق',
                  icon: const Icon(Icons.delivery_dining),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DriverPage())),
                );
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.edit_note, size: 38),
                  title: const Text('اكتب طلبك بحرية'),
                  subtitle: const Text('اكتب البضاعة التي تريد شراءها والعنوان بالتفصيل.'),
                  trailing: const Icon(Icons.arrow_back_ios),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewOrderPage())),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, size: 38),
                  title: const Text('طلباتي'),
                  trailing: const Icon(Icons.arrow_back_ios),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const OrdersPage())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
