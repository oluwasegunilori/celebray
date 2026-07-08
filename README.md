# Celebray

**Celebray** helps you remember and celebrate important dates — birthdays, anniversaries, graduations, and more — with smart reminders, personalized messages, and shareable greeting cards.

## Features

- Reminders list with rich event profiles (relationship, closeness, memories)
- Calendar view of upcoming celebrations
- Local notifications at midnight on the celebration day
- AI-style message generator (9 tones: warm, funny, formal, prayerful, romantic, casual, brief, heartfelt, poetic)
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
dart run tool/generate_splash_icon.dart
dart run flutter_native_splash:create
dart run tool/generate_splash_icon.dart
flutter run
```

## Store Release Checklist

1. Create Android upload keystore and `android/key.properties` (see `key.properties.example`)
2. Run `dart run flutter_launcher_icons` and `dart run tool/generate_splash_icon.dart
dart run flutter_native_splash:create
dart run tool/generate_splash_icon.dart`
3. Deploy legal pages: `firebase deploy --only hosting` (see Store URLs below)
4. Add App Store / Play Store screenshots
5. Run `flutter analyze` and `flutter test` before submitting

## Store URLs

Use these when submitting to the App Store and Google Play:

| Field | URL |
| --- | --- |
| Privacy Policy | https://celebray.web.app/privacy |
| Terms of Service | https://celebray.web.app/terms |
| Support URL | https://celebray.web.app/support |
| Marketing / Website | https://celebray.web.app |

Deploy with `firebase deploy --only hosting`.

## TestFlight (Fastlane)

Prerequisites: Apple Developer Program, Xcode signing for `com.shegz.celebray`, and an app record in App Store Connect.

```bash
# One-time setup
cd ios
bundle install
cp fastlane/.env.example fastlane/.env
# Edit fastlane/.env with App Store Connect API key (recommended)

# Load env + build + upload
set -a && source fastlane/.env && set +a
bundle exec fastlane beta

# Build IPA only
bundle exec fastlane build

# Upload an existing IPA (after flutter build ipa)
bundle exec fastlane upload
```

Bump `version: x.y.z+build` in `pubspec.yaml` before each upload (build number must increase).

Create an API key at [App Store Connect → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api). Grant **Developer** or **App Manager** role.

## Legal

Source documents (also published at the URLs above):

- [Privacy Policy](docs/privacy_policy.md)
- [Terms of Service](docs/terms_of_service.md)
