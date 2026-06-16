import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../services/file_repository.dart';
import '../utils/design_tokens.dart';
import '../utils/dialogs.dart';
import '../utils/file_utils.dart';
import '../widgets/custom_divider.dart';
import '../widgets/dialogs/decompress_archive_dialog.dart';
import '../widgets/dir_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/file/file_item.dart';
import '../widgets/motion.dart';
import '../widgets/path_bar.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/dialogs/add_file_dialog.dart';
import '../widgets/dialogs/rename_file_dialog.dart';

class Folder extends StatefulWidget {
  final String title;
  final String path;

  const Folder({super.key, required this.title, required this.path});

  @override
  // ignore: library_private_types_in_public_api
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> with WidgetsBindingObserver {
  static const FileRepository _repo = FileRepository();

  late String path;
  List<String> paths = <String>[];

  List<FileSystemEntity> files = <FileSystemEntity>[];
  bool showHidden = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getFiles();
    }
  }

  Future<void> getFiles() async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    showHidden = provider.showHidden;
    try {
      final listed = _repo.list(path, showHidden: showHidden);
      files = FileUtils.sortList(listed, provider.sort);
    } on FileOpException catch (e) {
      files = <FileSystemEntity>[];
      if (!mounted) return;
      Dialogs.showToast(e.message);
      if (e.kind == FileOpError.permissionDenied) {
        if (paths.length > 1) {
          navigateBack();
          return;
        }
        Navigator.pop(context);
        return;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    path = widget.path;
    getFiles();
    paths.add(widget.path);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void navigateBack() {
    paths.removeLast();
    path = paths.last;
    setState(() {});
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: paths.length == 1,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (paths.length > 1) {
          paths.removeLast();
          setState(() {
            path = paths.last;
          });
          getFiles();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (paths.length == 1) {
                Navigator.pop(context);
              } else {
                navigateBack();
              }
            },
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
          bottom: PathBar(
            paths: paths,
            icon: widget.path.toString().contains('emulated')
                ? Icons.smartphone
                : Icons.sd_card,
            onChanged: (index) {
              path = paths[index];
              paths.removeRange(index + 1, paths.length);
              setState(() {});
              getFiles();
            },
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  builder: (context) => const SortSheet(),
                );
                if (!mounted) return;
                getFiles();
              },
              tooltip: 'Sort by',
              icon: const Icon(Icons.sort),
            ),
          ],
        ),
        body: Visibility(
          replacement: const EmptyState(
            icon: Icons.folder_open_outlined,
            title: 'This folder is empty',
          ),
          visible: files.isNotEmpty,
          child: ListView.separated(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: 80,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
            ),
            itemCount: files.length,
            itemBuilder: (BuildContext context, int index) {
              final FileSystemEntity file = files[index];
              if (file is Directory) {
                return AnimatedEntrance(
                  index: index,
                  child: DirectoryItem(
                    popTap: (v) {
                      if (v == 0) {
                        renameDialog(context, file.path, 'dir');
                      } else if (v == 1) {
                        deleteFile(file);
                      }
                    },
                    file: file,
                    tap: () {
                      paths.add(file.path);
                      path = file.path;
                      setState(() {});
                      getFiles();
                    },
                  ),
                );
              }
              return AnimatedEntrance(
                index: index,
                child: FileItem(
                  file: file,
                  popTap: (v) {
                    if (v == 0) {
                      renameDialog(context, file.path, 'file');
                    } else if (v == 1) {
                      deleteFile(file);
                    } else if (v == 2) {
                      decompressDialog(context, file.path, file.parent.path);
                    }
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const CustomDivider();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => addDialog(context, path),
          tooltip: 'Add Folder',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> deleteFile(FileSystemEntity file) async {
    try {
      await _repo.delete(file);
      if (mounted) Dialogs.showToast('Delete Successful');
    } on FileOpException catch (e) {
      if (mounted) Dialogs.showToast(e.message);
    }
    await getFiles();
  }

  Future<void> addDialog(BuildContext context, String path) async {
    await showDialog(
      context: context,
      builder: (context) => AddFileDialog(path: path),
    );
    if (!mounted) return;
    getFiles();
  }

  Future<void> renameDialog(
    BuildContext context,
    String path,
    String type,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => RenameFileDialog(path: path, type: type),
    );
    if (!mounted) return;
    getFiles();
  }

  Future<void> decompressDialog(
    BuildContext context,
    String path,
    String parent,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => DecompressArchiveDialog(path: path, parent: parent),
    );
    if (!mounted) return;
    getFiles();
  }
}
