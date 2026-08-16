import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/phone_login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AlTasawuqAlHurApp());
}

class AlTasawuqAlHurApp extends StatelessWidget {
  const AlTasawuqAlHurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'التسوق الحر',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorSchemeSeed: Colors.amber,
      ),
      home: const PhoneLoginPage(),
    );
  }
}
