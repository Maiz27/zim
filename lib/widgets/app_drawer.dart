import 'package:flutter/material.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../utils/theme_config.dart';

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
              color: ThemeConfig.darkBg.withOpacity(0.15),
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
          const ListTile(
            leading: IconFont(size: 30, iconName: IconFontHelper.folder),
            title: Text('Browse'),
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          const ListTile(
            leading: IconFont(size: 30, iconName: IconFontHelper.share),
            title: Text('Share'),
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          const ListTile(
            leading: IconFont(size: 30, iconName: IconFontHelper.settings),
            title: Text('Settings'),
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
