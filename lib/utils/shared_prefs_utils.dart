import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static SharedPreferences? _instance;

  static Future<SharedPreferences?> _init() async {
    _instance = await SharedPreferences.getInstance();
    return _instance;
  }

  static Future<SharedPreferences?> getSharedPrefs() async {
    if (_instance == null) {
      await _init();
    }
    return _instance;
  }
}
