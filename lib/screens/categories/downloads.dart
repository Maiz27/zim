import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../widgets/custom_divider.dart';
import '../../widgets/file/file_item.dart';

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
      Provider.of<CategoryProvider>(context, listen: false).getDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Visibility(
            visible: provider.downloads.isNotEmpty,
            replacement: const Center(child: Text('No Files Found')),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              itemCount: provider.downloads.length,
              itemBuilder: (BuildContext context, int index) {
                return FileItem(file: provider.downloads[index]);
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

// return ListView.separated(
//                       padding: const EdgeInsets.only(left: 20),
//                       itemCount: provider.downloads.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return FileItem(file: provider.downloads[index]);
//                       },
//                       separatorBuilder: (BuildContext context, int index) {
//                         return const CustomDivider();
//                       },
