import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../utils/design_tokens.dart';
import '../../widgets/custom_divider.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/file/file_item.dart';
import '../../widgets/motion.dart';

//Category with Icon
class CategoryTwo extends StatefulWidget {
  final String title;
  const CategoryTwo({super.key, required this.title});

  @override
  State<CategoryTwo> createState() => _CategoryTwoState();
}

class _CategoryTwoState extends State<CategoryTwo> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      switch (widget.title.toLowerCase()) {
        case 'audio':
          Provider.of<CategoryProvider>(
            context,
            listen: false,
          ).getNonThumbnailFiles('audio');
          break;
        case 'documents':
          Provider.of<CategoryProvider>(
            context,
            listen: false,
          ).getNonThumbnailFiles('text');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, CategoryProvider provider, Widget? child) {
        final bool isAudio = widget.title.toLowerCase() == 'audio';
        return provider.loading
            ? const Scaffold(body: CustomLoader())
            : DefaultTabController(
                length: provider.nonThumbnailTabs.length,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                    bottom: TabBar(
                      isScrollable: provider.nonThumbnailTabs.length >= 3,
                      tabs: [
                        for (final label in provider.nonThumbnailTabs)
                          Tab(text: label),
                      ],
                    ),
                  ),
                  body: provider.nonThumbnailFiles.isEmpty
                      ? EmptyState(
                          icon: isAudio
                              ? Icons.library_music_outlined
                              : Icons.description_outlined,
                          title: isAudio ? 'No audio yet' : 'No documents yet',
                          message: isAudio
                              ? 'Audio files on your device will appear here.'
                              : 'Documents on your device will appear here.',
                        )
                      : TabBarView(
                          children: [
                            for (final (index, label)
                                in provider.nonThumbnailTabs.indexed)
                              Builder(
                                builder: (context) {
                                  final List items =
                                      provider.nonThumbnailFiles;
                                  final List list = [
                                    for (final file in items)
                                      if ('${file.path.split('/')[file.path.split('/').length - 2]}' ==
                                          label)
                                        file,
                                  ];
                                  return ListView.separated(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.xl,
                                ),
                                itemCount: index == 0
                                    ? provider.nonThumbnailFiles.length
                                    : list.length,
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                      FileSystemEntity file = index == 0
                                          ? provider.nonThumbnailFiles[index2]
                                          : list[index2];
                                      return AnimatedEntrance(
                                        index: index2,
                                        child: FileItem(file: file),
                                      );
                                    },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                      return const CustomDivider();
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                ),
              );
      },
    );
  }
}
