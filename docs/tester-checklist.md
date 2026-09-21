# Cyclea tester checklist

Use guest mode first if you do not want to sign in. Seeded demo data is the fastest way to exercise Insights.

## Guest / local

- [ ] First launch shows the full medical / contraception disclaimer plus **Continue as guest** and **Continue with Google**. Guest enters Home.
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

## Google Sign-In (Firebase project cyclea-db587)

- [ ] Settings shows **Continue as guest** and **Continue with Google** in guest mode.
- [ ] Web: **Continue with Google** opens the Google account picker on `localhost` and on `https://michaelady.github.io/Cyclea/` (authorized domain is set). A failed popup shows a snackbar; guest keeps working.
- [ ] Android: sign-in works on a device/emulator only after debug/release **SHA-1** is added in Firebase Console for `com.cyclea.app`. Until then Google Sign-In fails; guest mode still works.
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
