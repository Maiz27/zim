import 'package:flutter/material.dart';
import 'package:zim/screens/main/browse.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../utils/design_tokens.dart';
import '../utils/navigate.dart';
import '../widgets/motion.dart';

/// First-run hero. Keeps Zim's layered-folder identity but rebuilds it on
/// tokens: the stacked folders fade and settle in with a gentle stagger, and
/// the headline + CTA sit on a dark gradient panel so they stay legible no
/// matter where the folders land on a given screen.
class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  // Brand stack, deepest at the bottom where the copy sits.
  static const List<Color> _folderColors = [
    AppPalette.tealBright,
    AppPalette.blue,
    AppPalette.teal,
    AppPalette.navy,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            // Layered folder backdrop scales with width and stays in frame on
            // short / landscape screens via clamped step + offset.
            final folderSize = width + 35;
            final folderStep = (height * 0.15).clamp(80.0, 160.0);
            final topOffset = (height * 0.12).clamp(40.0, 140.0);

            return Stack(
              fit: StackFit.expand,
              children: [
                for (int i = 0; i < _folderColors.length; i++)
                  Positioned(
                    top: topOffset + folderStep * i,
                    left: -AppSpacing.xl,
                    child: AnimatedEntrance(
                      index: i,
                      child: IconFont(
                        iconName: IconFontHelper.folder,
                        color: _folderColors[i],
                        size: folderSize,
                      ),
                    ),
                  ),

                // Settled bottom panel: a soft fade to brand navy that anchors
                // the copy and guarantees contrast over the folders.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    child: Container(
                      height: height * 0.46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppPalette.navy.withValues(alpha: 0),
                            AppPalette.navy.withValues(alpha: 0.88),
                            AppPalette.navy,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Wordmark, sitting on the scaffold surface (theme-aware).
                Positioned(
                  top: (height * 0.06).clamp(16.0, 64.0),
                  left: width * 0.05,
                  child: AnimatedEntrance(
                    child: Text(
                      'Zim',
                      style: text.displaySmall?.copyWith(
                        color: scheme.onSurface,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                // Headline, sub and CTA on the settled panel.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                      AppSpacing.xxl,
                    ),
                    child: AnimatedEntrance(
                      index: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'The easiest way to manage your data.',
                            textAlign: TextAlign.center,
                            style: text.headlineMedium?.copyWith(
                              color: AppPalette.mist,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'A file manager to make your life easier.',
                            textAlign: TextAlign.center,
                            style: text.bodyLarge?.copyWith(
                              color: AppPalette.mist.withValues(alpha: 0.82),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Align(
                            alignment: Alignment.centerRight,
                            child: PressableScale(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppPalette.mist,
                                  foregroundColor: AppPalette.navy,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xxxl,
                                    vertical: AppSpacing.lg,
                                  ),
                                ),
                                onPressed: () => Navigate.pushPageReplacement(
                                  context,
                                  const Browse(),
                                ),
                                child: Text(
                                  'Get Started',
                                  style: text.titleMedium?.copyWith(
                                    color: AppPalette.navy,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
