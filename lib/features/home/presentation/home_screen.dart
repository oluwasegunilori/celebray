import 'package:celebray/features/calendar/presentation/calendar_screen.dart';
import 'package:celebray/features/generator/presentation/generator_screen.dart';
import 'package:celebray/features/home/widgets/elegant_bottom_nav.dart';
import 'package:celebray/features/notifications/notification_navigation_handler.dart';
import 'package:celebray/features/reminders/presentation/reminders_screen.dart';
import 'package:celebray/core/tutorial/feature_tutorial_overlay.dart';
import 'package:celebray/core/tutorial/home_tutorial_steps.dart';
import 'package:celebray/core/tutorial/tutorial_storage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showTutorial = false;
  int _tutorialStep = 0;

  final _fabKey = GlobalKey();
  final _settingsKey = GlobalKey();
  final _calendarNavKey = GlobalKey();
  final _generateNavKey = GlobalKey();

  late final List<TutorialStep> _tutorialSteps = buildHomeTutorialSteps(
    fabKey: _fabKey,
    settingsKey: _settingsKey,
    calendarNavKey: _calendarNavKey,
    generateNavKey: _generateNavKey,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigationHandler.consumePendingNavigation();
      _maybeStartTutorial();
    });
  }

  Future<void> _maybeStartTutorial() async {
    if (await TutorialStorage.hasSeenHomeTutorial()) return;
    if (!mounted) return;
    setState(() => _showTutorial = true);
  }

  Future<void> _finishTutorial() async {
    await TutorialStorage.markHomeTutorialSeen();
    if (!mounted) return;
    setState(() => _showTutorial = false);
  }

  void _advanceTutorial() {
    if (_tutorialStep >= _tutorialSteps.length - 1) {
      _finishTutorial();
      return;
    }

    final nextStep = _tutorialStep + 1;
    final tabIndex = _tutorialSteps[nextStep].tabIndex;

    setState(() {
      _tutorialStep = nextStep;
      if (tabIndex != null) {
        _currentIndex = tabIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      RemindersScreen(
        fabKey: _fabKey,
        settingsKey: _settingsKey,
      ),
      const CalendarScreen(),
      const GeneratorScreen(),
    ];

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ElegantBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              calendarTabKey: _calendarNavKey,
              generateTabKey: _generateNavKey,
            ),
          ),
        ),
        if (_showTutorial)
          Positioned.fill(
            child: FeatureTutorialOverlay(
              steps: _tutorialSteps,
              stepIndex: _tutorialStep,
              onNext: _advanceTutorial,
              onSkip: _finishTutorial,
            ),
          ),
      ],
    );
  }
}
