// ignore_for_file: unused_import

import 'package:flutter/material.dart';

import '../screens/main/browse.dart';
import '../screens/main/settings.dart';
import '../screens/main/share.dart';
import '../utils/icon_font_helper.dart';
import '../utils/navigate.dart';
import '../utils/theme_config.dart';
import 'icon_font.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 100,
        ),
        child: Column(children: [
          Container(
            height: 150,
            width: 150,
            margin: const EdgeInsets.only(bottom: 50),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor.withOpacity(0.1),
              borderRadius: const BorderRadius.all(
                Radius.circular(40),
              ),
            ),
            child: const Image(
              image: AssetImage('assets/imgs/logo/512px.png'),
            ),
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          ListTile(
            leading: const IconFont(size: 30, iconName: IconFontHelper.folder),
            title: const Text('Browse'),
            onTap: () {
              Navigate.pushPageReplacement(context, const Browse());
            },
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          ListTile(
            leading: const IconFont(size: 30, iconName: IconFontHelper.share),
            title: const Text('Share'),
            onTap: () {
              Navigate.pushPageReplacement(context, const Share());
            },
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          ListTile(
            leading:
                const IconFont(size: 30, iconName: IconFontHelper.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigate.pushPageReplacement(context, const Settings());
            },
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
        ]),
      ),
    );
  }
}
