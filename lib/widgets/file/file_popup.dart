import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FilePopup extends StatelessWidget {
  final String path;
  final Function popTap;

  const FilePopup({
    Key? key,
    required this.path,
    required this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isArchive = [
      '.zip',
      '.rar',
      '.tar',
      '.gz',
      '.7z',
      '.zlib',
      'bz2',
      '.xz'
    ].contains(extension(path));
    return PopupMenuButton<int>(
      onSelected: (val) => popTap(val),
      itemBuilder: (context) {
        if (isArchive) {
          return [
            const PopupMenuItem(value: 0, child: Text('Rename')),
            const PopupMenuItem(value: 1, child: Text('Delete')),
            const PopupMenuItem(value: 2, child: Text('Decompress'))
          ];
        } else {
          return [
            const PopupMenuItem(value: 0, child: Text('Rename')),
            const PopupMenuItem(value: 1, child: Text('Delete')),
          ];
        }
      },
      icon: Icon(
        Icons.arrow_drop_down,
        color: Theme.of(context).textTheme.headline6!.color,
      ),
      // color: Theme.of(context).scaffoldBackgroundColor,
      offset: const Offset(0, 30),
    );
  }
}
