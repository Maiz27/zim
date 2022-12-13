import 'dart:io';

// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mime_type/mime_type.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../utils/consts.dart';
import '../utils/file_utils.dart';
import '../widgets/custom_loader.dart';
import '../widgets/file_icon.dart';

class Images extends StatefulWidget {
  final String title;

  const Images({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _ImagesState createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.title.toLowerCase() == 'images') {
        Provider.of<CategoryProvider>(context, listen: false)
            .getImages('image');
      } else {
        Provider.of<CategoryProvider>(context, listen: false)
            .getImages('video');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
        if (provider.loading) {
          return Scaffold(body: CustomLoader());
        }
        return DefaultTabController(
          length: provider.imageTabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              bottom: TabBar(
                indicatorColor: Theme.of(context).colorScheme.secondary,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor:
                    Theme.of(context).textTheme.caption!.color,
                isScrollable: provider.imageTabs.length < 3 ? false : true,
                tabs: Constants.map<Widget>(
                  provider.imageTabs,
                  (index, label) {
                    return Tab(text: '$label');
                  },
                ),
                onTap: (val) => provider.switchCurrentFiles(
                    provider.images, provider.imageTabs[val]),
              ),
            ),
            body: Visibility(
              visible: provider.images.isNotEmpty,
              replacement: const Center(child: Text('No Files Found')),
              child: TabBarView(
                children: Constants.map<Widget>(
                  provider.imageTabs,
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
                                  ? provider.images
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

  _MediaTile({required this.file, required this.mimeType});

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
