import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/consts.dart';
import '../utils/design_tokens.dart';

class SortSheet extends StatefulWidget {
  const SortSheet({super.key});

  @override
  State<SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<SortSheet> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sort by'.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: ListView.builder(
                itemCount: Constants.sortList.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool selected =
                      index ==
                      Provider.of<SettingsProvider>(
                        context,
                        listen: false,
                      ).sort;
                  return ListTile(
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await Provider.of<SettingsProvider>(
                        context,
                        listen: false,
                      ).setSort(index);
                      navigator.pop();
                    },
                    contentPadding: EdgeInsets.zero,
                    trailing: selected
                        ? Icon(
                            Icons.check,
                            color: colorScheme.primary,
                            size: 18,
                          )
                        : const SizedBox.shrink(),
                    title: Text(
                      '${Constants.sortList[index]}',
                      style: textTheme.bodyLarge?.copyWith(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
