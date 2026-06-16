import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/entry.dart';
import '../providers/category_provider.dart';
import '../utils/navigate.dart';
import '../widgets/dir_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/file/file_item.dart';
import 'folder.dart';

class Search extends SearchDelegate {
  final ThemeData themeData;

  Search({Key? key, required this.themeData});

  /// Debounced query: the heavy filter only runs once typing settles, so a
  /// fast typist doesn't trigger a rebuild + filter on every keystroke.
  final ValueNotifier<String> _debounced = ValueNotifier<String>('');
  Timer? _debounce;

  @override
  void close(BuildContext context, dynamic result) {
    _debounce?.cancel();
    super.close(context, result);
  }

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
    // Schedule the debounced query update whenever the live query changes.
    if (_debounced.value != query) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _debounced.value = query;
      });
    }
    return ValueListenableBuilder<String>(
      valueListenable: _debounced,
      builder: (BuildContext context, String debouncedQuery, _) {
        if (debouncedQuery.isEmpty) return const SizedBox();
        return FutureBuilder<List<Entry>>(
          future: provider.search(debouncedQuery),
          builder:
              (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
            final results = snapshot.data;
            if (results == null) return const SizedBox();
            if (results.isEmpty) {
              return const EmptyState(
                icon: Icons.search_off,
                title: 'No matches',
                message: 'No file matches your query.',
              );
            }
            return ListView.separated(
              itemCount: results.length,
              itemBuilder: (BuildContext context, int index) {
                Entry file = results[index];
                if (file.isDir) {
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
          },
        );
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
