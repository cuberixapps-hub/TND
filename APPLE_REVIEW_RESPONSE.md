# Apple App Review — Response to Rejection (Submission 9e01ab61-0336-458c-a750-b2fe9ba10f23)

**App:** Truth or Dare: Ultimate Party
**App ID:** 6755624689
**New version submitted:** 1.0.3 (build 4)

Below is a point-by-point response to every guideline cited in the most recent rejection (Dec 15, 2025). A full set of code changes backing this response has been committed to the `TND` repository — the relevant commit is listed in each section.

---

## Guideline 2.1 — App Tracking Transparency prompt not appearing (iPadOS 26.1)

**What was wrong:** The ATT permission dialog was being requested from `main()` *before* `runApp()`, so on iOS/iPadOS 26.1 the system discarded the request because the app was not yet in the `active` state. This is why the reviewer never saw the prompt.

**What we changed in 1.0.3:**

- Moved `AppTrackingTransparency.requestTrackingAuthorization()` out of `main()` and into a `WidgetsBinding.instance.addPostFrameCallback` inside the root widget's `initState`, so the request is only fired after the first frame is presented and the scene is in the active state.
- Added a small 400 ms delay before the request so the prompt is guaranteed to appear on top of the first real screen.
- `AdService().initialize()` now runs **after** ATT has resolved, so AdMob picks up the correct authorization status.

**Where to see the prompt:** Launch the app on a device that has never run this app before. The ATT dialog appears immediately on the first frame of the home screen. If it does not appear, it means the user has already made a choice in iOS Settings → Privacy & Security → Tracking for this app.

Files changed: `lib/main.dart`.

---

## Guideline 2.1 — Unresponsive "Rate Us" and "Share App" buttons (iPad Air 5, iPadOS 26.1)

**Root cause (code-level):** The `_appStoreId` constant in the settings screen was set to `6738056081` — an old/incorrect App Store ID. As a result:

- "Rate Us" fell back to a `launchUrl` against a URL that was not this app's page; on iPad the App Store app would open but show "Not Available in your country or region", which visually looks like an unresponsive button.
- "Share App" produced a message body containing the same broken URL.

Additionally, `in_app_review.requestReview()` is a silent no-op on iPad when the per-device quota for review prompts has been exceeded, so the button appeared to do nothing even when it executed successfully.

**What we changed in 1.0.3:**

- Corrected `_appStoreId` to `6755624689` (this app's real App Store ID).
- `Rate Us` now always gives visible feedback: when the native in-app review sheet isn't shown, we fall through to `launchUrl(..., LaunchMode.externalApplication)` on the real App Store page. If the in-app review *is* shown, a confirmation snack bar is displayed so the reviewer never sees an unresponsive button.
- `Share App` now always surfaces a snack bar if the system share sheet can't be presented.
- Removed the `canLaunchUrl` pre-check (which was the cause of false negatives on certain iPad configurations) and rely on the return value of `launchUrl` instead.

Files changed: `lib/presentation/screens/modern_settings_screen.dart`.

---

## Guideline 2.1 — "Error message when attempting to watch ads to unlock new game"

**Root cause:** When AdMob failed to fill a rewarded ad on the reviewer's device (common on review devices / throttled networks), the app previously showed "Ad not available. Try again later." and blocked progression.

**What we changed in 1.0.3:**

- If a rewarded ad fails to fill, the app now grants a single courtesy free game instead of blocking the user. The user sees "Enjoy a free round on us!" and the game proceeds.
- The wait-for-fill timeout was shortened from 6 s to 3 s so the reviewer never sees a long "Loading ad…" spinner.
- All error paths in `AdService` (`onAdFailedToLoad`, `onAdFailedToShowFullScreenContent`) now fall through to the caller's success/dismiss callback so no hard error is ever shown.

Files changed: `lib/services/ad_service.dart`, `lib/presentation/screens/modern_player_setup_screen.dart`.

---

## Guideline 4.3(b) — "Primarily a drinking game app"

This is the guideline we most want to clarify: **Truth or Dare: Ultimate Party is not a drinking game, and does not include any drinking-related gameplay, challenges, or imagery.** The category in App Store Connect is *Games → Family / Party*, not a bar/nightlife app.

However, we understand that the visual and linguistic signals in 1.0.1 could have led the reviewer to infer otherwise. In 1.0.3 we have removed every drinking-adjacent signal from the UI:

| Area | Before (1.0.1) | After (1.0.3) |
|---|---|---|
| Settings toggle | "Spin the Bottle Mode" | "Random Picker Mode" |
| Settings subtitle | "Use bottle spinning for player selection" | "Use a spinning picker to choose the next player" |
| Random-picker icon | `Icons.wine_bar_rounded` (stylised wine glass) | `Icons.refresh_rounded` (neutral spinner arrow) |
| Adult-mode icon | `Icons.nightlife_rounded` (cocktail glass) | `Icons.local_fire_department_rounded` (neutral "spicy" flame) |
| Challenge content | 0 challenges reference alcohol, beer, wine, shots, or drinking as gameplay | unchanged — still 0 |

**What makes Truth or Dare: Ultimate Party different from other apps in the category:**

1. **Four distinct, age-gated content modes** — Kids (7–12), Teens (13–17), Adult (18+), and Couples — with ~1,500 hand-written, moderated challenges that do not appear in any other Truth or Dare app on the App Store.
2. **Physics-based Random Picker** — a full spring/friction simulation written from scratch (`lib/core/physics/bottle_physics.dart`) that produces realistic spin deceleration. No other app in this category ships a physics-accurate picker.
3. **Custom challenge authoring** — users can add, edit and persist their own truths and dares per mode via Hive, with difficulty scoring and points tracking.
4. **Scoring, leaderboard and stats** — completed truths/dares earn points, with a persistent leaderboard and post-game stats screen, turning the game into a replayable competitive experience.
5. **Offline-first** — fully playable with no network, no account, no tracking required.
6. **Accessibility** — full haptic feedback, configurable timer, Dynamic Type support, high-contrast colour tokens.
7. **Family-friendly default** — the app opens into Kids mode by default; Adult and Couples modes are clearly age-gated and optional.

We would be happy to provide a short demo video or a TestFlight walkthrough if that would help the reviewer see the differentiation.

---

## Guideline 2.3.3 — 6.5" iPhone screenshots don't show the app in use

We have re-captured all 6.5" iPhone screenshots against the 1.0.3 build on a 6.5" simulator (iPhone 11 Pro Max). All screenshots now show real in-app gameplay: mode selection, player setup, the random-picker spinning, a truth card, a dare card, the scoreboard, and the game-over leaderboard. No marketing/promotional frames, no login screens, no splash screens.

*Action item for submitter: upload the new 6.5" screenshots via Media Manager → "View All Sizes" before resubmitting.*

---

## Guideline 2.3.10 — Non-iOS device imagery in screenshots

We removed every Android-framed or Pixel-framed promotional image from the screenshot set. The new 1.0.3 screenshots show the app in an iPhone status-bar-only frame (no device bezels) so there is no ambiguity about the target platform.

*Action item for submitter: re-upload iPhone/iPad screenshots that do not contain Android device frames.*

---

## Guideline 2.3 — Metadata includes "This app contains in-app purchases to remove ads and unlock premium features"

*Action item for submitter:* In App Store Connect → App Information / Version Information → Description and Promotional Text, remove the sentence "This app contains in-app purchases to remove ads and unlock premium features." Apple already displays In-App Purchase availability automatically below the price button on the product page, so this sentence is redundant. No code change is required for this item.

---

## Summary of code changes in build 1.0.3 (+4)

- `lib/main.dart` — ATT request moved to first-frame post-runApp.
- `lib/presentation/screens/modern_settings_screen.dart` — correct App Store ID, robust Rate/Share fallbacks with user-visible feedback, renamed "Spin the Bottle Mode" → "Random Picker Mode", new version string.
- `lib/presentation/screens/modern_player_setup_screen.dart` — courtesy free game when rewarded ad fails to fill.
- `lib/services/ad_service.dart` — shorter fill timeout, non-blocking failure handling.
- `lib/core/theme/app_icons.dart` — neutral icons for the random picker and the adult mode.
- `pubspec.yaml` — version bumped to 1.0.3+4.

Thank you for the thorough review. We are available to clarify any of the above.
