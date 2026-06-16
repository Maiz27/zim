import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';

import '../../utils/file_utils.dart';
import '../entity_popup.dart';
import '../entity_tile.dart';
import 'file_icon.dart';

class FileItem extends StatelessWidget {
  final FileSystemEntity file;
  final EntityAction? popTap;

  const FileItem({super.key, required this.file, this.popTap});

  String _buildSubtitle() {
    final f = File(file.path);
    if (!f.existsSync()) return 'Unavailable';
    try {
      final size = FileUtils.formatBytes(f.lengthSync(), 2);
      final modified = FileUtils.formatTime(
        f.lastModifiedSync().toIso8601String(),
      );
      return '$size, $modified';
    } on FileSystemException {
      return 'Unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return EntityTile(
      onTap: () => OpenFile.open(file.path),
      onAction: popTap,
      canDecompress: FileUtils.isExtractableArchive(file.path),
      leading: FileIcon(file: file),
      title: basename(file.path),
      subtitle: _buildSubtitle(),
    );
  }
}
