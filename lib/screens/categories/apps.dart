import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../models/entry.dart';
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
  // Created once so the installed-apps query doesn't re-run on every rebuild.
  late final Future<List<AppInfo>> _installedApps;

  @override
  void initState() {
    super.initState();
    _installedApps = FlutterDeviceApps.listApps(
      onlyLaunchable: true,
      includeSystem: true,
      includeIcons: true,
    );
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

  Widget _apksTab(List<Entry> apks) {
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
      future: _installedApps,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load apps',
            message: 'The installed app list is unavailable right now.',
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const CustomLoader();
        }
        final data = snapshot.data ?? <AppInfo>[];
        if (data.isEmpty) {
          return const EmptyState(
            icon: Icons.apps_outlined,
            title: 'No apps found',
            message: 'Installed apps will appear here.',
          );
        }
        // Sort the App List on Alphabetical Order
        data.sort(
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
      },
    );
  }
}
