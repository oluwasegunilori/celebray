# Privacy Policy

**Last updated:** July 7, 2026

Celebray ("we", "our", or "the app") is a celebration reminder app developed by Shegz. This policy explains how we handle your information.

## Summary

- **Celebration events and photos** stay on your device unless you choose to share them yourself.
- **Sign-in is optional.** You can use Celebray without a Google or Apple account.
- **AI features** send celebration details you include to our servers and to OpenAI to generate messages.
- **We do not sell your data** and we do not use it for cross-app advertising or tracking.

## Information Stored on Your Device Only

The following stays in local storage on your device and is **not** uploaded to our cloud:

- Celebrations you add (names, dates, relationships, closeness, memories, photos)
- Notification schedules for celebration-day alerts
- Your profile name, email, and photo after sign-in (stored in secure local storage)
- Calendar suggestions when you use calendar import (processed on device)

Uninstalling the app removes locally stored celebration data.

## Information We Collect

"Collect" means data transmitted off your device in a way that we or our service providers can access for longer than needed to handle a single real-time request.

### Account and identifiers

- **Name and email address** — if you sign in with Google or Apple (via Firebase Authentication)
- **User ID** — a Firebase user identifier for all users, including guest AI (anonymous sign-in), used for authentication and AI rate limits

### User content (AI features)

When you use AI message generation or touch-up, we send celebration details you provide, such as:

- Person's name, event type, and relationship
- Optional memories, tone, and faith context
- Message text and edit instructions (for touch-up)

This data is processed on Google Cloud Functions and forwarded to **OpenAI** to generate responses. We do not permanently store the content of AI requests on our servers. OpenAI processes data under its own privacy policy.

### Optional sensitive information

If you choose a **faith context** for a celebration, that religious preference may be included in AI requests. This is optional and only sent when you use AI features.

### Usage data

- **AI usage counters** — we store a daily request count per Firebase user ID in Firestore to enforce rate limits (10/day for guests, 20/day for signed-in users)

### Diagnostics

- **Crash data** — anonymous crash reports via Firebase Crashlytics to improve app stability

## How We Use Information

- To send a **midnight notification on the celebration day** with quick access to share your message
- To generate and refine celebration messages when you use AI features
- To authenticate your account when you choose to sign in
- To enforce fair-use limits on AI features
- To diagnose and fix crashes

## What We Do Not Collect

We do not collect location, contacts, health or financial data, browsing history, or in-app purchase history. We do not upload your event photos to our servers. We do not use advertising SDKs or collect data for cross-app tracking.

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
