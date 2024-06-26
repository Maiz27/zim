import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../utils/consts.dart';
import '../../widgets/custom_divider.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/file/file_item.dart';

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
          Provider.of<CategoryProvider>(context, listen: false)
              .getNonThumbnailFiles('audio');
          break;
        case 'documents':
          Provider.of<CategoryProvider>(context, listen: false)
              .getNonThumbnailFiles('text');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
        return provider.loading
            ? const Scaffold(body: CustomLoader())
            : DefaultTabController(
                length: provider.nonThumbnailTabs.length,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                    bottom: TabBar(
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      labelColor: Theme.of(context).colorScheme.secondary,
                      unselectedLabelColor:
                          Theme.of(context).textTheme.caption!.color,
                      isScrollable:
                          provider.nonThumbnailTabs.length < 3 ? false : true,
                      tabs: Constants.map<Widget>(
                        provider.nonThumbnailTabs,
                        (index, label) {
                          // print('tabs');
                          return Tab(text: '$label');
                        },
                      ),
                    ),
                  ),
                  body: provider.nonThumbnailFiles.isEmpty
                      ? const Center(child: Text('No Files Found'))
                      : TabBarView(
                          children: Constants.map<Widget>(
                            provider.nonThumbnailTabs,
                            (index, label) {
                              // print(label);
                              List list = [];
                              List items = provider.nonThumbnailFiles;
                              for (var file in items) {
                                // print('${file.path.split('/')}');
                                if ('${file.path.split('/')[file.path.split('/').length - 2]}' ==
                                    label) {
                                  list.add(file);
                                }
                              }
                              // print(label);
                              return ListView.separated(
                                padding: const EdgeInsets.only(left: 20),
                                itemCount: index == 0
                                    ? provider.nonThumbnailFiles.length
                                    : list.length,
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                  FileSystemEntity file = index == 0
                                      ? provider.nonThumbnailFiles[index2]
                                      : list[index2];
                                  return FileItem(file: file);
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const CustomDivider();
                                },
                              );
                            },
                          ),
                        ),
                ),
              );
      },
    );
  }
}
