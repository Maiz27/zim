import 'package:flutter/material.dart';
import 'package:zim/utils/design_tokens.dart';
import 'package:zim/utils/navigate.dart';

import '../icon_font.dart';
import '../motion.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String icon;
  final MaterialColor color;
  final WidgetBuilder screen;

  const CategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Keep each category's colour identity, but render as a soft tonal tile.
    final Color tileColor = color.withValues(alpha: 0.16);
    final Color glyphColor = isDark
        ? Color.lerp(color, Colors.white, 0.3)!
        : color.shade700;

    return PressableScale(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            Navigate.pushPage(context, screen(context));
          },
          borderRadius: AppRadius.brLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: AppRadius.brLg,
                    ),
                    child: Center(
                      child: IconFont(
                        iconName: icon,
                        size: 26,
                        color: glyphColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
