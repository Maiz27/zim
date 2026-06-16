import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import '../../models/entry.dart';
import '../../utils/file_utils.dart';
import '../entity_popup.dart';
import '../entity_tile.dart';
import 'file_icon.dart';

class FileItem extends StatelessWidget {
  final Entry file;
  final EntityAction? popTap;

  const FileItem({super.key, required this.file, this.popTap});

  /// Subtitle from the prefetched [Entry] fields — no per-row disk I/O.
  String _buildSubtitle() {
    final size = FileUtils.formatBytes(file.size, 2);
    final modified = FileUtils.formatTime(file.modified.toIso8601String());
    return '$size, $modified';
  }

  @override
  Widget build(BuildContext context) {
    return EntityTile(
      onTap: () => OpenFile.open(file.path),
      onAction: popTap,
      canDecompress: FileUtils.isExtractableArchive(file.path),
      leading: FileIcon(entry: file),
      title: file.name,
      subtitle: _buildSubtitle(),
    );
  }
}
