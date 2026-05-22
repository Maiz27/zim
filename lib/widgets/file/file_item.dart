import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';

import '../../utils/file_utils.dart';
import 'file_icon.dart';
import 'file_popup.dart';

class FileItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function? popTap;

  const FileItem({super.key, required this.file, this.popTap});

  String _buildSubtitle() {
    final f = File(file.path);
    if (!f.existsSync()) return 'Unavailable';
    try {
      final size = FileUtils.formatBytes(f.lengthSync(), 2);
      final modified =
          FileUtils.formatTime(f.lastModifiedSync().toIso8601String());
      return '$size, $modified';
    } on FileSystemException {
      return 'Unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => OpenFile.open(file.path),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: FileIcon(file: file),
      title: Text(
        basename(file.path),
        style: const TextStyle(fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _buildSubtitle(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: popTap == null
          ? null
          : FilePopup(path: file.path, popTap: popTap!),
    );
  }
}
