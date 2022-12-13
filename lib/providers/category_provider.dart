import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:mime_type/mime_type.dart';
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
    setLoading(true);
    imageTabs.clear();
    images.clear();
    imageTabs.add('All');
    String isolateName = type;
    isolates.spawn<String>(
      getAllFilesWithIsolate,
      name: isolateName,
      onReceive: (val) {
        // print(val);
        isolates.kill(isolateName);
      },
      onInitialized: () => isolates.send('hey', to: isolateName),
    );
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');
    port.listen((files) {
      // print('RECEIVED SERVER PORT');
      // print(files);
      files.forEach((file) {
        String mimeType = mime(file.path) ?? '';
        if (mimeType.split('/')[0] == type) {
          images.add(file);
          imageTabs
              .add('${file.path.split('/')[file.path.split('/').length - 2]}');
          imageTabs = imageTabs.toSet().toList();
        }
        notifyListeners();
      });
      currentFiles = images;
      setLoading(false);
      port.close();
      IsolateNameServer.removePortNameMapping('${isolateName}_2');
    });
  }

  static getAllFilesWithIsolate(Map<String, dynamic> context) async {
    // print(context);
    String isolateName = context['name'];
    // print('Get files');
    List<FileSystemEntity> files =
        await FileUtils.getAllFiles(showHidden: false);
    // print('Files $files');
    final messenger = HandledIsolate.initialize(context);
    try {
      final SendPort? send =
          IsolateNameServer.lookupPortByName('${isolateName}_2');
      send!.send(files);
    } catch (e) {
      // print(e);
    }
    messenger.send('done');
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
        // print(val);
        isolates.kill(isolateName);
      },
      onInitialized: () => isolates.send('hey', to: isolateName),
    );
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');
    port.listen((files) async {
      // print('RECEIVED SERVER PORT');
      // print(files);
      List tabs = await compute(separateAudios, {'files': files, 'type': type});
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
    List files = body['files'];
    String type = body['type'];
    List<FileSystemEntity> audio = [];
    List<String> audioTabs = [];
    for (File file in files) {
      String mimeType = mime(file.path) ?? '';
      // print(extension(file.path));
      if (type == 'text' && docExtensions.contains(extension(file.path))) {
        audio.add(file);
      }
      if (mimeType.isNotEmpty) {
        if (mimeType.split('/')[0] == type) {
          audio.add(file);
          audioTabs.add(file.path.split('/')[file.path.split('/').length - 2]);
          audioTabs = audioTabs.toSet().toList();
        }
      }
    }
    return [audio, audioTabs];
  }

  static List docExtensions = [
    '.pdf',
    '.epub',
    '.mobi',
    '.doc',
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
