import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings(this._prefs);

  final SharedPreferences _prefs;

  static const String _onboardedKey = 'onboarded';

  bool get onboarded => _prefs.getBool(_onboardedKey) ?? false;

  Future<void> setOnboarded(bool value) => _prefs.setBool(_onboardedKey, value);
}