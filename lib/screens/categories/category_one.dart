import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mime_type/mime_type.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../utils/consts.dart';
import '../../utils/file_utils.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/file/file_icon.dart';

//Category with Thumbnail
class CategoryOne extends StatefulWidget {
  final String title;
  const CategoryOne({super.key, required this.title});

  @override
  State<CategoryOne> createState() => _CategoryOneState();
}

class _CategoryOneState extends State<CategoryOne> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      switch (widget.title.toLowerCase()) {
        case 'images':
          Provider.of<CategoryProvider>(context, listen: false)
              .getThumbnailFiles('image');
          break;
        case 'video':
          Provider.of<CategoryProvider>(context, listen: false)
              .getThumbnailFiles('video');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
        if (provider.loading) {
          return const Scaffold(body: CustomLoader());
        }
        return DefaultTabController(
          length: provider.thumbnailTabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              bottom: TabBar(
                indicatorColor: Theme.of(context).colorScheme.secondary,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor:
                    Theme.of(context).textTheme.caption!.color,
                isScrollable: provider.thumbnailTabs.length < 3 ? false : true,
                tabs: Constants.map<Widget>(
                  provider.thumbnailTabs,
                  (index, label) {
                    return Tab(text: '$label');
                  },
                ),
                onTap: (val) => provider.switchCurrentFiles(
                    provider.thumbnailFiles, provider.thumbnailTabs[val]),
              ),
            ),
            body: Visibility(
              visible: provider.thumbnailFiles.isNotEmpty,
              replacement: const Center(child: Text('No Files Found')),
              child: TabBarView(
                children: Constants.map<Widget>(
                  provider.thumbnailTabs,
                  (index, label) {
                    List l = provider.currentFiles;

                    return CustomScrollView(
                      primary: false,
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.all(10.0),
                          sliver: SliverGrid.count(
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                            crossAxisCount: 2,
                            children: Constants.map(
                              index == 0
                                  ? provider.thumbnailFiles
                                  : l.reversed.toList(),
                              (index, item) {
                                File file = File(item.path);
                                String path = file.path;
                                String mimeType = mime(path) ?? '';
                                return _MediaTile(
                                    file: file, mimeType: mimeType);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  final File file;
  final String mimeType;

  const _MediaTile({required this.file, required this.mimeType});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => OpenFile.open(file.path),
      child: GridTile(
        header: Container(
          height: 50,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black54, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: mimeType.split('/')[0] == 'video'
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          FileUtils.formatBytes(file.lengthSync(), 1),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    )
                  : Text(
                      FileUtils.formatBytes(file.lengthSync(), 1),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
        ),
        child: mimeType.split('/')[0] == 'video'
            ? FileIcon(file: file)
            : Image(
                fit: BoxFit.cover,
                errorBuilder: (b, o, c) {
                  return const Icon(Icons.image);
                },
                image: ResizeImage(
                  FileImage(File(file.path)),
                  width: 150,
                  height: 150,
                ),
              ),
      ),
    );
  }
}
