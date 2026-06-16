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

class Downloads extends StatefulWidget {
  final String title;
  const Downloads({super.key, required this.title});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<CategoryProvider>(context, listen: false).getDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.title)),
              body: provider.loading
                  ? const CustomLoader()
                  : Visibility(
                visible: provider.downloads.isNotEmpty,
                replacement: const EmptyState(
                  icon: Icons.download_outlined,
                  title: 'No downloads yet',
                  message: 'Files you download will appear here.',
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  itemCount: provider.downloads.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AnimatedEntrance(
                      index: index,
                      child: FileItem(file: provider.downloads[index]),
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
