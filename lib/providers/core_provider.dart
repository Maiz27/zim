import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zim/utils/file_utils.dart';

class CoreProvider extends ChangeNotifier {
  List<FileSystemEntity> availableStorage = <FileSystemEntity>[];
  List<File> recentFiles = <File>[];
  int totalSpace = 0;
  int freeSpace = 0;
  int totalSDSpace = 0;
  int freeSDSpace = 0;
  int usedSpace = 0;
  int usedSDSpace = 0;
  bool storageLoading = true;
  bool recentLoading = true;

  Future<void> checkSpace() async {
    setRecentLoading(true);
    setStorageLoading(true);
    recentFiles.clear();
    availableStorage.clear();
    List<Directory> dirList = await getExternalStorageDirectories() ?? [];
    availableStorage.addAll(dirList);
    notifyListeners();
    MethodChannel platform = const MethodChannel('dev.maiz.zim/storage');
    int free = await platform.invokeMethod<int>('getStorageFreeSpace') ?? 0;
    int total = await platform.invokeMethod<int>('getStorageTotalSpace') ?? 0;
    setFreeSpace(free);
    setTotalSpace(total);
    setUsedSpace(total - free);
    if (dirList.length > 1) {
      int freeSD =
          await platform.invokeMethod<int>('getExternalStorageFreeSpace') ?? 0;
      int totalSD =
          await platform.invokeMethod<int>('getExternalStorageTotalSpace') ?? 0;
      setFreeSDSpace(freeSD);
      setTotalSDSpace(totalSD);
      setUsedSDSpace(totalSD - freeSD);
    }
    setStorageLoading(false);
    getRecentFiles();
  }

  Future<void> getRecentFiles() async {
    List<FileSystemEntity> files = await FileUtils.getRecentFiles(
      showHidden: false,
    );
    recentFiles.addAll(files.map((file) => File(file.path)));
    setRecentLoading(false);
  }

  void setFreeSpace(int value) {
    freeSpace = value;
    notifyListeners();
  }

  void setTotalSpace(int value) {
    totalSpace = value;
    notifyListeners();
  }

  void setUsedSpace(int value) {
    usedSpace = value;
    notifyListeners();
  }

  void setFreeSDSpace(int value) {
    freeSDSpace = value;
    notifyListeners();
  }

  void setTotalSDSpace(int value) {
    totalSDSpace = value;
    notifyListeners();
  }

  void setUsedSDSpace(int value) {
    usedSDSpace = value;
    notifyListeners();
  }

  void setStorageLoading(bool value) {
    storageLoading = value;
    notifyListeners();
  }

  void setRecentLoading(bool value) {
    recentLoading = value;
    notifyListeners();
  }
}
