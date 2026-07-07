# Privacy Policy

**Last updated:** July 7, 2026

Celebray ("we", "our", or "the app") is a celebration reminder app developed by Shegz. This policy explains how we handle your information.

## Information We Collect

- **Account information:** If you sign in with Google or Apple, we store your name, email, and profile photo locally on your device using secure storage. Guest AI uses Firebase Anonymous Authentication (a random user ID with no personal details).
- **Event data:** Celebrations you add (names, dates, relationships, memories, photos) are stored locally on your device in a SQLite database.
- **AI request data:** When you use AI message generation or touch-up, the app sends relevant celebration details (name, event type, relationship, memories, tone, and faith context if provided) to our servers for processing. We do not permanently store the content of these requests.
- **AI usage counters:** We store a daily request count per Firebase user ID in Firestore to enforce rate limits (10/day for guests, 20/day for signed-in users).
- **Crash reports:** Anonymous crash data may be collected via Firebase Crashlytics to improve app stability.

## How We Use Information

- To send a **midnight notification on the celebration day** with quick access to share your message
- To generate and refine celebration messages when you use AI features
- To authenticate your account when you choose to sign in
- To enforce fair-use limits on AI features

## Data Storage

All event data is stored **locally on your device**. We do not sync your celebrations to a cloud database in the current version.

AI message requests are processed transiently on Google Cloud Functions and forwarded to OpenAI. They are not saved as a permanent message history on our servers.

## Third-Party Services

- **Firebase Authentication** — sign-in with Google and Apple; anonymous auth for guest AI
- **Firebase Cloud Functions** — secure backend for AI message generation
- **Firebase Firestore** — daily AI usage counters only (not your events)
- **Firebase Crashlytics** — crash reporting
- **OpenAI** — processes celebration details you submit to generate message text. See [OpenAI's privacy policy](https://openai.com/policies/privacy-policy).
- **Google Sign-In / Sign in with Apple** — authentication

## Your Rights

You can delete your account and local profile data from Settings. You can delete individual events from the Reminders screen. Uninstalling the app removes all locally stored celebration data.

## Contact

For privacy questions, contact: privacy@celebray.app
