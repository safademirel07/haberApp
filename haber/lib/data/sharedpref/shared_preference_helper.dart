import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class SharedPreferenceHelper {
  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  static Future<String> getString(String key) async {
    final p = await prefs;
    return p.getString(key) ?? '';
  }

  static Future setString(String key, String value) async {
    final p = await prefs;
    return p.setString(key, value);
  }
}
