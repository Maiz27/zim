import 'dart:io';

import 'package:flutter_device_apps/flutter_device_apps.dart';
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

class Apps extends StatefulWidget {
  final String title;
  const Apps({super.key, required this.title});

  @override
  State<Apps> createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).getThumbnailFiles('application');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
            if (provider.loading) {
              return const Scaffold(body: CustomLoader());
            }
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Apps'),
                  bottom: const TabBar(
                    isScrollable: false,
                    tabs: [
                      Tab(text: 'Apks'),
                      Tab(text: 'Installed'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    _apksTab(provider.thumbnailFiles),
                    _installedTab(),
                  ],
                ),
              ),
            );
          },
    );
  }

  Widget _apksTab(List<FileSystemEntity> apks) {
    if (apks.isEmpty) {
      return const EmptyState(
        icon: Icons.android,
        title: 'No APKs yet',
        message: 'Installable app packages on your device will appear here.',
      );
    }
    return ListView.separated(
      itemCount: apks.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedEntrance(
          index: index,
          child: FileItem(file: apks[index]),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const CustomDivider();
      },
    );
  }

  Widget _installedTab() {
    return FutureBuilder<List<AppInfo>>(
      future: FlutterDeviceApps.listApps(
        onlyLaunchable: true,
        includeSystem: true,
        includeIcons: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<AppInfo>? data = snapshot.data;
          // Sort the App List on Alphabetical Order
          data!.sort(
            (app1, app2) => (app1.appName ?? '').toLowerCase().compareTo(
              (app2.appName ?? '').toLowerCase(),
            ),
          );
          return ListView.separated(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              AppInfo app = data[index];
              String? packageName = app.packageName;
              return AnimatedEntrance(
                index: index,
                child: ListTile(
                  leading: app.iconBytes != null
                      ? Image.memory(app.iconBytes!, height: 40, width: 40)
                      : null,
                  title: Text(app.appName ?? 'Unknown app'),
                  subtitle: Text(packageName ?? ''),
                  onTap: packageName == null
                      ? null
                      : () => FlutterDeviceApps.openApp(packageName),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const CustomDivider();
            },
          );
        }
        return const CustomLoader();
      },
    );
  }
}
