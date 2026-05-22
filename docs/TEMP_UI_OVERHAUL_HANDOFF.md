# Temporary UI Overhaul Handoff

This is a temporary handoff note for the next agent. Delete this file after the UI overhaul work is picked up or converted into permanent docs/issues.

## Current State

- Repo: `C:\Users\maged\.codex\worktrees\621d\zim`
- Branch: `modernize-2026`
- Do not commit yet; the user explicitly said to forget committing for now.
- The project was modernized from an old Flutter/Android baseline and now builds again.
- Verification already passed:
  - `flutter analyze`
  - `flutter test`
  - `flutter pub outdated --no-transitive`
  - `flutter build apk --debug`
  - `flutter build apk --release`
- Emulator launch mostly worked, but the emulator had low storage and ADB reported `INSTALL_FAILED_INSUFFICIENT_STORAGE` during one reinstall. The app package `dev.maiz.zim` was installed and running afterward.

## Important Modernization Changes

- Android Gradle moved from Groovy to Kotlin DSL:
  - `android/settings.gradle.kts`
  - `android/build.gradle.kts`
  - `android/app/build.gradle.kts`
- Dependencies were updated in `pubspec.yaml`; direct/dev deps are currently up to date.
- Removed `isolate_handler` because its transitive Android plugin blocked AGP 8 builds.
- Replaced:
  - `device_apps` with `flutter_device_apps`
  - `mime_type` with `mime`
- Launcher icons and native splash resources were regenerated.
- `dart format lib test` touched many files, so expect wide formatting diff noise.

## Next Task

The app needs a UI overhaul because many screens overflow or are brittle on modern devices. Focus on fixing responsive layout, text overflow, and scroll behavior before visual polish.

### Pass 1 — landed (responsive / overflow fixes, uncommitted)

- `lib/screens/get_started.dart` — `Positioned`-percentage layout replaced with `SafeArea` + `LayoutBuilder`; folder backdrop now built via a loop with clamped step/offset, and the headline/sub/Get Started button live in a single bottom-anchored `Column` so the layout survives short devices.
- `lib/screens/main/browse.dart` — body wrapped in `SafeArea` + `SingleChildScrollView(AlwaysScrollableScrollPhysics)` so storage + categories never get cropped and `RefreshIndicator` still works.
- `lib/widgets/storage/storage_section.dart` — fixed `deviceHeight * 0.48` height removed, dropdown logic simplified, clamps to a safe index, handles empty/zero-totalSpace paths.
- `lib/widgets/storage/storage_item.dart` — `CircularPercentIndicator` radius is now `LayoutBuilder`-driven and clamped (70–120). Percent label uses `FittedBox` so 32pt scales down on narrow phones. Used/Free row uses `Expanded` legend tiles with `Flexible` text + ellipsis instead of a fixed-width Row.
- `lib/widgets/category/category_section.dart` — fixed `deviceHeight * 0.3` height removed, switched to `GridView.builder(shrinkWrap: true, NeverScrollableScrollPhysics)` so it sizes itself inside the new scroll view.
- `lib/widgets/category/category_item.dart` — tile uses `Expanded` + `AspectRatio` instead of `deviceHeight * 0.08`, label has `maxLines: 1` + ellipsis.
- `lib/screens/folder.dart` — AppBar title and path get `maxLines: 1` + ellipsis so deep paths don't blow out the bar.
- `lib/widgets/dialogs/{add_file,rename_file,decompress_archive}_dialog.dart` — fixed-width 130×40 buttons replaced with a shared `DialogActions` (new file: `lib/widgets/dialogs/dialog_actions.dart`) that uses `Expanded` buttons and theme-aware colors (no more raw `Colors.white` cancel button). Rename logic also switched to `path_lib.join` on the directory name (the old `replaceAll(basename, '')` would corrupt paths whose directory contained the basename as a substring).

Verification after pass 1:

- `flutter analyze` — clean.
- `flutter test` — 3/3 passing.
- `flutter build apk --debug` — succeeds.
- Not yet emulator-verified after these edits.

### Pass 2 — landed

- `lib/screens/splash.dart` — wrapped in `SafeArea` so the logo isn't covered by status bar / display cutout on tall devices.
- `lib/widgets/file/file_item.dart` — `maxLines + ellipsis` on title and subtitle, and `lengthSync()` / `lastModifiedSync()` are now guarded by an `existsSync()` check + `FileSystemException` catch so a stale list (file deleted out from under us) doesn't crash the row build.
- `lib/widgets/dir_item.dart` — same maxLines/ellipsis treatment.
- `lib/screens/categories/recent.dart` — removed the `SingleChildScrollView` + `NeverScrollable` `ListView.separated` sandwich, filtered missing files up front, added explicit "No Files Found" empty state.
- `lib/widgets/custom_alert.dart` — replaced full-screen Stack/Expanded/Card with a real Material `Dialog` (insetPadding + clipBehavior + maxWidth 480) so dialogs honor Material insets and behave correctly with the keyboard.
- `lib/widgets/app_drawer.dart` — replaced `EdgeInsets.only(top: 100)` with `SafeArea`, smaller (140) and clipped logo container, removed unused `theme_config` import.
- `lib/widgets/storage/storage_item.dart` — switched the storage Device/SD dropdown to a direct `DropdownMenuItem<String>` list comprehension. `Constants.map` is untyped, which caused a runtime "DropdownMenuItem<Object> is not a subtype of DropdownMenuItem<String>" crash the moment a second storage volume (SD) was present.
- `docs/ui-screenshots/` — captured emulator screenshots (Pixel 8a, Android 16) of the responsive Get Started screen for visual regression reference.

Verification after pass 2:

- `flutter analyze` — clean.
- `flutter test` — 3/3 passing.
- `flutter build apk --debug --target-platform android-x64` — succeeds.
- Emulator (Pixel 8a, API 36, `MANAGE_EXTERNAL_STORAGE` granted via `appops`): app launches, splash → Get Started renders correctly. The earlier `DropdownMenuItem<Object>` crash on Browse is fixed.

### Outstanding / pass 3 ideas

Likely visual-polish fixes (do after the overflow pass is verified on more devices):

- Replace ad-hoc colors with `Theme.of(context).colorScheme` references.
- Standardize radius/padding tokens (currently a mix of 5, 8, 10, 15, 20, 40).
- Consider a real Material 3 `NavigationBar` / `NavigationRail` instead of the current drawer-only nav on wide screens.
- The Get Started layered-folder backdrop is a creative liability; consider a single illustration asset instead of stacked folder glyphs.

Untouched but worth a look in a future pass:

- `lib/screens/categories/{category_one,category_two,apps,archives,downloads}.dart` — list/grid layouts look fine but were not emulator-verified end-to-end.
- `lib/screens/main/share.dart` and `lib/screens/main/settings.dart` — not opened during this overhaul.
- The dropdown bug fix in `storage_item.dart` is a strong hint that `Constants.map` (in `lib/utils/consts.dart`) deserves a generic-aware refactor — every other caller currently relies on call-site type annotation (`Constants.map<Widget>(...)`).

## Suggested Skills

- `impeccable`: primary skill for frontend/UI audit and responsive overhaul.
- `redesign-existing-projects`: useful if doing a broader visual refresh after fixing overflow.
- `diagnose`: use if a specific screen crashes or overflows and needs a reproduce-minimize-fix loop.

## Keep Green

After each slice, run:

```sh
flutter analyze
flutter test
flutter build apk --debug
```

For emulator testing, make sure the emulator has enough free `/data` space before reinstalling the APK.
