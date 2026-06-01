import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const _keyTheme = 'theme_mode';
  static const _keyNotif = 'notif_enabled';
  static const _keyUserName = 'user_name';
  static const _keyCityLocation = 'city_location';

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode);
  }

  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme) ?? 'light';
  }

  static Future<void> saveNotifEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotif, value);
  }

  static Future<bool> getNotifEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotif) ?? true;
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Pengguna';
  }

  static Future<void> saveCityLocation(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCityLocation, city);
  }

  static Future<String> getCityLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCityLocation) ?? 'Jakarta';
  }
}
