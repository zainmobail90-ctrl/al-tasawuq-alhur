import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static SharedPreferences? _prefs;
  static const String USERS_KEY = 'bt_users';
  static const String LOGGED_KEY = 'bt_logged_user';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // users stored as list of json strings
  static List<Map<String, String>> _readUsers() {
    final list = _prefs?.getStringList(USERS_KEY) ?? [];
    return list.map((s) => Map<String, String>.from(jsonDecode(s))).toList();
  }

  static Future<void> _writeUsers(List<Map<String, String>> users) async {
    final list = users.map((u) => jsonEncode(u)).toList();
    await _prefs?.setStringList(USERS_KEY, list);
  }

  static Future<bool> signup(String phone, String password) async {
    final users = _readUsers();
    final exists = users.any((u) => u['phone'] == phone);
    if (exists) return false;
    users.add({'phone': phone, 'password': password});
    await _writeUsers(users);
    await login(phone, password);
    return true;
  }

  static Future<bool> login(String phone, String password) async {
    final users = _readUsers();
    final user = users.firstWhere((u) => u['phone'] == phone && u['password'] == password, orElse: () => {});
    if (user.isEmpty) return false;
    await _prefs?.setString(LOGGED_KEY, jsonEncode(user));
    return true;
  }

  static Map<String, String>? currentUser() {
    final s = _prefs?.getString(LOGGED_KEY);
    if (s == null) return null;
    return Map<String, String>.from(jsonDecode(s));
  }

  static Future<void> logout() async {
    await _prefs?.remove(LOGGED_KEY);
  }
}
