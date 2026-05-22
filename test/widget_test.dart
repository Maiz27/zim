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

  test('theme config exposes app colors through modern color schemes', () {
    expect(ThemeConfig.lightTheme.colorScheme.primary, ThemeConfig.primary);
    expect(ThemeConfig.darkTheme.colorScheme.primary, ThemeConfig.primary);
    expect(ThemeConfig.lightTheme.colorScheme.surface, ThemeConfig.darkBg);
    expect(ThemeConfig.darkTheme.colorScheme.surface, ThemeConfig.lightBg);
  });
}
