import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    await _saveToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'phone': user.phoneNumber,
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
