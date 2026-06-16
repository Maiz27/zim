import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../utils/design_tokens.dart';
import 'entity_popup.dart';
import 'entity_tile.dart';

class DirectoryItem extends StatelessWidget {
  final FileSystemEntity file;
  final VoidCallback tap;
  final EntityAction? popTap;

  const DirectoryItem({
    super.key,
    required this.file,
    required this.tap,
    this.popTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FilePalette.of(FileKind.folder, Theme.of(context).brightness);
    return EntityTile(
      onTap: tap,
      onAction: popTap,
      title: basename(file.path),
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: AppRadius.brMd,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.folder, color: colors.icon, size: 22),
      ),
    );
  }
}
