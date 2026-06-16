import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/core_provider.dart';
import '../../utils/design_tokens.dart';
import '../../utils/file_utils.dart';
import '../custom_loader.dart';
import 'storage_item.dart';

class StorageSection extends StatefulWidget {
  const StorageSection({super.key});

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.brXl,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        child: Consumer<CoreProvider>(
          builder: (BuildContext context, coreProvider, Widget? child) {
            if (coreProvider.storageLoading) {
              return const SizedBox(height: 200, child: CustomLoader());
            }
            if (coreProvider.availableStorage.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(child: Text('No storage found')),
              );
            }
            // Guard against idx pointing past a removed (e.g. SD) volume.
            final safeIdx = idx.clamp(0, coreProvider.availableStorage.length - 1);
            final FileSystemEntity item = coreProvider.availableStorage[safeIdx];
            final String path = FileUtils.removeDataDirectory(item.path).path;

            final List<String> list = [
              for (int i = 0; i < coreProvider.availableStorage.length; i++)
                if (i == 0) 'Device' else if (i == 1) 'SD',
            ];

            final int usedSpace = safeIdx == 0
                ? coreProvider.usedSpace
                : coreProvider.usedSDSpace;
            final int totalSpace = safeIdx == 0
                ? coreProvider.totalSpace
                : coreProvider.totalSDSpace;
            final double percent = totalSpace == 0
                ? 0
                : calculatePercent(usedSpace, totalSpace);

            return StorageItem(
              percent: percent,
              title: list[safeIdx],
              path: path,
              usedSpace: usedSpace,
              freeSpace: totalSpace - usedSpace,
              onItemChange: handleStorageItemChanged,
              items: list,
            );
          },
        ),
      ),
    );
  }

  double calculatePercent(int usedSpace, int totalSpace) {
    return double.parse((usedSpace / totalSpace * 100).toStringAsFixed(1));
  }

  void handleStorageItemChanged(String? value) {
    if (value == null) return;
    if (value.toString() == 'Device') {
      idx = 0;
    } else if (value.toString() == 'SD') {
      idx = 1;
    }
    setState(() {});
  }
}
