import 'package:shared_preferences/shared_preferences.dart';

class TutorialStorage {
  static const _homeTutorialKey = 'hasSeenHomeTutorial';

  static Future<bool> hasSeenHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_homeTutorialKey) ?? false;
  }

  static Future<void> markHomeTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeTutorialKey, true);
  }
}
