import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zim/utils/file_utils.dart';
import 'package:zim/utils/theme_config.dart';

void main() {
  test('formats bytes with binary units', () {
    expect(FileUtils.formatBytes(0, 1), '0.0 KB');
    expect(FileUtils.formatBytes(1024, 1), '1.0 KB');
    expect(FileUtils.formatBytes(1536, 1), '1.5 KB');
  });

  test('removes Android app data suffix from storage paths', () {
    expect(
      FileUtils.removeDataDirectory(
        '/storage/emulated/0/Android/data/dev.maiz.zim/files',
      ).path,
      '/storage/emulated/0/',
    );
  });

  test('theme config builds matching light and dark Material 3 schemes', () {
    expect(ThemeConfig.lightTheme.colorScheme.brightness, Brightness.light);
    expect(ThemeConfig.darkTheme.colorScheme.brightness, Brightness.dark);

    // Surface now follows brightness (the old config mis-assigned these:
    // a dark surface in the light theme and vice versa).
    expect(
      ThemeConfig.lightTheme.colorScheme.surface.computeLuminance(),
      greaterThan(0.5),
    );
    expect(
      ThemeConfig.darkTheme.colorScheme.surface.computeLuminance(),
      lessThan(0.5),
    );

    // Scaffold background tracks the scheme surface in both themes.
    expect(
      ThemeConfig.lightTheme.scaffoldBackgroundColor,
      ThemeConfig.lightTheme.colorScheme.surface,
    );
    expect(
      ThemeConfig.darkTheme.scaffoldBackgroundColor,
      ThemeConfig.darkTheme.colorScheme.surface,
    );
  });
}
