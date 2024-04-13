import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:mime_type/mime_type.dart';
import 'package:zim/utils/file_utils.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final isolates = IsolateHandler();

  getDownloads() async {
    await getFiles('downloads', downloads, downloadTabs, 'Download');
  }

  getThumbnailFiles(String type) async {
    await getFiles(type, thumbnailFiles, thumbnailTabs);
  }

  getNonThumbnailFiles(String type) async {
    await getFiles(type, nonThumbnailFiles, nonThumbnailTabs);
  }

  Future<void> getFiles(
      String type, List<FileSystemEntity> files, List<String> tabs,
      [String? dirName]) async {
    setLoading(true);
    tabs.clear();
    files.clear();
    tabs.add('All');
    if (dirName != null) {
      List<Directory> storages = await FileUtils.getStorageList();
      for (var dir in storages) {
        if (Directory('${dir.path}$dirName').existsSync()) {
          List<FileSystemEntity> dirFiles =
              Directory('${dir.path}$dirName').listSync();
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
      String isolateName = type;
      isolates.spawn<String>(
        getAllFilesWithIsolate,
        name: isolateName,
        onReceive: (val) {
          print('getAllFilesWithIsolate completed');
          isolates.kill(isolateName);
        },
        onInitialized: () => isolates.send('hey', to: isolateName),
      );
      ReceivePort port = ReceivePort();
      IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');
      port.listen((filePaths) {
        processFilePaths(filePaths, type, files, tabs);
        currentFiles = files;
        setLoading(false);
        print('getFiles completed');
        port.close();
        IsolateNameServer.removePortNameMapping('${isolateName}_2');
      });
    }
  }

  void processFilePaths(List<String> filePaths, String type,
      List<FileSystemEntity> files, List<String> tabs) {
    Set _tabs = tabs.toSet();
    filePaths.forEach((filePath) {
      File file = File(filePath);
      if (shouldAddFile(file, type)) {
        files.add(file);
        _tabs.add('${file.path.split('/')[file.path.split('/').length - 2]}');
      }
      notifyListeners();
    });
    tabs = _tabs.toList() as List<String>;
  }

  bool shouldAddFile(File file, String type) {
    switch (type) {
      case 'application':
        return extension(file.path) == '.apk';
      case 'archive':
        return ['.zip', '.rar', '.tar', '.gz', '.7z', '.zlib', 'bz2', '.xz']
            .contains(extension(file.path));
      case 'text':
        return ['.pdf', '.epub', '.mobi', '.doc', '.docx', '.json']
            .contains(extension(file.path));
      default:
        String mimeType = mime(file.path) ?? '';
        return mimeType.split('/')[0] == type;
    }
  }

  static getAllFilesWithIsolate(Map<String, dynamic> context) async {
    String isolateName = context['name'];
    List<FileSystemEntity> files =
        await FileUtils.getAllFiles(showHidden: false);
    final messenger = HandledIsolate.initialize(context);
    try {
      final SendPort? send =
          IsolateNameServer.lookupPortByName('${isolateName}_2');
      // Convert the FileSystemEntity objects to their paths before sending
      List<String> filePaths = files.map((file) => file.path).toList();
      print('Found ${filePaths.length} files'); // Add this line
      send!.send(filePaths);
      // Wait for the send operation to complete before sending 'done'
      await Future.delayed(Duration(seconds: 1));
      messenger.send('done');
    } catch (e) {
      print(e);
    }
  }

  switchCurrentFiles(List list, String label) async {
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

  void setLoading(value) {
    loading = value;
    notifyListeners();
  }

  setHidden(value) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setBool('hidden', value);
    showHidden = value;
    notifyListeners();
  }

  getHidden() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    bool h = preference.getBool('hidden') ?? false;
    setHidden(h);
  }

  Future setSort(value) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    await preference.setInt('sort', value);
    sort = value;
    notifyListeners();
  }

  getSort() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    int h = preference.getInt('sort') ?? 0;
    setSort(h);
  }
}
