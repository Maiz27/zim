import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../screens/folder.dart';
import '../../utils/design_tokens.dart';
import '../../utils/file_utils.dart';
import '../../utils/navigate.dart';
import '../motion.dart';

class StorageItem extends StatelessWidget {
  final double percent;
  final String title;
  final String path;
  final int usedSpace;
  final int freeSpace;
  final ValueChanged<String?> onItemChange;
  final List<String> items;

  const StorageItem({
    super.key,
    required this.percent,
    required this.title,
    required this.path,
    required this.usedSpace,
    required this.freeSpace,
    required this.onItemChange,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PressableScale(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            Navigate.pushPage(context, Folder(path: path, title: title));
          },
          borderRadius: AppRadius.brLg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Dial size is capped so it never dwarfs the rest of the card on
              // tablets or oversized phones.
              final double dialRadius =
                  (constraints.maxWidth * 0.32).clamp(70.0, 120.0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: items.contains(title) ? title : null,
                    items: [
                      for (final value in items)
                        DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                    ],
                    onChanged: onItemChange,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: CircularPercentIndicator(
                      progressColor: colorScheme.primary,
                      radius: dialRadius,
                      lineWidth: 22,
                      percent: (percent / 100).clamp(0.0, 1.0),
                      animation: true,
                      animationDuration: 1000,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$percent%',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Used',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: _LegendTile(
                            color: colorScheme.primary,
                            label: 'Used',
                            value: FileUtils.formatBytes(usedSpace, 2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _LegendTile(
                            color: colorScheme.surfaceContainerHighest,
                            label: 'Free',
                            value: FileUtils.formatBytes(freeSpace, 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LegendTile extends StatelessWidget {
  final Color? color;
  final String label;
  final String value;

  const _LegendTile({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            borderRadius: AppRadius.brSm,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
