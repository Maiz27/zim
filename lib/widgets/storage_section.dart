import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/core_provider.dart';
import 'custom_loader.dart';
import 'storage_item.dart';

var idx = 0;

class StorageSection extends StatefulWidget {
  const StorageSection({super.key});

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection> {
  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;

    var list = ['Device'];

    int usedSpace;
    int totalSpace;
    double percent;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Center(
        child: Container(
          height: deviceHeight * 0.48,
          width: deviceWidth * 0.9,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: const BorderRadius.all(
              Radius.circular(40),
            ),
          ),
          child: Column(children: [
            Consumer<CoreProvider>(
                builder: (BuildContext context, coreProvider, Widget? child) {
              if (coreProvider.storageLoading) {
                return SizedBox(height: 100, child: CustomLoader());
              }
              FileSystemEntity item = coreProvider.availableStorage[idx];

              String path = item.path.split('Android')[idx];

              if (coreProvider.availableStorage.length == 2) {
                list.add('SD');
              }

              if (idx == 0) {
                percent = calculatePercent(
                    coreProvider.usedSpace, coreProvider.totalSpace);
                usedSpace = coreProvider.usedSpace;
                totalSpace = coreProvider.totalSpace;
              } else {
                percent = calculatePercent(
                    coreProvider.usedSDSpace, coreProvider.totalSDSpace);
                usedSpace = coreProvider.usedSDSpace;
                totalSpace = coreProvider.totalSDSpace;
              }

              return StorageItem(
                percent: percent,
                title: list[idx],
                path: path,
                usedSpace: usedSpace,
                totalSpace: totalSpace,
                onItemChange: handleStorageItemChanged,
                items: list,
              );
            }),
          ]),
        ),
      ),
    );
  }

  calculatePercent(int usedSpace, int totalSpace) {
    return double.parse((usedSpace / totalSpace * 100).toStringAsFixed(1));
  }

  handleStorageItemChanged(String value) {
    if (value.toString() == 'Device') {
      idx = 0;
    } else if (value.toString() == 'SD') {
      idx = 1;
    }
    setState(() {});
  }
}
