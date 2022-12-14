import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/core_provider.dart';
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Consumer<CoreProvider>(
          builder: (BuildContext context, coreProvider, Widget? child) {
            if (coreProvider.recentLoading) {
              return const SizedBox(height: 150, child: CustomLoader());
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coreProvider.recentFiles.length > 20
                  ? 20
                  : coreProvider.recentFiles.length,
              itemBuilder: (BuildContext context, int index) {
                FileSystemEntity file = coreProvider.recentFiles[index];
                return file.existsSync()
                    ? FileItem(file: file)
                    : const SizedBox();
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
