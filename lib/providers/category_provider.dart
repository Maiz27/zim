import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zim/services/file_repository.dart';
import 'package:zim/utils/file_utils.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider() {
    getHidden();
    getSort();
  }

  static const FileRepository _repo = FileRepository();

  bool loading = false;
  List<FileSystemEntity> downloads = <FileSystemEntity>[];
  List<String> downloadTabs = <String>[];

  List<FileSystemEntity> thumbnailFiles = <FileSystemEntity>[];
  List<String> thumbnailTabs = <String>[];

  List<FileSystemEntity> nonThumbnailFiles = <FileSystemEntity>[];
  List<String> nonThumbnailTabs = <String>[];

  List<FileSystemEntity> currentFiles = [];

  bool showHidden = false;
  int sort = 0;

  /// Cached full-device scan (file paths). The walk is expensive and was
  /// re-run on every category open / search keystroke; we scan once, off the
  /// UI isolate, and let each category [classify] from this list.
  List<String>? _scanCache;

  /// All file paths on the device, scanned once and cached. Pass [refresh] to
  /// force a re-scan (pull-to-refresh / returned-to-foreground / hidden toggle).
  Future<List<String>> allFilePaths({bool refresh = false}) async {
    if (!refresh && _scanCache != null) return _scanCache!;
    _scanCache = await FileUtils.getAllFilePaths(showHidden: showHidden);
    return _scanCache!;
  }

  /// Drops the cached device scan so the next category open / search re-walks.
  /// Wired to pull-to-refresh on Browse.
  void invalidateScan() => _scanCache = null;

  /// File-name search over the cached scan — no filesystem re-walk per query.
  Future<List<FileSystemEntity>> search(String query) async {
    final q = query.toLowerCase();
    final paths = await allFilePaths();
    return [
      for (final path in paths)
        if (basename(path).toLowerCase().contains(q)) File(path),
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

  /// Pure classification: returns the files in [paths] matching [type] and the
  /// set of tab names (parent dirs) they fall under, with 'All' first. No I/O,
  /// no notify — unit-testable in isolation.
  static (List<FileSystemEntity>, List<String>) classify(
    List<String> paths,
    String type,
  ) {
    final matched = <FileSystemEntity>[];
    final tabs = <String>{'All'};
    for (final path in paths) {
      final file = File(path);
      if (shouldAddFile(file, type)) {
        matched.add(file);
        tabs.add(_parentDirName(path));
      }
    }
    return (matched, tabs.toList());
  }

  /// Files in [files] that belong to the tab named [label] (i.e. whose
  /// immediate parent directory is [label]). Synchronous, pure — used to drive
  /// per-tab views without re-walking or re-splitting paths in the widget.
  List<FileSystemEntity> filesForTab(
    List<FileSystemEntity> files,
    String label,
  ) {
    return [
      for (final file in files)
        if (_parentDirName(file.path) == label) file,
    ];
  }

  Future<void> getFiles(
    String type,
    List<FileSystemEntity> files,
    List<String> tabs, [
    String? dirName,
  ]) async {
    setLoading(true);
    files.clear();
    tabs.clear();
    if (dirName != null) {
      final tabSet = <String>{'All'};
      final storages = await FileUtils.getStorageList();
      for (final dir in storages) {
        final target = '${dir.path}$dirName';
        if (!Directory(target).existsSync()) continue;
        for (final file in _repo.list(target, showHidden: true)) {
          if (FileSystemEntity.isFileSync(file.path)) {
            files.add(file);
            tabSet.add(_parentDirName(file.path));
          }
        }
      }
      tabs.addAll(tabSet);
    } else {
      final paths = await allFilePaths();
      final (matched, tabList) = classify(paths, type);
      files.addAll(matched);
      tabs.addAll(tabList);
      currentFiles = files;
    }
    setLoading(false);
  }

  static bool shouldAddFile(File file, String type) {
    switch (type) {
      case 'application':
        return extension(file.path) == '.apk';
      case 'archive':
        return FileUtils.isArchive(file.path);
      case 'text':
        return [
          '.pdf',
          '.epub',
          '.mobi',
          '.doc',
          '.docx',
          '.json',
        ].contains(extension(file.path));
      default:
        String mimeType = lookupMimeType(file.path) ?? '';
        return mimeType.split('/')[0] == type;
    }
  }

  Future<void> switchCurrentFiles(List list, String label) async {
    List<FileSystemEntity> l = await compute(getTabImages, [list, label]);
    currentFiles = l;
    notifyListeners();
  }

  static Future<List<FileSystemEntity>> getTabImages(List item) async {
    List items = item[0];
    String label = item[1];
    List<FileSystemEntity> files = [];
    for (var file in items) {
      if (_parentDirName(file.path) == label) {
        files.add(file);
      }
    }
    return files;
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  Future<void> setHidden(bool value) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setBool('hidden', value);
    showHidden = value;
    _scanCache = null; // hidden toggle changes which paths the scan returns
    notifyListeners();
  }

  Future<void> getHidden() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    showHidden = preference.getBool('hidden') ?? false;
    notifyListeners();
  }

  Future<void> setSort(int value) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setInt('sort', value);
    sort = value;
    notifyListeners();
  }

  Future<void> getSort() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    sort = preference.getInt('sort') ?? 0;
    notifyListeners();
  }
}
