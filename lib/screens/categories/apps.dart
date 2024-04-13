import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../utils/consts.dart';
import '../../widgets/custom_divider.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/file/file_item.dart';

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
      Provider.of<CategoryProvider>(context, listen: false)
          .getThumbnailFiles('application');
    });
  }

  int idx = 0;

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
              bottom: TabBar(
                indicatorColor: Theme.of(context).colorScheme.secondary,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor:
                    Theme.of(context).textTheme.caption!.color,
                isScrollable: false,
                tabs: Constants.map<Widget>(
                  ['Apks', 'Installed'],
                  (index, label) {
                    return Tab(text: '$label');
                  },
                ),
                onTap: (val) {
                  setState(() {
                    idx = val;
                  });
                },
              ),
            ),
            body: idx == 0
                ? Visibility(
                    visible: provider.thumbnailFiles.isNotEmpty,
                    replacement: const Center(child: Text('No Files Found')),
                    child: ListView.separated(
                      itemCount: provider.currentFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return FileItem(
                          file: provider.currentFiles[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const CustomDivider();
                      },
                    ))
                : FutureBuilder<List<Application>>(
                    future: DeviceApps.getInstalledApplications(
                      onlyAppsWithLaunchIntent: true,
                      includeSystemApps: true,
                      includeAppIcons: true,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Application>? data = snapshot.data;
                        // Sort the App List on Alphabetical Order
                        data!.sort((app1, app2) => app1.appName
                            .toLowerCase()
                            .compareTo(app2.appName.toLowerCase()));
                        return ListView.separated(
                          padding: const EdgeInsets.only(left: 10),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            Application app = data[index];
                            return ListTile(
                              leading: app is ApplicationWithIcon
                                  ? Image.memory(app.icon,
                                      height: 40, width: 40)
                                  : null,
                              title: Text(app.appName),
                              subtitle: Text(app.packageName),
                              onTap: () => DeviceApps.openApp(app.packageName),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const CustomDivider();
                          },
                        );
                      }
                      return const CustomLoader();
                    },
                  ),
          ),
        );
      },
    );
  }
}
