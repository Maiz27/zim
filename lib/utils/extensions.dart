import 'dart:io';

import 'package:path/path.dart';

extension FilesExt on FileSystemEntity {
  bool get isHidden => basename(path).startsWith('.');

  // String get fileExtension => basename(path).split('.').last;
}
