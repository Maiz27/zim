// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:zim/widgets/icon_font.dart';

import '../../utils/icon_font_helper.dart';
import '../video_thumbnail.dart';

class FileIcon extends StatelessWidget {
  final FileSystemEntity file;

  const FileIcon({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    File f = File(file.path);
    String _extension = extension(f.path).toLowerCase();
    String mimeType = mime(basename(file.path).toLowerCase()) ?? '';
    String type = mimeType.isEmpty ? '' : mimeType.split('/')[0];
    if (_extension == '.apk') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconFont(
          iconName: IconFontHelper.android,
          color: Colors.green[700],
          size: 30,
        ),
      );
    } else if (_extension == '.crdownload') {
      return const Icon(Icons.download, color: Colors.lightBlue);
    } else if (['.zip', '.rar', '.tar', '.gz', '.7z'].contains(_extension)) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconFont(
          iconName: IconFontHelper.archive,
          color: Colors.purple[700],
          size: 30,
        ),
      );
    } else if (_extension == '.epub' ||
        _extension == '.pdf' ||
        _extension == '.mobi' ||
        _extension == '.doc' ||
        _extension == '.docx' ||
        _extension == '.json') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconFont(
          iconName: IconFontHelper.document,
          color: Colors.blue[700],
          size: 30,
        ),
      );
    } else {
      switch (type) {
        case 'image':
          return SizedBox(
            width: 50,
            height: 50,
            child: Image(
              errorBuilder: (b, o, c) {
                return IconFont(
                  iconName: IconFontHelper.img,
                  color: Colors.teal[700],
                );
              },
              image: ResizeImage(FileImage(File(file.path)),
                  width: 50, height: 50),
            ),
          );
        case 'video':
          return SizedBox(
              height: 40,
              width: 40,
              child: VideoThumbnail(
                path: file.path,
              ));
        case 'audio':
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconFont(
              iconName: IconFontHelper.audio,
              color: Colors.pink[700],
              size: 30,
            ),
          );
        case 'text':
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconFont(
              iconName: IconFontHelper.document,
              color: Colors.blue[700],
              size: 30,
            ),
          );
        default:
          return const Icon(Icons.file_copy_rounded);
      }
    }
  }
}
