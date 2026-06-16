import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/core_provider.dart';
import '../../utils/design_tokens.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/category/category_section.dart';
import '../../widgets/storage/storage_section.dart';
import '../search.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  Future<void> refresh(BuildContext context) async {
    // Drop the cached device scan so categories/search re-walk after a refresh.
    Provider.of<CategoryProvider>(context, listen: false).invalidateScan();
    await Provider.of<CoreProvider>(context, listen: false).checkSpace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Zim',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              showSearch(
                context: context,
                delegate: Search(themeData: Theme.of(context)),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => refresh(context),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: const Column(
              children: [StorageSection(), CategorySection()],
            ),
          ),
        ),
      ),
    );
  }

  double calculatePercent(int usedSpace, int totalSpace) {
    return double.parse((usedSpace / totalSpace * 100).toStringAsFixed(1));
  }
}
