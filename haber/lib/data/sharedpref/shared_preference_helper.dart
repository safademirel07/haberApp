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

  static Future<bool> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key) ?? false;
  }

  static Future setBool(String key, bool value) async {
    final p = await prefs;
    return p.setBool(key, value);
  }

  static Future<bool> get getInit => getBool(Constants.init_pref);
  static Future setInit(bool value) {
    return setBool(Constants.init_pref, value);
  }

  static Future<bool> get getSabah => getBool(Constants.sabah_pref);
  static Future setSabah(bool value) {
    return setBool(Constants.sabah_pref, value);
  }

  static Future<bool> get getMilliyet => getBool(Constants.milliyet_pref);
  static Future setMilliyet(bool value) {
    return setBool(Constants.milliyet_pref, value);
  }

  static Future<bool> get getCNNTurk => getBool(Constants.cnnturk_pref);
  static Future setCNNTurk(bool value) {
    return setBool(Constants.cnnturk_pref, value);
  }

  static Future<bool> get getHaberTurk => getBool(Constants.haberturk_pref);
  static Future setHaberTurk(bool value) {
    return setBool(Constants.haberturk_pref, value);
  }

  static Future<bool> get getNTV => getBool(Constants.ntv_pref);
  static Future setNTV(bool value) {
    return setBool(Constants.ntv_pref, value);
  }

  static Future<String> get getAuthToken => getString(Constants.auth_token);
  static Future setAuthToken(String value) =>
      setString(Constants.auth_token, value);

  static Future<String> get getUID => getString(Constants.uid_token);
  static Future setUID(String value) => setString(Constants.uid_token, value);

  static Future<String> get getUser => getString(Constants.user_token);
  static Future setUser(String value) {
    setString(Constants.user_token, value);
  }

  static Future<String> get getPassword => getString(Constants.password_token);
  static Future setPassword(String value) =>
      setString(Constants.password_token, value);

  static Future<String> get getAnonymousID =>
      getString(Constants.anonymous_token);
  static Future setAnonymousID(String value) =>
      setString(Constants.anonymous_token, value);

  static Future<String> get getFavorites => getString(Constants.favorites_pref);
  static Future addFavorites(String value) async {
    String currentFavorites = await getFavorites;
    String newValue = currentFavorites + value + ",";
    setString(Constants.favorites_pref, newValue);
  }

  static Future setFavorites(String value) async {
    setString(Constants.favorites_pref, value);
  }
}
