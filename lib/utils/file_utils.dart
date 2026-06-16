import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// Extensions treated as archives for icons, the Archives category and the
  /// file listing. Broad: includes formats we recognise but cannot extract.
  static const List<String> archiveExtensions = [
    '.zip',
    '.rar',
    '.tar',
    '.gz',
    '.7z',
    '.zlib',
    '.bz2',
    '.xz',
  ];

  /// Archives the bundled `archive` package can actually extract. Narrower than
  /// [archiveExtensions] (no `.rar` / `.7z`), so the Decompress action is only
  /// offered when it can really succeed.
  static const List<String> extractableArchiveExtensions = [
    '.zip',
    '.tar',
    '.gz',
    '.zlib',
    '.bz2',
    '.xz',
  ];

  /// Whether [path] looks like an archive (for icon / category / listing).
  static bool isArchive(String path) =>
      archiveExtensions.contains(extension(path).toLowerCase());

  /// Whether [path] is an archive this app can extract.
  static bool isExtractableArchive(String path) =>
      extractableArchiveExtensions.contains(extension(path).toLowerCase());

  /// Convert Byte to KB, MB, .......
  static String formatBytes(num bytes, int decimals) {
    if (bytes == 0) return '0.0 KB';
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return '${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}';
  }

  /// Return all available storage roots (with the Android data suffix removed).
  static Future<List<Directory>> getStorageList() async {
    final List<Directory> paths = await getExternalStorageDirectories() ?? [];
    return [for (final dir in paths) removeDataDirectory(dir.path)];
  }

  static Directory removeDataDirectory(String path) {
    return Directory(path.split('Android')[0]);
  }

  static Future<bool> extractArchive(String source, String destination) async {
    if (!isExtractableArchive(source)) return false;
    try {
      await extractFileToDisk(source, destination);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static String formatTime(String iso) {
    DateTime date = DateTime.parse(iso);
    DateTime now = DateTime.now();
    DateTime yDay = DateTime.now().subtract(const Duration(days: 1));
    DateTime dateFormat = DateTime.parse(
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00.000Z',
    );
    DateTime today = DateTime.parse(
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T00:00:00.000Z',
    );
    DateTime yesterday = DateTime.parse(
      '${yDay.year}-${yDay.month.toString().padLeft(2, '0')}-${yDay.day.toString().padLeft(2, '0')}T00:00:00.000Z',
    );

    if (dateFormat == today) {
      return 'Today ${DateFormat('HH:mm').format(DateTime.parse(iso))}';
    } else if (dateFormat == yesterday) {
      return 'Yesterday ${DateFormat('HH:mm').format(DateTime.parse(iso))}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(DateTime.parse(iso));
    }
  }
}
