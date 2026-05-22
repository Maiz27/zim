import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zim/utils/file_utils.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider() {
    getHidden();
    getSort();
  }

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

  Future<void> getFiles(
    String type,
    List<FileSystemEntity> files,
    List<String> tabs, [
    String? dirName,
  ]) async {
    setLoading(true);
    tabs.clear();
    files.clear();
    tabs.add('All');
    if (dirName != null) {
      List<Directory> storages = await FileUtils.getStorageList();
      for (var dir in storages) {
        if (Directory('${dir.path}$dirName').existsSync()) {
          List<FileSystemEntity> dirFiles = Directory(
            '${dir.path}$dirName',
          ).listSync();
          for (var file in dirFiles) {
            if (FileSystemEntity.isFileSync(file.path)) {
              files.add(file);
              tabs.add(file.path.split('/')[file.path.split('/').length - 2]);
              tabs = tabs.toSet().toList();
              notifyListeners();
            }
          }
        }
      }
    } else {
      List<FileSystemEntity> allFiles = await FileUtils.getAllFiles(
        showHidden: showHidden,
      );
      processFilePaths(
        allFiles.map((file) => file.path).toList(),
        type,
        files,
        tabs,
      );
      currentFiles = files;
      setLoading(false);
    }
  }

  void processFilePaths(
    List<String> filePaths,
    String type,
    List<FileSystemEntity> files,
    List<String> tabs,
  ) {
    Set<String> tabs0 = tabs.toSet();
    for (var filePath in filePaths) {
      File file = File(filePath);
      if (shouldAddFile(file, type)) {
        files.add(file);
        tabs0.add(file.path.split('/')[file.path.split('/').length - 2]);
      }
      notifyListeners();
    }
    tabs
      ..clear()
      ..addAll(tabs0);
  }

  bool shouldAddFile(File file, String type) {
    switch (type) {
      case 'application':
        return extension(file.path) == '.apk';
      case 'archive':
        return [
          '.zip',
          '.rar',
          '.tar',
          '.gz',
          '.7z',
          '.zlib',
          'bz2',
          '.xz',
        ].contains(extension(file.path));
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
      if ('${file.path.split('/')[file.path.split('/').length - 2]}' == label) {
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
