import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/entry.dart';
import '../utils/file_utils.dart';

/// Classified file-operation failures, so the UI can show a clear, recoverable
/// message instead of swallowing every error or string-matching on
/// "Permission denied".
enum FileOpError {
  permissionDenied,
  notFound,
  alreadyExists,
  noSpace,
  unsupported,
  unknown,
}

class FileOpException implements Exception {
  const FileOpException(this.kind, this.message);

  final FileOpError kind;
  final String message;

  @override
  String toString() => 'FileOpException($kind): $message';
}

/// The single seam for filesystem mutations. Owns all `dart:io` access for
/// list / delete / rename / create / extract and maps low-level
/// [FileSystemException]s to typed [FileOpException]s. This is the test surface:
/// widgets call the repository, not `dart:io` directly.
class FileRepository {
  const FileRepository();

  /// Entries directly inside [path] (non-recursive). Hides dotfiles unless
  /// [showHidden] is set.
  List<FileSystemEntity> list(String path, {bool showHidden = false}) {
    try {
      final entries = Directory(path).listSync();
      if (showHidden) return entries;
      return entries
          .where((e) => !p.basename(e.path).startsWith('.'))
          .toList();
    } on FileSystemException catch (e) {
      throw _map(e);
    }
  }

  /// Entries directly inside [path] (non-recursive) as value objects, statted
  /// once. Hides dotfiles unless [showHidden].
  List<Entry> listEntries(String path, {bool showHidden = false}) {
    return list(path, showHidden: showHidden).map(Entry.of).toList();
  }

  /// Full recursive device scan. The platform channel resolves storage roots
  /// before `compute` runs the recursive walk on a background isolate.
  Future<List<Entry>> scan({bool showHidden = false}) async {
    final roots =
        (await FileUtils.getStorageList()).map((d) => d.path).toList();
    return compute(scanEntries, (roots, showHidden));
  }

  /// Device files, newest-modified first. Built on the offloaded [scan].
  Future<List<Entry>> recent({bool showHidden = false}) async {
    final entries = await scan(showHidden: showHidden);
    entries.sort((a, b) => b.modified.compareTo(a.modified));
    return entries;
  }

  /// Recursively collects entries under the roots in [args] (a
  /// `(roots, showHidden)` record). Pure + isolate-safe (no platform channels),
  /// so it runs via `compute`. Statts each file once into an [Entry].
  static List<Entry> scanEntries((List<String>, bool) args) {
    final (roots, showHidden) = args;
    final out = <Entry>[];
    for (final root in roots) {
      try {
        _collect(root, showHidden, out);
      } catch (_) {
        // Skip unreadable roots rather than aborting the whole scan.
      }
    }
    return out;
  }

  static void _collect(String path, bool showHidden, List<Entry> out) {
    // followLinks:false so a symlink cycle can't cause unbounded recursion.
    for (final entity in Directory(path).listSync(followLinks: false)) {
      final bool hidden = p.basename(entity.path).startsWith('.');
      if (entity is File) {
        if (showHidden || !hidden) out.add(Entry.of(entity));
      } else {
        if (entity.path.contains('/storage/emulated/0/Android')) continue;
        if (showHidden || !hidden) {
          try {
            _collect(entity.path, showHidden, out);
          } catch (_) {
            // Skip directories we cannot read.
          }
        }
      }
    }
  }

  /// Sorts [list] in place by the sort code used across the app
  /// (0/1 name asc/desc, 2/3 modified asc/desc, 4/5 size desc/asc). Reads the
  /// prefetched [Entry] fields — no per-comparison `statSync`.
  static List<Entry> sortEntries(List<Entry> list, int sort) {
    int byName(Entry a, Entry b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
    switch (sort) {
      case 1:
        list.sort((a, b) => byName(b, a));
        break;
      case 2:
        list.sort((a, b) => a.modified.compareTo(b.modified));
        break;
      case 3:
        list.sort((a, b) => b.modified.compareTo(a.modified));
        break;
      case 4:
        list.sort((a, b) => b.size.compareTo(a.size));
        break;
      case 5:
        list.sort((a, b) => a.size.compareTo(b.size));
        break;
      default:
        list.sort(byName);
    }
    return list;
  }

  /// Rejects a user-supplied name that would escape its parent directory
  /// (empty, `.`/`..`, or containing a path separator).
  void _validateName(String name) {
    if (name.isEmpty ||
        name == '.' ||
        name == '..' ||
        name.contains('/') ||
        name.contains(r'\')) {
      throw const FileOpException(
        FileOpError.unsupported,
        'That name contains characters that are not allowed.',
      );
    }
  }

  Future<void> delete(FileSystemEntity entity) async {
    try {
      await entity.delete(recursive: true);
    } on FileSystemException catch (e) {
      throw _map(e);
    }
  }

  /// Renames [entity] to [newName] within its own directory. Throws
  /// [FileOpError.alreadyExists] if something already uses that name.
  Future<FileSystemEntity> rename(
    FileSystemEntity entity,
    String newName,
  ) async {
    _validateName(newName);
    final target = p.join(p.dirname(entity.path), newName);
    if (FileSystemEntity.typeSync(target) != FileSystemEntityType.notFound) {
      throw const FileOpException(
        FileOpError.alreadyExists,
        'An item with that name already exists.',
      );
    }
    try {
      return await entity.rename(target);
    } on FileSystemException catch (e) {
      throw _map(e);
    }
  }

  /// Creates a subdirectory [name] under [parentPath]. Throws
  /// [FileOpError.alreadyExists] if it is already there.
  Future<Directory> createDirectory(String parentPath, String name) async {
    _validateName(name);
    final dir = Directory(p.join(parentPath, name));
    if (dir.existsSync()) {
      throw const FileOpException(
        FileOpError.alreadyExists,
        'A folder with that name already exists.',
      );
    }
    try {
      return await dir.create(recursive: true);
    } on FileSystemException catch (e) {
      throw _map(e);
    }
  }

  /// Extracts [archivePath] into [destPath], creating the destination if
  /// needed. Throws [FileOpError.unsupported] for formats we cannot extract.
  Future<void> extract(String archivePath, String destPath) async {
    if (!FileUtils.isExtractableArchive(archivePath)) {
      throw const FileOpException(
        FileOpError.unsupported,
        'This archive format is not supported.',
      );
    }
    try {
      final dest = Directory(destPath);
      if (!dest.existsSync()) await dest.create(recursive: true);
    } on FileSystemException catch (e) {
      throw _map(e);
    }
    final ok = await FileUtils.extractArchive(archivePath, destPath);
    if (!ok) {
      throw const FileOpException(
        FileOpError.unknown,
        'Could not extract this archive.',
      );
    }
  }

  /// Maps a [FileSystemException] to a typed [FileOpException] using the POSIX
  /// errno (Android/Linux) with a string fallback for permission denials.
  FileOpException _map(FileSystemException e) {
    final code = e.osError?.errorCode;
    // EPERM=1, ENOENT=2, EACCES=13, EEXIST=17, ENOSPC=28
    if (code == 1 ||
        code == 13 ||
        e.toString().contains('Permission denied')) {
      return const FileOpException(
        FileOpError.permissionDenied,
        'Permission denied. Cannot access this location.',
      );
    }
    if (code == 2) {
      return const FileOpException(
        FileOpError.notFound,
        'That file or folder no longer exists.',
      );
    }
    if (code == 17) {
      return const FileOpException(
        FileOpError.alreadyExists,
        'An item with that name already exists.',
      );
    }
    if (code == 28) {
      return const FileOpException(
        FileOpError.noSpace,
        'Not enough storage space.',
      );
    }
    return FileOpException(
      FileOpError.unknown,
      e.message.isEmpty ? 'Something went wrong.' : e.message,
    );
  }
}
