import 'package:flutter/material.dart';
import 'package:zim/screens/main/browse.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../utils/navigate.dart';
import '../utils/theme_config.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            // Layered folder backdrop scales with the smaller of the two
            // dimensions, so it stays in frame on short/landscape screens.
            final folderSize = width + 35;
            final folderStep = (height * 0.15).clamp(80.0, 160.0);
            final topOffset = (height * 0.12).clamp(40.0, 140.0);

            return Stack(
              children: [
                for (int i = 0; i < 4; i++)
                  Positioned(
                    top: topOffset + folderStep * i,
                    left: -20,
                    child: IconFont(
                      iconName: IconFontHelper.folder,
                      color: [
                        ThemeConfig.accent,
                        ThemeConfig.secondary,
                        ThemeConfig.primary,
                        ThemeConfig.accent2,
                      ][i],
                      size: folderSize,
                    ),
                  ),
                Positioned(
                  top: (height * 0.06).clamp(16.0, 64.0),
                  left: width * 0.05,
                  child: const Text(
                    'Zim',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      width * 0.05,
                      16,
                      width * 0.05,
                      24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'The easiest way to manage your data.',
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            color: ThemeConfig.lightBg,
                            fontSize: 28,
                            letterSpacing: 2,
                            wordSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A file manager to make your life easier.',
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            color: ThemeConfig.lightBg.withValues(alpha: 0.8),
                            fontSize: 15,
                            letterSpacing: 1,
                            wordSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                ThemeConfig.lightBg,
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 18,
                                ),
                              ),
                              shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigate.pushPageReplacement(
                                context,
                                const Browse(),
                              );
                            },
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: ThemeConfig.darkBg,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
