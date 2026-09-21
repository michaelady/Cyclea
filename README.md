# Cyclea

Cyclea is a privacy-respecting menstrual cycle tracker for **web** and **Android**. It covers table-stakes logging and calendar predictions, then differentiates on **personal statistics** and **short educational advice**.

**Cyclea is not medical advice, not a medical device, and not contraception.** Predictions are calendar estimates from dates you log. They can be wrong — especially with irregular cycles. Do not use Cyclea to avoid or achieve pregnancy. If you have concerns about your cycle or health, talk to a qualified clinician.

Public web build (once GitHub Pages is enabled): [https://michaelady.github.io/Cyclea/](https://michaelady.github.io/Cyclea/)

Privacy page: [https://michaelady.github.io/Cyclea/privacy.html](https://michaelady.github.io/Cyclea/privacy.html)

## Competitive map

| Capability | Cyclea | Flo | Clue | Period Calendar |
| --- | --- | --- | --- | --- |
| Period + flow logging | Yes | Yes | Yes | Yes |
| Daily symptoms | 24 curated | Very large catalog | Science-oriented catalog | Basic |
| Next period estimate | Calendar + uncertainty band | Yes | Yes | Yes |
| Fertile window | Calendar estimate + disclaimer | Yes (broader product) | Yes | Often yes |
| Guest / local-first | First-class Hive storage | Account-heavy | Account-centric | Local |
| Google + Firestore sync | Optional Google Sign-In (cyclea-db587) | Cloud account | Cloud account | Usually none |
| Personal stats (average, variability, early/late vs *your* mean) | **Core differentiator** | Some insights | Strong science framing | Limited |
| Educational advice cards | **Non-diagnostic, stats-aware** | Content library | Articles | Sparse |
| Contraception / pregnancy tools | **Out of scope** | Present | Present | Sometimes |
| Wearables, community, partner sharing, iOS App Store | Phase 2+ / out of scope | Yes / mixed | Mixed | No |

Cyclea’s bet: stay small, calm, and honest about uncertainty, and make **your** numbers (not a generic 28-day cartoon) the product.

## What Phase 1 includes

1. **Auth and sync** — Welcome and Settings both offer **Continue as guest** and **Continue with Google**. Google is optional. Guest mode works fully with Hive on-device storage. Firebase project **cyclea-db587** is wired for web + Android; web Google Sign-In should complete after Pages deploy. Android still needs a SHA-1 in the Firebase Console.
2. **Tracking** — Calendar logging of period start/end, flow (spotting / light / medium / heavy), and ~24 symptoms. Edit or delete any day. Range picker for a whole period.
3. **Predictions** — Next period and fertile window from logged cycle starts. Uncertainty widens for short histories and irregular cycles. Disclaimers on Home, Calendar, Insights, Settings, and this README.
4. **Insights** — Average cycle length, variability, early vs on-time vs late (±2 days from *your* average), symptoms by phase, educational advice cards.
5. **Settings** — Account, sync status, theme, seed demo data (for testers), privacy link, disclaimer, delete-all.
6. **Privacy** — No ads, no selling health data, easy delete-all, [`web/privacy.html`](web/privacy.html).
7. **Web publish** — GitHub Actions builds Flutter web from `main` onto `gh-pages`.
8. **Android** — `applicationId` `com.cyclea.app`.
9. **Quality** — Unit tests for cycle math, predictions, demo data, and guest UI smoke tests.

## Run locally

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.32+ (CI uses `stable`).

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
# or
flutter run -d android
```

Guest mode works without signing in. Use **Settings → Seed demo data** to populate ~six months of slightly irregular cycles.

The UI uses a warm botanical look (Fraunces headings, Figtree body, custom blossom / petal / sprout / moon icons). Google Sign-In is optional beside guest.

## Firebase (cyclea-db587)

Cyclea is wired to Firebase project **cyclea-db587**. Client config lives in [`lib/firebase_options.dart`](lib/firebase_options.dart) and [`android/app/google-services.json`](android/app/google-services.json) (package `com.cyclea.app`). These are standard public Firebase client identifiers, not server secrets.

- **Web Google Sign-In** uses Firebase Auth `signInWithPopup` against `authDomain` `cyclea-db587.firebaseapp.com`, with the web OAuth client `699763889491-fqjgp58darl1kg7pj096g9a15tpa30e9.apps.googleusercontent.com`. Authorized domain **michaelady.github.io** is already set in Firebase. After this branch merges and GitHub Pages deploys, **Continue with Google** on [https://michaelady.github.io/Cyclea/](https://michaelady.github.io/Cyclea/) should open the Google account picker. `localhost` should work for local `flutter run -d chrome` as well.
- **Android Google Sign-In** still needs a **debug and/or release SHA-1** (and SHA-256) added on the Firebase Android app (`com.cyclea.app`). That step was skipped at registration. Until fingerprints are in the Console, Google Sign-In on a device/emulator will fail even though `google-services.json` is present; guest mode stays usable. Add them with `keytool -list -v -keystore ~/.android/debug.keystore` (debug) and Play App Signing (release).
- Guest logging, predictions, and Insights never require Google. If Firebase fails to initialize, **Continue with Google** shows a clear error and guest keeps working.
- Cloud Firestore: publish rules such as [`firestore.rules`](firestore.rules) so users can only read and write `users/{uid}/**`. First sign-in merges local Hive logs with Firestore using last-write-wins on `updatedAt`. **Sign out** returns the account chip to Guest; logs are not wiped unless the user deletes them.

Restrict Firebase Auth domains and Firestore rules. Do not commit upload keystores or `.env` files.

## Android APK

```bash
flutter build apk --release --target-platform android-arm64
# artifact: build/app/outputs/flutter-apk/app-release.apk
```

- `applicationId`: `com.cyclea.app`
- `minSdk`: 23
- Release currently signs with the debug keystore so `flutter run --release` works. For Play, create an upload keystore and point `android/key.properties` at it (see Flutter’s [signing docs](https://docs.flutter.dev/deployment/android)).
- **Continue with Google** on Android needs SHA-1 / SHA-256 registered on the `com.cyclea.app` Android app in Firebase Console. Until then, guest mode still works.

## GitHub Pages

Workflow: [`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml)

On each push to `main` it runs tests, `flutter analyze`, and:

```bash
flutter build web --release --base-href /Cyclea/
```

then publishes `build/web` to the `gh-pages` branch.

Enable Pages in the GitHub repo: **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch `gh-pages` / root**. After the first green workflow, the app is at `https://michaelady.github.io/Cyclea/`.

## Privacy

- No advertisements.
- No sale of health data.
- Guest logs stay in Hive on the device (IndexedDB on web).
- Signed-in logs are stored under `users/{uid}/logs/{yyyy-MM-dd}` in your Firebase project. Cyclea does not operate a separate analytics company pipeline.
- **Settings → Delete all Cyclea data** clears local storage and, if signed in, the Firestore log collection.
- Full notice: [`web/privacy.html`](web/privacy.html).

## Tester checklist

See [`docs/tester-checklist.md`](docs/tester-checklist.md).

## Architecture notes

- Cycle length = days from one **period start** to the next. Lengths outside 10–90 days are ignored as implausible.
- On-time = within ±2 days of the user’s own mean.
- Fertile window = estimated ovulation at `cycleLength - 14`, then −5 / +1 days. That is a population heuristic, not an LH test.
- Irregular: sample standard deviation ≥ 8 **or** (max − min) ≥ 10 among logged cycle lengths.

## Out of scope (Phase 2+)

Wearables, community, pregnancy / TTC mode, partner sharing, AI chatbot, iOS App Store.
