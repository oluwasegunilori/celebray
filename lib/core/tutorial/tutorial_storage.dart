import 'package:shared_preferences/shared_preferences.dart';

class TutorialStorage {
  static const _homeTutorialKey = 'hasSeenHomeTutorial';
  static const _generatorTutorialKey = 'hasSeenGeneratorTutorial';
  static const _eventDetailTutorialKey = 'hasSeenEventDetailTutorial';
  static const _shareTutorialKey = 'hasSeenShareTutorial';

  static Future<bool> hasSeenHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_homeTutorialKey) ?? false;
  }

  static Future<void> markHomeTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeTutorialKey, true);
  }

  static Future<bool> hasSeenGeneratorTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_generatorTutorialKey) ?? false;
  }

  static Future<void> markGeneratorTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_generatorTutorialKey, true);
  }

  static Future<bool> hasSeenEventDetailTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_eventDetailTutorialKey) ?? false;
  }

  static Future<void> markEventDetailTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eventDetailTutorialKey, true);
  }

  static Future<bool> hasSeenShareTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shareTutorialKey) ?? false;
  }

  static Future<void> markShareTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shareTutorialKey, true);
  }
}
