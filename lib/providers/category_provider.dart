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
      final allFiles = await FileUtils.getAllFiles(showHidden: showHidden);
      final (matched, tabList) = classify(
        allFiles.map((file) => file.path).toList(),
        type,
      );
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
    notifyListeners();
  }

  Future<void> getHidden() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    bool h = preference.getBool('hidden') ?? false;
    setHidden(h);
  }

  Future<void> setSort(int value) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setInt('sort', value);
    sort = value;
    notifyListeners();
  }

  Future<void> getSort() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    int h = preference.getInt('sort') ?? 0;
    setSort(h);
  }
}
