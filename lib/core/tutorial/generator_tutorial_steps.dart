import 'package:celebray/core/tutorial/feature_tutorial_overlay.dart';
import 'package:flutter/material.dart';

List<TutorialStep> buildGeneratorTutorialSteps({
  required GlobalKey eventSelectorKey,
  required GlobalKey editEventKey,
  required GlobalKey tonePickerKey,
  required GlobalKey generateButtonKey,
}) {
  return [
    const TutorialStep(
      title: 'Create a message',
      body:
          'Pick a celebration, choose a tone, and generate personalized greetings. This quick tour shows you how.',
    ),
    TutorialStep(
      title: 'Choose the celebration',
      body:
          'Select who this message is for. You can switch between any celebration you have saved.',
      targetKey: eventSelectorKey,
    ),
    TutorialStep(
      title: 'Edit event details',
      body:
          'Need to change the name, date, relationship, or other details? Tap here before generating.',
      targetKey: editEventKey,
    ),
    TutorialStep(
      title: 'Pick a tone',
      body:
          'Warm, funny, formal, and more — the tone shapes how your message reads.',
      targetKey: tonePickerKey,
    ),
    TutorialStep(
      title: 'Generate messages',
      body:
          'Tap to create AI-powered options. Your pick saves automatically — touch up or share when ready.',
      targetKey: generateButtonKey,
    ),
    const TutorialStep(
      title: 'Ready to go',
      body:
          'Generate a few options, pick your favorite, and share it when the day arrives.',
    ),
  ];
}
