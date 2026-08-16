import 'package:flutter/material.dart';
import 'package:bike_taxi_app/services/auth_service.dart';
import 'package:bike_taxi_app/screens/home_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _phoneCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  void _trySignup() async {
    setState(() { _loading = true; _error = null; });
    final ok = await AuthService.signup(_phoneCtl.text.trim(), _passCtl.text);
    setState(() { _loading = false; });
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      setState(() { _error = 'رقم الهاتف مستخدم مسبقاً'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneCtl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'رقم الهاتف'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passCtl,
              obscureText: true,
              decoration: InputDecoration(labelText: 'كلمة المرور'),
            ),
            SizedBox(height: 16),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: _loading ? null : _trySignup,
              child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('سجل الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
