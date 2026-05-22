import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/core_provider.dart';
import '../../widgets/custom_divider.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/file/file_item.dart';

class Recent extends StatefulWidget {
  final String title;
  const Recent({super.key, required this.title});

  @override
  State<Recent> createState() => _RecentState();
}

class _RecentState extends State<Recent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Consumer<CoreProvider>(
        builder: (BuildContext context, coreProvider, Widget? child) {
          if (coreProvider.recentLoading) {
            return const CustomLoader();
          }
          final files = coreProvider.recentFiles
              .where((f) => f.existsSync())
              .take(20)
              .toList();
          if (files.isEmpty) {
            return const Center(child: Text('No Files Found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            itemCount: files.length,
            itemBuilder: (BuildContext context, int index) {
              final FileSystemEntity file = files[index];
              return FileItem(file: file);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const CustomDivider();
            },
          );
        },
      ),
    );
  }
}
