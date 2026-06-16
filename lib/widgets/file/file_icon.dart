// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:zim/widgets/icon_font.dart';

import '../../utils/design_tokens.dart';
import '../../utils/file_utils.dart';
import '../../utils/icon_font_helper.dart';
import '../video_thumbnail.dart';

class FileIcon extends StatelessWidget {
  final FileSystemEntity file;

  const FileIcon({super.key, required this.file});

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
      child: IconFont(
        iconName: iconName,
        color: colors.icon,
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    File f = File(file.path);
    String _extension = extension(f.path).toLowerCase();
    String mimeType = lookupMimeType(file.path) ?? '';
    String type = mimeType.isEmpty ? '' : mimeType.split('/')[0];
    if (_extension == '.apk') {
      return _chip(context, FileKind.apk, IconFontHelper.android);
    } else if (_extension == '.crdownload') {
      final colors =
          FilePalette.of(FileKind.download, Theme.of(context).brightness);
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: AppRadius.brMd,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.download, color: colors.icon, size: 22),
      );
    } else if (FileUtils.archiveExtensions.contains(_extension)) {
      return _chip(context, FileKind.archive, IconFontHelper.archive);
    } else if (_extension == '.epub' ||
        _extension == '.pdf' ||
        _extension == '.mobi' ||
        _extension == '.doc' ||
        _extension == '.docx' ||
        _extension == '.json') {
      return _chip(context, FileKind.document, IconFontHelper.document);
    } else {
      switch (type) {
        case 'image':
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
                  FileImage(File(file.path)),
                  width: 50,
                  height: 50,
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
        case 'video':
          return SizedBox(
            height: 40,
            width: 40,
            child: VideoThumbnail(path: file.path),
          );
        case 'audio':
          return _chip(context, FileKind.audio, IconFontHelper.audio);
        case 'text':
          return _chip(context, FileKind.text, IconFontHelper.document);
        default:
          final colors =
              FilePalette.of(FileKind.generic, Theme.of(context).brightness);
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: AppRadius.brMd,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.file_copy_rounded, color: colors.icon, size: 22),
          );
      }
    }
  }
}
