import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../utils/design_tokens.dart';
import '../../utils/file_utils.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/file/file_icon.dart';
import '../../widgets/motion.dart';

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
          Provider.of<CategoryProvider>(
            context,
            listen: false,
          ).getThumbnailFiles('image');
          break;
        case 'video':
          Provider.of<CategoryProvider>(
            context,
            listen: false,
          ).getThumbnailFiles('video');
          break;
      }
    });
  }

  Widget _mediaTile(int index, dynamic item) {
    final file = File(item.path);
    final mimeType = lookupMimeType(file.path) ?? '';
    return AnimatedEntrance(
      index: index,
      child: _MediaTile(file: file, mimeType: mimeType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
            if (provider.loading) {
              return const Scaffold(body: CustomLoader());
            }
            final bool isVideo = widget.title.toLowerCase() == 'video';
            return DefaultTabController(
              length: provider.thumbnailTabs.length,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                  bottom: TabBar(
                    isScrollable: provider.thumbnailTabs.length >= 3,
                    tabs: [
                      for (final label in provider.thumbnailTabs)
                        Tab(text: label),
                    ],
                    onTap: (val) => provider.switchCurrentFiles(
                      provider.thumbnailFiles,
                      provider.thumbnailTabs[val],
                    ),
                  ),
                ),
                body: Visibility(
                  visible: provider.thumbnailFiles.isNotEmpty,
                  replacement: EmptyState(
                    icon: isVideo
                        ? Icons.video_library_outlined
                        : Icons.photo_library_outlined,
                    title: isVideo ? 'No videos yet' : 'No images yet',
                    message: isVideo
                        ? 'Videos on your device will appear here.'
                        : 'Images on your device will appear here.',
                  ),
                  child: TabBarView(
                    children: [
                      for (final (index, _) in provider.thumbnailTabs.indexed)
                        CustomScrollView(
                          primary: false,
                          slivers: <Widget>[
                            SliverPadding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              sliver: SliverGrid.count(
                                crossAxisSpacing: AppSpacing.xs,
                                mainAxisSpacing: AppSpacing.xs,
                                crossAxisCount: 2,
                                children: [
                                  for (final (i, item)
                                      in (index == 0
                                              ? provider.thumbnailFiles
                                              : provider.currentFiles.reversed
                                                    .toList())
                                          .indexed)
                                    _mediaTile(i, item),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
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
    final scheme = Theme.of(context).colorScheme;
    final isVideo = mimeType.split('/')[0] == 'video';
    // media overlay: white-on-media label for legibility over thumbnails
    final overlayStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Colors.white,
    );

    return PressableScale(
      child: InkWell(
        onTap: () => OpenFile.open(file.path),
        borderRadius: AppRadius.brMd,
        child: ClipRRect(
          borderRadius: AppRadius.brMd,
          child: GridTile(
            header: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // media overlay: scrim for label legibility over thumbnails
                  colors: [
                    scheme.scrim.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: isVideo
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              FileUtils.formatBytes(file.lengthSync(), 1),
                              style: overlayStyle,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            // media overlay: white icon for legibility
                            const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        )
                      : Text(
                          FileUtils.formatBytes(file.lengthSync(), 1),
                          style: overlayStyle,
                        ),
                ),
              ),
            ),
            child: isVideo
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
        ),
      ),
    );
  }
}
