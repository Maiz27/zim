import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../utils/file_utils.dart';
import '../utils/navigate.dart';
import '../widgets/dir_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/file/file_item.dart';
import 'folder.dart';

class Search extends SearchDelegate {
  final ThemeData themeData;

  Search({Key? key, required this.themeData});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = themeData;
    return theme.copyWith(
      primaryTextTheme: Theme.of(context).primaryTextTheme,
      textTheme: Theme.of(context).textTheme.copyWith(
        displayLarge: Theme.of(context).textTheme.displayLarge!.copyWith(
          color: Theme.of(context).primaryTextTheme.titleLarge!.color,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  /// Shared builder for results and suggestions: both run the same query and
  /// render the same list, so they delegate here to avoid duplication.
  Widget _buildSearch(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    return FutureBuilder<List<FileSystemEntity>>(
      future: FileUtils.searchFiles(query, showHidden: provider.showHidden),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'No matches',
              message: 'No file matches your query.',
            );
          } else {
            return ListView.separated(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                FileSystemEntity file = snapshot.data[index];
                if (file.toString().split(':')[0] == 'Directory') {
                  return DirectoryItem(
                    popTap: null,
                    file: file,
                    tap: () {
                      Navigate.pushPage(
                        context,
                        Folder(title: 'Storage', path: file.path),
                      );
                    },
                  );
                }
                return FileItem(file: file, popTap: null);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearch(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearch(context);
  }
}
