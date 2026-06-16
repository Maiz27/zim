import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zim/models/entry.dart';
import 'package:zim/services/file_repository.dart';

class CoreProvider extends ChangeNotifier {
  /// Single platform seam for native storage queries.
  static const MethodChannel _storageChannel =
      MethodChannel('dev.maiz.zim/storage');

  static const FileRepository _repo = FileRepository();

  List<FileSystemEntity> availableStorage = <FileSystemEntity>[];
  List<Entry> recentFiles = <Entry>[];
  int totalSpace = 0;
  int freeSpace = 0;
  int totalSDSpace = 0;
  int freeSDSpace = 0;
  int usedSpace = 0;
  int usedSDSpace = 0;
  bool storageLoading = true;
  bool recentLoading = true;

  Future<void> checkSpace() async {
    recentLoading = true;
    storageLoading = true;
    recentFiles.clear();
    availableStorage.clear();
    notifyListeners();

    try {
      final List<Directory> dirList =
          await getExternalStorageDirectories() ?? [];
      availableStorage.addAll(dirList);

      final int free =
          await _storageChannel.invokeMethod<int>('getStorageFreeSpace') ?? 0;
      final int total =
          await _storageChannel.invokeMethod<int>('getStorageTotalSpace') ?? 0;
      freeSpace = free;
      totalSpace = total;
      usedSpace = total - free;

      if (dirList.length > 1) {
        final int freeSD = await _storageChannel
                .invokeMethod<int>('getExternalStorageFreeSpace') ??
            0;
        final int totalSD = await _storageChannel
                .invokeMethod<int>('getExternalStorageTotalSpace') ??
            0;
        freeSDSpace = freeSD;
        totalSDSpace = totalSD;
        usedSDSpace = totalSD - freeSD;
      }
    } catch (e) {
      // A native storage query failed; surface an empty state rather than a
      // spinner that never resolves.
      debugPrint('checkSpace failed: $e');
    } finally {
      storageLoading = false;
      notifyListeners();
    }

    getRecentFiles();
  }

  Future<void> getRecentFiles() async {
    try {
      recentFiles = await _repo.recent(showHidden: false);
    } catch (e) {
      debugPrint('getRecentFiles failed: $e');
    } finally {
      recentLoading = false;
      notifyListeners();
    }
  }
}
