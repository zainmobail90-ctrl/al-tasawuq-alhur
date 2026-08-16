import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/notification_service.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final phone = TextEditingController();
  final code = TextEditingController();
  String? verificationId;
  bool loading = false;

  Future<void> sendCode() async {
    setState(() => loading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone.text.trim(),
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        await NotificationService.init();
        if (mounted) Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
      },
      verificationFailed: (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'تعذر إرسال الرمز')));
      },
      codeSent: (id, _) {
        setState(() {
          verificationId = id;
          loading = false;
        });
      },
      codeAutoRetrievalTimeout: (id) => verificationId = id,
    );
  }

  Future<void> verify() async {
    if (verificationId == null) return;
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: code.text.trim(),
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    await NotificationService.init();
    if (mounted) Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التسوق الحر')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تسجيل الدخول برقم الهاتف',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الموبايل',
                  hintText: '+9647XXXXXXXXX',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (verificationId != null)
                TextField(
                  controller: code,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رمز التحقق SMS',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loading
                    ? null
                    : (verificationId == null ? sendCode : verify),
                child: Text(verificationId == null ? 'إرسال الرمز' : 'دخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
