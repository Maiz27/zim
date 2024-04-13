import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as path;
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

  List<FileSystemEntity> images = <FileSystemEntity>[];
  List<String> imageTabs = <String>[];

  List<FileSystemEntity> audio = <FileSystemEntity>[];
  List<String> audioTabs = <String>[];
  List<FileSystemEntity> currentFiles = [];

  bool showHidden = false;
  int sort = 0;
  final isolates = IsolateHandler();

  getDownloads() async {
    setLoading(true);
    downloadTabs.clear();
    downloads.clear();
    downloadTabs.add('All');
    List<Directory> storages = await FileUtils.getStorageList();
    for (var dir in storages) {
      if (Directory('${dir.path}Download').existsSync()) {
        List<FileSystemEntity> files =
            Directory('${dir.path}Download').listSync();
        // print(files);
        for (var file in files) {
          if (FileSystemEntity.isFileSync(file.path)) {
            downloads.add(file);
            downloadTabs
                .add(file.path.split('/')[file.path.split('/').length - 2]);
            downloadTabs = downloadTabs.toSet().toList();
            notifyListeners();
          }
        }
      }
    }
    setLoading(false);
  }

  getImages(String type) async {
    print('getImages started');
    setLoading(true);
    imageTabs.clear();
    images.clear();
    imageTabs.add('All');
    String isolateName = type;
    isolates.spawn<String>(
      getAllFilesWithIsolate,
      name: isolateName,
      onReceive: (val) {
        print('getAllFilesWithIsolate completed');
        // print(val);
        isolates.kill(isolateName);
      },
      onInitialized: () => isolates.send('hey', to: isolateName),
    );
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');
    port.listen((filePaths) {
      filePaths.forEach((filePath) {
        File file = File(filePath);
        // Rest of your code...
        switch (type) {
          case 'application':
            var ex = extension(file.path);
            if (ex == '.apk') {
              images.add(file);
              imageTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              imageTabs = imageTabs.toSet().toList();
            }
            break;
          case 'archive':
            var ex = extension(file.path);

            if (['.zip', '.rar', '.tar', '.gz', '.7z', '.zlib', 'bz2', '.xz']
                .contains(ex)) {
              images.add(file);
              imageTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              imageTabs = imageTabs.toSet().toList();
            }
            break;
          default:
            String mimeType = mime(file.path) ?? '';
            if (mimeType.split('/')[0] == type) {
              images.add(file);
              imageTabs.add(
                  '${file.path.split('/')[file.path.split('/').length - 2]}');
              imageTabs = imageTabs.toSet().toList();
            }
        }
        notifyListeners();
      });
      currentFiles = images;
      setLoading(false);
      print('getImages completed');
      port.close();
      IsolateNameServer.removePortNameMapping('${isolateName}_2');
    });
  }

  /* 
  x-rar-compressed => rar-compressed
  vnd.android.package-archive => apk
  zip => zip
  */

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

  getAudios(String type) async {
    setLoading(true);
    audioTabs.clear();
    audio.clear();
    audioTabs.add('All');
    String isolateName = type;
    isolates.spawn<String>(
      getAllFilesWithIsolate,
      name: isolateName,
      onReceive: (val) {
        print('getAllFilesWithIsolate completed');
        // print(val);
        isolates.kill(isolateName);
      },
      onInitialized: () => isolates.send('hey', to: isolateName),
    );
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');
    port.listen((filePaths) async {
      if (filePaths.isEmpty) {
        print('No file paths received');
      } else {
        print('Received file paths: ${filePaths.length}');
      }
      // List<File> files = filePaths.map((filePath) => File(filePath)).toList();
      List tabs =
          await compute(separateAudios, {'files': filePaths, 'type': type});
      audio = tabs[0];
      audioTabs = tabs[1];
      setLoading(false);
      port.close();
      IsolateNameServer.removePortNameMapping('${isolateName}_2');
    });
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

  static Future<List> separateAudios(Map body) async {
    List<String> filePaths = body['files'];
    String type = body['type'];
    List<FileSystemEntity> audio = [];
    List<String> audioTabs = [];

    for (String filePath in filePaths) {
      File file = File(filePath);
      String fileType = getFileType(file.path);
      if (fileType == type) {
        audio.add(file);
        audioTabs.add(file.path.split('/')[file.path.split('/').length - 2]);
        audioTabs = audioTabs.toSet().toList();
      }
    }
    return [audio, audioTabs];
  }

  static String getFileType(String filePath) {
    String extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
      case '.doc':
      case '.docx':
      case '.json':
        return 'text';
      // Add more cases here for other file types
      default:
        String mimeType = mime(filePath) ?? '';
        return mimeType.split('/')[0];
    }
  }

  static List docExtensions = [
    '.pdf',
    '.epub',
    '.mobi',
    '.doc',
    '.docx',
  ];

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
