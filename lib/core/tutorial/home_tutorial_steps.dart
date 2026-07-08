import 'package:celebray/core/tutorial/feature_tutorial_overlay.dart';
import 'package:flutter/material.dart';

List<TutorialStep> buildHomeTutorialSteps({
  required GlobalKey fabKey,
  required GlobalKey settingsKey,
  required GlobalKey calendarNavKey,
  required GlobalKey generateNavKey,
}) {
  return [
    const TutorialStep(
      title: 'Welcome to Celebray',
      body:
          'This quick tour shows where to add celebrations, generate messages, and find settings. You can skip anytime.',
    ),
    TutorialStep(
      title: 'Add a celebration',
      body:
          'Tap + to add a birthday, anniversary, or milestone. You can also import dates from your calendar.',
      targetKey: fabKey,
      tabIndex: 0,
    ),
    TutorialStep(
      title: 'Settings & import',
      body:
          'Open settings for alerts, feedback, and account options. Use the menu to import from your calendar.',
      targetKey: settingsKey,
      tabIndex: 0,
    ),
    TutorialStep(
      title: 'Calendar view',
      body:
          'See upcoming celebrations on a calendar. Tap a day to view or add events.',
      targetKey: calendarNavKey,
      tabIndex: 0,
    ),
    TutorialStep(
      title: 'Generate messages',
      body:
          'Pick an event, choose a tone, and create AI-powered greetings to share.',
      targetKey: generateNavKey,
      tabIndex: 0,
    ),
    const TutorialStep(
      title: 'You\'re all set',
      body:
          'Add your first celebration and Celebray will remind you at midnight on the big day.',
    ),
  ];
}
