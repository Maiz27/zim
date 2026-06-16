import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zim/utils/design_tokens.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../../providers/app_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/navigate.dart';
import '../../widgets/app_drawer.dart';
import '../about.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const AppDrawer(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const _SectionLabel('Appearance'),
            const _ThemeModeSelector(),
            const SizedBox(height: AppSpacing.xxl),
            const _SectionLabel('Files'),
            _SettingsCard(
              children: [
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    secondary: const IconFont(
                      size: 24,
                      iconName: IconFontHelper.hidden,
                    ),
                    title: const Text('Show hidden files'),
                    subtitle: const Text('Display files and folders that start with a dot'),
                    value: settings.showHidden,
                    onChanged: (value) =>
                        context.read<SettingsProvider>().setHidden(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _SectionLabel('General'),
            _SettingsCard(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  onTap: () => Navigate.pushPage(context, const About()),
                  leading: const IconFont(
                    size: 24,
                    iconName: IconFontHelper.info,
                  ),
                  title: const Text('About'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
        top: AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: children));
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final mode = context.select<AppProvider, ThemeMode>((p) => p.themeMode);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto_outlined),
            label: Text('System'),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Light'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Dark'),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selection) =>
            context.read<AppProvider>().setThemeMode(selection.first),
      ),
    );
  }
}
