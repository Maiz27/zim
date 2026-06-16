import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import '../utils/design_tokens.dart';
import '../utils/file_utils.dart';

/// An immutable snapshot of one filesystem entry. Carries the metadata the UI
/// needs — size and modified time prefetched during the scan — so rows never
/// stat the disk during `build`. Dumb data: no behaviour beyond the
/// path-classifying factory used to construct it.
class Entry {
  const Entry({
    required this.path,
    required this.name,
    required this.isDir,
    required this.size,
    required this.modified,
    required this.kind,
  });

  final String path;

  /// Last path segment (file or folder name).
  final String name;
  final bool isDir;

  /// Size in bytes; 0 for directories or entries that vanished before stat.
  final int size;
  final DateTime modified;
  final FileKind kind;

  /// Builds an [Entry] from a filesystem [entity], statting it once. Safe in a
  /// background isolate (no platform channels). If the entity vanished between
  /// listing and stat, size/modified fall back to zero rather than throwing.
  factory Entry.of(FileSystemEntity entity) {
    final bool isDir = entity is Directory;
    int size = 0;
    DateTime modified = DateTime.fromMillisecondsSinceEpoch(0);
    try {
      final stat = entity.statSync();
      size = stat.size;
      modified = stat.modified;
    } on FileSystemException {
      // Entity disappeared between listing and stat; keep the defaults.
    }
    return Entry(
      path: entity.path,
      name: p.basename(entity.path),
      isDir: isDir,
      size: size,
      modified: modified,
      kind: kindOf(entity.path, isDir: isDir),
    );
  }

  /// Pure path-based classification into a [FileKind]. Mirrors the icon logic so
  /// every surface (row icon, classify, decompress affordance) agrees.
  static FileKind kindOf(String path, {required bool isDir}) {
    if (isDir) return FileKind.folder;
    final String ext = p.extension(path).toLowerCase();
    if (ext == '.apk') return FileKind.apk;
    if (ext == '.crdownload') return FileKind.download;
    if (FileUtils.archiveExtensions.contains(ext)) return FileKind.archive;
    if (const ['.epub', '.pdf', '.mobi', '.doc', '.docx', '.json']
        .contains(ext)) {
      return FileKind.document;
    }
    final String mime = lookupMimeType(path) ?? '';
    switch (mime.isEmpty ? '' : mime.split('/')[0]) {
      case 'image':
        return FileKind.image;
      case 'video':
        return FileKind.video;
      case 'audio':
        return FileKind.audio;
      case 'text':
        return FileKind.text;
      default:
        return FileKind.generic;
    }
  }
}
