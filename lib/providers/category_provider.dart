import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:zim/models/entry.dart';
import 'package:zim/services/file_repository.dart';
import 'package:zim/utils/design_tokens.dart';
import 'package:zim/utils/file_utils.dart';

class CategoryProvider extends ChangeNotifier {
  static const FileRepository _repo = FileRepository();

  bool loading = false;
  List<Entry> downloads = <Entry>[];
  List<String> downloadTabs = <String>[];

  List<Entry> thumbnailFiles = <Entry>[];
  List<String> thumbnailTabs = <String>[];

  List<Entry> nonThumbnailFiles = <Entry>[];
  List<String> nonThumbnailTabs = <String>[];

  List<Entry> currentFiles = [];

  /// Synced from [SettingsProvider] via a ChangeNotifierProxyProvider; not
  /// persisted here. Changing it invalidates the scan cache without notifying
  /// the file-list consumers (they refetch on their next open).
  bool showHidden = false;

  /// Cached full-device scan. The walk is expensive and was re-run on every
  /// category open / search keystroke; we scan once, off the UI isolate, and
  /// let each category [classify] from this list.
  List<Entry>? _scanCache;

  /// All entries on the device, scanned once and cached. Pass [refresh] to
  /// force a re-scan (pull-to-refresh / returned-to-foreground / hidden toggle).
  Future<List<Entry>> allEntries({bool refresh = false}) async {
    if (!refresh && _scanCache != null) return _scanCache!;
    _scanCache = await _repo.scan(showHidden: showHidden);
    return _scanCache!;
  }

  /// Drops the cached device scan so the next category open / search re-walks.
  /// Wired to pull-to-refresh on Browse.
  void invalidateScan() => _scanCache = null;

  /// Syncs the show-hidden preference from [SettingsProvider]. Invalidates the
  /// scan cache on change but does NOT notify — file lists refetch on their
  /// next open, so a settings toggle shouldn't rebuild them mid-scroll.
  void applyShowHidden(bool value) {
    if (showHidden == value) return;
    showHidden = value;
    _scanCache = null;
  }

  /// File-name search over the cached scan — no filesystem re-walk per query.
  Future<List<Entry>> search(String query) async {
    final q = query.toLowerCase();
    final entries = await allEntries();
    return [
      for (final entry in entries)
        if (entry.name.toLowerCase().contains(q)) entry,
    ];
  }

  Future<void> getDownloads() async {
    await getFiles('downloads', downloads, downloadTabs, 'Download');
  }

  Future<void> getThumbnailFiles(String type) async {
    await getFiles(type, thumbnailFiles, thumbnailTabs);
  }

  Future<void> getNonThumbnailFiles(String type) async {
    await getFiles(type, nonThumbnailFiles, nonThumbnailTabs);
  }

  /// The immediate parent directory name of [path] (the tab a file belongs to).
  static String _parentDirName(String path) {
    final parts = path.split('/');
    return parts.length >= 2 ? parts[parts.length - 2] : '';
  }

  /// The [FileKind] a category [type] string selects for.
  static FileKind _kindForType(String type) {
    switch (type) {
      case 'application':
        return FileKind.apk;
      case 'archive':
        return FileKind.archive;
      case 'text':
        return FileKind.document;
      case 'image':
        return FileKind.image;
      case 'video':
        return FileKind.video;
      case 'audio':
        return FileKind.audio;
      default:
        return FileKind.generic;
    }
  }

  /// Pure classification: returns the entries matching [type] and the set of tab
  /// names (parent dirs) they fall under, with 'All' first. No I/O, no notify —
  /// unit-testable in isolation. Matches on the prefetched [Entry.kind].
  static (List<Entry>, List<String>) classify(
    List<Entry> entries,
    String type,
  ) {
    final target = _kindForType(type);
    final matched = <Entry>[];
    final tabs = <String>{'All'};
    for (final entry in entries) {
      if (entry.kind == target) {
        matched.add(entry);
        tabs.add(_parentDirName(entry.path));
      }
    }
    return (matched, tabs.toList());
  }

  /// Entries in [files] that belong to the tab named [label] (i.e. whose
  /// immediate parent directory is [label]). Synchronous, pure — used to drive
  /// per-tab views without re-walking or re-splitting paths in the widget.
  List<Entry> filesForTab(List<Entry> files, String label) {
    return [
      for (final file in files)
        if (_parentDirName(file.path) == label) file,
    ];
  }

  Future<void> getFiles(
    String type,
    List<Entry> files,
    List<String> tabs, [
    String? dirName,
  ]) async {
    setLoading(true);
    files.clear();
    tabs.clear();
    try {
      if (dirName != null) {
        final tabSet = <String>{'All'};
        final storages = await FileUtils.getStorageList();
        for (final dir in storages) {
          final target = '${dir.path}$dirName';
          if (!Directory(target).existsSync()) continue;
          for (final entry in _repo.listEntries(
            target,
            showHidden: showHidden,
          )) {
            if (!entry.isDir) {
              files.add(entry);
              tabSet.add(_parentDirName(entry.path));
            }
          }
        }
        tabs.addAll(tabSet);
      } else {
        final entries = await allEntries();
        final (matched, tabList) = classify(entries, type);
        files.addAll(matched);
        tabs.addAll(tabList);
        currentFiles = files;
      }
    } finally {
      // Always clear the spinner, even if the scan/listing threw.
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
