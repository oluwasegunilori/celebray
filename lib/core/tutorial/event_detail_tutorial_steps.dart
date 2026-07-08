import 'package:celebray/core/tutorial/feature_tutorial_overlay.dart';
import 'package:flutter/material.dart';

List<TutorialStep> buildEventDetailTutorialSteps({
  required GlobalKey editKey,
  required GlobalKey generateKey,
  GlobalKey? shareKey,
  required bool hasMessage,
}) {
  return [
    const TutorialStep(
      title: 'Celebration details',
      body:
          'See the date, relationship, and any saved message for this celebration.',
    ),
    TutorialStep(
      title: 'Edit',
      body:
          'Change the name, date, relationship, closeness, and other details about this event.',
      targetKey: editKey,
    ),
    if (hasMessage && shareKey != null)
      TutorialStep(
        title: 'Share',
        body:
            'Send a greeting card or plain text using your saved message — great for texting or social.',
        targetKey: shareKey,
      )
    else
      const TutorialStep(
        title: 'Share',
        body:
            'Share appears after you generate and save a message. Use Generate Message below to create one first.',
      ),
    TutorialStep(
      title: hasMessage ? 'Edit message' : 'Generate message',
      body: hasMessage
          ? 'Open your saved greeting to refine it, try new AI options, or update the wording.'
          : 'Create AI-powered message ideas tailored to this person and celebration.',
      targetKey: generateKey,
    ),
    const TutorialStep(
      title: 'You\'re ready',
      body:
          'Edit anytime, generate when you need the perfect words, and share once a message is saved.',
    ),
  ];
}
