import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/category_provider.dart';
import '../utils/navigate.dart';
import '../utils/theme_config.dart';
import 'about.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    check();
  }

  int sdkVersion = 0;

  check() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      sdkVersion = androidInfo.version.sdkInt;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.all(0),
            secondary: const Icon(
              Icons.hide_source,
            ),
            title: const Text(
              'See hidden files',
            ),
            value: Provider.of<CategoryProvider>(context).showHidden,
            onChanged: (value) {
              Provider.of<CategoryProvider>(context, listen: false)
                  .setHidden(value);
            },
            activeColor: Theme.of(context).accentColor,
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          MediaQuery.of(context).platformBrightness !=
                  ThemeConfig.darkTheme.brightness
              ? SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.all(0),
                  secondary: const Icon(
                    Icons.motion_photos_on,
                  ),
                  title: const Text('Dark mode'),
                  value: Provider.of<AppProvider>(context).theme ==
                          ThemeConfig.lightTheme
                      ? false
                      : true,
                  onChanged: (v) {
                    if (v) {
                      Provider.of<AppProvider>(context, listen: false)
                          .setTheme(ThemeConfig.darkTheme, 'dark');
                    } else {
                      Provider.of<AppProvider>(context, listen: false)
                          .setTheme(ThemeConfig.lightTheme, 'light');
                    }
                  },
                  activeColor: Theme.of(context).accentColor,
                )
              : const SizedBox(),
          MediaQuery.of(context).platformBrightness !=
                  ThemeConfig.darkTheme.brightness
              ? Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                )
              : const SizedBox(),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            onTap: () => showLicensePage(context: context),
            leading: const Icon(Icons.text_fields_outlined),
            title: const Text('Open source licenses'),
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            onTap: () => Navigate.pushPage(context, About()),
            leading: const Icon(Icons.info),
            title: const Text('About'),
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
  }
}
