import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../screens/folder.dart';
import '../../utils/file_utils.dart';
import '../../utils/navigate.dart';
import '../../utils/theme_config.dart';

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
    return InkWell(
      onTap: () {
        Navigate.pushPage(context, Folder(path: path, title: title));
      },
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: ThemeConfig.primary,
                        ),
                      ),
                    ),
                ],
                onChanged: onItemChange,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CircularPercentIndicator(
                  progressColor: Theme.of(context).progressIndicatorTheme.color,
                  radius: dialRadius,
                  lineWidth: 22,
                  percent: (percent / 100).clamp(0.0, 1.0),
                  animation: true,
                  animationDuration: 1000,
                  backgroundColor: Theme.of(
                    context,
                  ).progressIndicatorTheme.circularTrackColor!,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$percent%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Used',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _LegendTile(
                        color: ThemeConfig.primary,
                        label: 'Used',
                        value: FileUtils.formatBytes(usedSpace, 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LegendTile(
                        color: Theme.of(
                          context,
                        ).progressIndicatorTheme.circularTrackColor,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
