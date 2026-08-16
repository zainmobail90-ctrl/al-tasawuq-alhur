import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final request = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  String payment = 'cash';
  bool saving = false;

  Future<void> createOrder() async {
    if (request.text.trim().isEmpty || address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب الطلب والعنوان أولاً')));
      return;
    }

    setState(() => saving = true);
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('orders').add({
      'customerId': user.uid,
      'customerPhone': user.phoneNumber,
      'requestText': request.text.trim(),
      'address': address.text.trim(),
      'notes': notes.text.trim(),
      'paymentMethod': payment,
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الطلب بنجاح')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلب جديد')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('شنو تريد نشتري لك؟',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: request,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'مثال: أريد شراء ... الكمية ... ومن محل ...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: address,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'عنوان التوصيل بالتفصيل',
                hintText: 'المحافظة، المنطقة، الشارع، أقرب نقطة دالة...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ملاحظات للسائق',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('طريقة الدفع',
              style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              value: 'cash',
              groupValue: payment,
              title: const Text('نقدي عند الاستلام'),
              onChanged: (v) => setState(() => payment = v!),
            ),
            RadioListTile(
              value: 'electronic',
              groupValue: payment,
              title: const Text('دفع إلكتروني'),
              onChanged: (v) => setState(() => payment = v!),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: saving ? null : createOrder,
              child: Text(saving ? 'جاري الإرسال...' : 'إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
