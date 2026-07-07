# Celebray

**Celebray** helps you remember and celebrate important dates — birthdays, anniversaries, graduations, and more — with smart reminders, personalized messages, and shareable greeting cards.

## Features

- Reminders list with rich event profiles (relationship, closeness, memories)
- Calendar view of upcoming celebrations
- Local notifications (7-day advance + day-of)
- AI-style message generator (warm, funny, formal tones)
- Shareable greeting cards as PNG
- Optional Google / Apple sign-in
- Photo attachments for events

## Tech Stack

- Flutter + Material 3
- Riverpod for state management
- sqflite for local storage
- Firebase Auth + Crashlytics
- flutter_local_notifications
- table_calendar, share_plus, image_picker

## Getting Started

```bash
git clone <your-repo-url>
cd celebray
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter run
```

## Store Release Checklist

1. Create Android upload keystore and `android/key.properties` (see `key.properties.example`)
2. Run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`
3. Host `docs/privacy_policy.md` and update URLs in `lib/constants/app_constants.dart`
4. Add App Store / Play Store screenshots
5. Run `flutter analyze` and `flutter test` before submitting

## Legal

- [Privacy Policy](docs/privacy_policy.md)
- [Terms of Service](docs/terms_of_service.md)
