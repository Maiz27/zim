import 'package:flutter/material.dart';

import '../screens/main/browse.dart';
import '../screens/main/settings.dart';
import '../screens/main/share.dart';
import '../utils/design_tokens.dart';
import '../utils/icon_font_helper.dart';
import '../utils/navigate.dart';
import 'icon_font.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Container(
              height: 140,
              width: 140,
              margin: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: AppRadius.brXl,
              ),
              clipBehavior: Clip.antiAlias,
              child: const Image(
                image: AssetImage('assets/imgs/logo/512px.png'),
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const IconFont(
                size: 30,
                iconName: IconFontHelper.folder,
              ),
              title: const Text('Browse'),
              onTap: () {
                Navigate.pushPageReplacement(context, const Browse());
              },
            ),
            const Divider(),
            ListTile(
              leading: const IconFont(
                size: 30,
                iconName: IconFontHelper.share,
              ),
              title: const Text('Share'),
              onTap: () {
                Navigate.pushPageReplacement(context, const Share());
              },
            ),
            const Divider(),
            ListTile(
              leading: const IconFont(
                size: 30,
                iconName: IconFontHelper.settings,
              ),
              title: const Text('Settings'),
              onTap: () {
                Navigate.pushPageReplacement(context, const Settings());
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
