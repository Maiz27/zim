import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../../providers/app_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/navigate.dart';
import '../../utils/theme_config.dart';
import '../../widgets/app_drawer.dart';
import '../about.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.all(0),
            secondary:
                const IconFont(size: 25, iconName: IconFontHelper.hidden),
            title: const Text(
              'See hidden files',
            ),
            value: Provider.of<CategoryProvider>(context).showHidden,
            onChanged: (value) {
              Provider.of<CategoryProvider>(context, listen: false)
                  .setHidden(value);
            },
            activeColor: ThemeConfig.primary,
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.all(0),
            secondary: const IconFont(size: 25, iconName: IconFontHelper.moon),
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
            activeColor: ThemeConfig.primary,
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            onTap: () => Navigate.pushPage(context, const About()),
            leading: const IconFont(
              size: 25,
              iconName: IconFontHelper.info,
            ),
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
