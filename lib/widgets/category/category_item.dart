import 'package:flutter/material.dart';
import 'package:zim/utils/navigate.dart';

import '../icon_font.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String icon;
  final MaterialColor color;
  final Widget screen;

  const CategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigate.pushPage(context, screen);
      },
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color[200],
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Center(
                  child: IconFont(iconName: icon, size: 26, color: color[700]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
