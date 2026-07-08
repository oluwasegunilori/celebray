import 'package:celebray/core/tutorial/feature_tutorial_overlay.dart';
import 'package:flutter/material.dart';

List<TutorialStep> buildShareTutorialSteps({
  required GlobalKey colorKey,
  required GlobalKey typographyKey,
  required GlobalKey previewKey,
  required GlobalKey shareActionsKey,
}) {
  return [
    const TutorialStep(
      title: 'Share your greeting',
      body:
          'Customize how your message looks, preview it, then send as a card image or plain text.',
    ),
    TutorialStep(
      title: 'Pick a color',
      body: 'Choose a background that fits the mood of your celebration.',
      targetKey: colorKey,
    ),
    TutorialStep(
      title: 'Text style',
      body: 'Switch fonts to match the tone — elegant, playful, or bold.',
      targetKey: typographyKey,
    ),
    TutorialStep(
      title: 'Preview',
      body: 'See exactly how your card will look before you share it.',
      targetKey: previewKey,
    ),
    TutorialStep(
      title: 'Send it',
      body:
          'Share Card saves a beautiful image. Share as Text sends the message ready to paste.',
      targetKey: shareActionsKey,
    ),
    const TutorialStep(
      title: 'Done',
      body: 'Share however you like — Messages, WhatsApp, Instagram, and more.',
    ),
  ];
}
