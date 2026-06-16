import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../utils/design_tokens.dart';

class PathBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> paths;
  final Function(int) onChanged;
  final IconData? icon;

  const PathBar({
    super.key,
    required this.paths,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 50,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: paths.length,
          itemBuilder: (BuildContext context, int index) {
            final bool active = index == paths.length - 1;
            final Color segmentColor = active
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant;
            final String segment = p.basename(paths[index]);
            if (index == 0) {
              return IconButton(
                icon: Icon(icon ?? Icons.smartphone, color: segmentColor),
                onPressed: () => onChanged(index),
              );
            }
            return InkWell(
              onTap: () => onChanged(index),
              borderRadius: AppRadius.brSm,
              child: SizedBox(
                height: 40,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Text(
                      segment,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: segmentColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}
