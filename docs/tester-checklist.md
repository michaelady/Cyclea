# Cyclea tester checklist

Use guest mode first (no Firebase keys required). Seeded demo data is the fastest way to exercise Insights.

## Guest / local

- [ ] First launch shows the full medical / contraception disclaimer. The app does not enter Home until **I understand — continue**.
- [ ] Home, Calendar, and Insights still show a short disclaimer strip after acceptance.
- [ ] Settings repeats the full disclaimer and privacy summary.
- [ ] With empty data, Home asks you to log a period and does not invent a confident next-period date.
- [ ] **Calendar → Log period range** marks consecutive days. Flow is heavy → medium → light by default; a day can be edited.
- [ ] Tapping a day opens the editor. Period toggle, flow chips, ~24 symptoms, notes, Save, Delete day.
- [ ] After two period starts, Home shows cycle day, next period, fertile window, and a confidence / uncertainty caption.
- [ ] Irregular spacing (for example 21 then 35 days) widens uncertainty and can flag Insights as more variable.
- [ ] **Settings → Seed demo data** fills ~six months. Home ring, Calendar colors, and Insights averages populate.
- [ ] Calendar legend: rose = logged period, sage = fertile estimate, sand = predicted period (plus a lighter uncertainty band).
- [ ] Insights: average cycle, variability, period length, range, early / on-time / late bars, symptoms by phase, advice cards.
- [ ] Advice never claims diagnosis or contraception. At least one card says estimates are not a method to avoid or achieve pregnancy.
- [ ] **Settings → Delete all Cyclea data** requires confirmation and returns the app to an empty guest state.
- [ ] Theme segmented control (system / light / dark) changes surfaces without losing logs.
- [ ] Wide browser window uses a navigation rail; narrow uses a bottom bar. All four destinations work: Home, Calendar, Insights, Settings.
- [ ] Refresh on web keeps guest logs (Hive / IndexedDB).

## Google Sign-In (only after Firebase config)

- [ ] Settings shows **Continue with Google** when `lib/firebase_options.dart` is configured; otherwise it explains guest-only mode.
- [ ] Web sign-in popup works on `localhost` and on `michaelady.github.io` after authorized domains / OAuth origins are set.
- [ ] Android sign-in works on a device/emulator with `google-services.json` and SHA-1 registered.
- [ ] After sign-in, a log created as guest appears in Firestore `users/{uid}/logs/{date}`.
- [ ] Sign out returns to guest label; local logs remain until delete-all.
- [ ] Delete-all while signed in removes Firestore documents as well as Hive.

## Quality gates

- [ ] `flutter test` passes.
- [ ] `flutter analyze` has no error-level issues.
- [ ] GitHub Action on `main` publishes `gh-pages` with `--base-href /Cyclea/`.
- [ ] `https://michaelady.github.io/Cyclea/privacy.html` loads (after Pages is enabled).
- [ ] Release APK builds: `flutter build apk --release` with `applicationId` `com.cyclea.app`.

## Explicit non-goals to watch for

- [ ] No pregnancy mode, no “safe days” as contraception, no wearable import, no community feed, no iOS project in this phase.
