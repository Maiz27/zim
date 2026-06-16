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

### Pass 3 — landed (full visual overhaul / design system)

The end-to-end Material 3 redesign is done and emulator-verified in both light and
dark. New design-system foundation (the contract every screen/widget reads from):

- `lib/utils/design_tokens.dart` (new) — `AppPalette` (brand hues), `AppSpacing`
  (4pt scale), `AppRadius` (8/12/16/24/28 + ready-made `BorderRadius`),
  `AppMotion` (calm ease-out durations/curves + stagger), and `FilePalette.of(kind,
  brightness)` returning a theme-aware icon + tonal-container colour pair per
  `FileKind`.
- `lib/utils/theme_config.dart` (rewritten) — real M3 `ColorScheme.fromSeed` from the
  brand teal for both brightnesses (the old config mis-assigned `surface`; fixed),
  a tuned `TextTheme`, and full component theming (AppBar is now surface-tinted, not
  a teal slab; Card, Filled/Outlined/Text/Elevated buttons, FAB, Dialog, BottomSheet
  w/ drag handle, Drawer, PopupMenu, TabBar, SnackBar, ProgressIndicator,
  InputDecoration, SegmentedButton, Divider, ListTile). `ThemeConfig.primary` etc. are
  kept only as brand-hue aliases.
- `lib/widgets/motion.dart` (new) — `AnimatedEntrance` (staggered fade+slide for
  list/grid items) and `PressableScale` (subtle scale-on-press; pointer-observer so it
  never eats gestures).
- `lib/widgets/empty_state.dart` (new) — one calm empty/placeholder state used across
  "no files", search misses and coming-soon screens.

Theming behaviour: `AppProvider` now stores a `ThemeMode` (key `theme_mode`:
`system`/`light`/`dark`, default **system**). `app.dart` passes `theme`+`darkTheme`+
`themeMode`, runs edge-to-edge, and sets a theme-aware transparent system-bar overlay
via `MaterialApp.builder`. Settings has a `System · Light · Dark` `SegmentedButton`
(the old boolean dark-mode switch is gone). NOTE: this changed the prefs key, so an
existing user's old `theme` value is ignored once (they fall back to System).

Every screen and widget was migrated off `ThemeConfig.*` / hardcoded
`Colors.*` / magic radii / magic font sizes onto the tokens above:
- Get Started: layered-folder identity kept but rebuilt on tokens, with a settled
  navy gradient panel under the copy and a staggered folder entrance.
- file_icon: hardcoded per-type Material colours replaced with `FilePalette` tonal
  chips. Storage/category panels are real tonal containers. Category tiles keep their
  per-category colour as a tonal chip + `PressableScale`. Dialog buttons are themed
  Filled/Outlined. Search dedup'd into one helper with real `Divider`s.
- Deleted the empty unused `lib/screens/category_one.dart`.

Verification after pass 3:

- `flutter analyze` — clean (No issues found).
- `flutter test` — 3/3 passing (theme test rewritten to assert the corrected
  brightness-matched surfaces instead of the old buggy assignment).
- `flutter build apk --debug` — succeeds.
- Emulator (Pixel 8a, API/Android, `MANAGE_EXTERNAL_STORAGE` granted): launches and
  was screenshot-verified across Get Started, Browse (storage + categories), drawer,
  folder list (dark), Settings (light + dark theme switching), and a file list with
  tonal file-type chips. See `docs/ui-screenshots/new_*.png`.

### Pass 4 — landed (architecture deepening)

Read-only architecture review (improve-codebase-architecture) was run, then all
findings were implemented. The data/domain layer is no longer raw `dart:io` and `Map`
literals leaking into widgets:

- New `lib/services/file_repository.dart` — the single seam for filesystem mutations
  (`list` / `delete` / `rename` / `createDirectory` / `extract`). Maps POSIX errno
  `FileSystemException`s to a typed `FileOpException` / `FileOpError` so the UI shows
  clear, recoverable messages instead of swallowing non-permission errors. `folder.dart`
  and all three dialogs now call the repository instead of inline `dart:io`.
- Typed `Category` model in `consts.dart` (with a lazy `WidgetBuilder` screen, so
  category screens aren't constructed at app start). `Constants.map<T>` (the untyped
  helper behind the old `DropdownMenuItem<Object>` crash) was deleted; all 6 call sites
  use Dart 3 `.indexed` / collection-for.
- Archive extension lists were consolidated to `FileUtils.archiveExtensions` (broad:
  icon/category/listing) and `FileUtils.extractableArchiveExtensions` (narrow: what the
  `archive` package can extract). Fixes the real bug where `.rar`/`.7z` offered a
  Decompress action that always failed, and the `'bz2'` (missing dot) that never matched.
  Decompress is now only offered for extractable formats.
- `CategoryProvider`: per-file `notifyListeners()` in loops removed (now one notify per
  refresh); pure, unit-tested `classify(paths, type)` extracted; repeated parent-dir
  string math folded into `_parentDirName`.
- `CoreProvider`: ~6 notifications per refresh collapsed to one; `MethodChannel`
  hoisted to a named seam. `storage_section.dart`: module-global `idx` moved into State,
  and the `split('Android')[idx]` indexing bug fixed to `.first`.
- `dir_item`/`file_item` now share `EntityTile`; `dir_popup`/`file_popup` replaced by one
  `EntityPopup` with a typed `EntityAction = void Function(int)`. `folder.dart` gained the
  missing `mounted` guards after awaits and uses `file is Directory` instead of
  `toString()` sniffing.
- Dead code removed: empty `lib/screens/category_one.dart`, commented `_RecentFiles`
  (browse), the commented video player (video_thumbnail), `// print` debris, the dead
  share branch in folder.dart, and the commented `fileExtension` getter.

Verification after pass 4:

- `flutter analyze` — clean.
- `flutter test` — 12/12 passing (9 new in `test/architecture_test.dart` covering the
  pure `classify` and the FileRepository list/create/rename/delete/extract ops against a
  real temp filesystem).
- `flutter build apk --debug` — succeeds.
- Emulator: folder browsing (FileRepository.list), the Add Folder dialog, and creating a
  folder were verified end-to-end (the new dir appeared on disk and in the refreshed
  list). See `docs/ui-screenshots/arch_*.png`.

### Pass 5 — landed (read-path deepening)

The second architecture review (the read/scan path) was implemented in full.
The device scan no longer runs on the UI isolate, no longer re-walks per
category/search, and rows no longer stat the disk during `build`.

- Quick wins: `search.dart` uses `file is Directory` (last `toString()`
  type-sniff gone); typed `_mediaTile`/`_apksTab` params; `path_bar` takes
  `List<String>`; `category_two` drives document tabs via a pure typed
  `CategoryProvider.filesForTab`; `getHidden`/`getSort` no longer re-persist
  what they just read; `FileUtils` lost its `Fluttertoast` + `decompressing`
  global. `apps.dart` now uses `DefaultTabController`/`TabBarView` (no `idx`).
- Performance: the recursive walk is offloaded to a background isolate via
  `compute` (`FileRepository.scanEntries`). `CategoryProvider` scans **once**
  into a cache, classifies every category from it, and `search()` filters the
  cache; the search delegate debounces (300ms). Browse pull-to-refresh and the
  hidden toggle invalidate the cache.
- Keystone `Entry` value type (`lib/models/entry.dart`): immutable
  path/name/isDir/size/modified/kind with a pure `kindOf`. The whole read path
  (scan/category/recent/search/folder lists + FileItem/DirectoryItem/FileIcon)
  now carries `Entry`. Reads live behind `FileRepository`
  (`scan`/`recent`/`listEntries`/`sortEntries`); the old `FileUtils` read
  statics and the orphaned `extensions.dart` were deleted.
- Per-row sync I/O removed: subtitle, media-grid size label, sort comparator
  and recent's existence filter read prefetched `Entry` fields instead of
  `existsSync`/`lengthSync`/`lastModifiedSync`/`statSync`.
- Cleanup: `SettingsProvider` (show-hidden + sort) extracted from
  `CategoryProvider` and wired via `ChangeNotifierProxyProvider` so a setting
  change no longer notifies the file-list consumers; `splash` permission
  request is bounded (no self-recursion); `CoreProvider.checkSpace`/
  `getRecentFiles` reset their loading flags in `finally`; `getStorageList` no
  longer force-unwraps; `storage_section` uses `removeDataDirectory`.

Verification after pass 5:

- `flutter analyze` — clean (No issues found).
- `flutter test` — 22/22 passing (added Entry.kindOf, sortEntries, scanEntries
  and the Entry-based classify tests).
- `flutter build apk --debug` — succeeds.
- Emulator-verified (Pixel_8a, API 36, `MANAGE_EXTERNAL_STORAGE` granted) with
  seeded test files: Browse (storage + grid), Documents/Images categories
  (classify-by-kind, parent-dir tabs, prefetched-size subtitles/overlays), tab
  switch, Recent (modified-desc, per-kind chips), folder browse + breadcrumb,
  sort-by-size (re-orders from prefetched Entry.size, persists), show-hidden
  toggle (persists), and debounced search — no freezes or crashes (logcat
  clean). See `docs/ui-screenshots/readpath_*.png`. Note recent is now sorted by
  modified (was last-accessed, which Android often disables). Image thumbnails
  rendered the error-fallback glyph only because the seed PNGs were 1×1; real
  photos decode normally.

### Outstanding / future ideas (optional)

- Consider a real Material 3 `NavigationRail` for wide screens/tablets (still
  drawer-only today).
- ~~A thin `Entry` value type produced by the repository~~ — done in pass 5.
  `folder.dart` still wraps `Entry` back into `File`/`Directory` for the repo's
  mutation API (`delete`/`rename` take `FileSystemEntity`); could widen those to
  take `Entry` if more mutation call sites appear.
- Optionally bundle a brand display font (currently the platform default Roboto with a
  tuned M3 type scale).

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
