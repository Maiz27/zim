import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../utils/design_tokens.dart';
import '../../widgets/custom_divider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/file/file_item.dart';
import '../../widgets/motion.dart';

class Archives extends StatefulWidget {
  final String title;
  const Archives({super.key, required this.title});

  @override
  State<Archives> createState() => _ArchivesState();
}

class _ArchivesState extends State<Archives> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).getThumbnailFiles('archive');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.title)),
              body: Visibility(
                visible: provider.currentFiles.isNotEmpty,
                replacement: const EmptyState(
                  icon: Icons.folder_zip_outlined,
                  title: 'No archives yet',
                  message: 'Zip and other archives will appear here.',
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  itemCount: provider.currentFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AnimatedEntrance(
                      index: index,
                      child: FileItem(file: provider.currentFiles[index]),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const CustomDivider();
                  },
                ),
              ),
            );
          },
    );
  }
}
