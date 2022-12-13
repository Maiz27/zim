import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../utils/consts.dart';
import '../widgets/custom_divider.dart';
import '../widgets/custom_loader.dart';
import '../widgets/file_item.dart';

class Category extends StatefulWidget {
  final String title;
  const Category({super.key, required this.title});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      switch (widget.title.toLowerCase()) {
        case 'audio':
          Provider.of<CategoryProvider>(context, listen: false)
              .getAudios('audio');
          break;
        case 'documents & others':
          Provider.of<CategoryProvider>(context, listen: false)
              .getAudios('text');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
        return provider.loading
            ? Scaffold(body: CustomLoader())
            : DefaultTabController(
                length: provider.audioTabs.length,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                    bottom: TabBar(
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      labelColor: Theme.of(context).colorScheme.secondary,
                      unselectedLabelColor:
                          Theme.of(context).textTheme.caption!.color,
                      isScrollable:
                          provider.audioTabs.length < 3 ? false : true,
                      tabs: Constants.map<Widget>(
                        provider.audioTabs,
                        (index, label) {
                          // print('tabs');
                          return Tab(text: '$label');
                        },
                      ),
                    ),
                  ),
                  body: provider.audio.isEmpty
                      ? const Center(child: Text('No Files Found'))
                      : TabBarView(
                          children: Constants.map<Widget>(
                            provider.audioTabs,
                            (index, label) {
                              // print(label);
                              List list = [];
                              List items = provider.audio;
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
                                    ? provider.audio.length
                                    : list.length,
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                  FileSystemEntity file = index == 0
                                      ? provider.audio[index2]
                                      : list[index2];
                                  return FileItem(file: file);
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return CustomDivider();
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
