import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String SHOW_ONBOARDING = 'showOnboarding';

  static Future<void> setOnboardingShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SHOW_ONBOARDING, false);
  }

  static Future<bool> shouldShowOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SHOW_ONBOARDING) ?? true;
  }
}
