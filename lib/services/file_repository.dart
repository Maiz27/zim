import 'dart:io';

import 'package:path/path.dart' as p;

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
