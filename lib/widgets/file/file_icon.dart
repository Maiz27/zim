import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zim/widgets/icon_font.dart';

import '../../models/entry.dart';
import '../../utils/design_tokens.dart';
import '../../utils/icon_font_helper.dart';
import '../video_thumbnail.dart';

class FileIcon extends StatelessWidget {
  final Entry entry;

  const FileIcon({super.key, required this.entry});

  /// Renders a non-thumbnail glyph as a calm M3 tonal chip.
  Widget _chip(BuildContext context, FileKind kind, String iconName) {
    final colors = FilePalette.of(kind, Theme.of(context).brightness);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: AppRadius.brMd,
      ),
      alignment: Alignment.center,
      child: IconFont(iconName: iconName, color: colors.icon, size: 22),
    );
  }

  /// A tonal chip carrying a Material [icon] (for kinds without an IconFont).
  Widget _materialChip(BuildContext context, FileKind kind, IconData icon) {
    final colors = FilePalette.of(kind, Theme.of(context).brightness);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: AppRadius.brMd,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: colors.icon, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (entry.kind) {
      case FileKind.apk:
        return _chip(context, FileKind.apk, IconFontHelper.android);
      case FileKind.download:
        return _materialChip(context, FileKind.download, Icons.download);
      case FileKind.archive:
        return _chip(context, FileKind.archive, IconFontHelper.archive);
      case FileKind.document:
      case FileKind.pdf:
        return _chip(context, FileKind.document, IconFontHelper.document);
      case FileKind.text:
        return _chip(context, FileKind.text, IconFontHelper.document);
      case FileKind.audio:
        return _chip(context, FileKind.audio, IconFontHelper.audio);
      case FileKind.image:
        return SizedBox(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: AppRadius.brMd,
            child: Image(
              errorBuilder: (b, o, c) {
                return _chip(context, FileKind.image, IconFontHelper.img);
              },
              image: ResizeImage(
                FileImage(File(entry.path)),
                width: 50,
                height: 50,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      case FileKind.video:
        return SizedBox(
          height: 40,
          width: 40,
          child: VideoThumbnail(path: entry.path),
        );
      case FileKind.code:
      case FileKind.folder:
      case FileKind.generic:
        return _materialChip(
          context,
          FileKind.generic,
          Icons.file_copy_rounded,
        );
    }
  }
}
