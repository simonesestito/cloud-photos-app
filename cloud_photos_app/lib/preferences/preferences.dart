import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const _loginNameKey = 'loginName';

  static Preferences? _instance;
  final SharedPreferences _prefs;

  // Private constructor
  Preferences._(this._prefs);

  // Initialize the singleton instance
  static Future<Preferences> ensureInitialized() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = Preferences._(prefs);
    }
    return _instance!;
  }

  // Singleton instance
  static Preferences get instance => _instance!;

  String? getLoginName() => _prefs.getString(_loginNameKey);

  Future<void> removeLoginName() => _prefs.remove(_loginNameKey);

  Future<void> setLoginName(String loginName) =>
      _prefs.setString(_loginNameKey, loginName);
}
