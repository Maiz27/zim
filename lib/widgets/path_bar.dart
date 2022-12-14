import 'package:flutter/material.dart';

import '../utils/theme_config.dart';

class PathBar extends StatelessWidget implements PreferredSizeWidget {
  final List paths;
  final Function(int) onChanged;
  final IconData? icon;

  const PathBar({
    Key? key,
    required this.paths,
    required this.onChanged,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: paths.length,
          itemBuilder: (BuildContext context, int index) {
            String i = paths[index];
            List split = i.split('/');
            if (index == 0) {
              return IconButton(
                icon: Icon(
                  icon ?? Icons.smartphone,
                  color: index == paths.length - 1
                      ? ThemeConfig.accent
                      : ThemeConfig.lightBg,
                ),
                onPressed: () => onChanged(index),
              );
            }
            return InkWell(
              onTap: () => onChanged(index),
              child: SizedBox(
                height: 40,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      '${split[split.length - 1]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: index == paths.length - 1
                            ? ThemeConfig.accent
                            : ThemeConfig.lightBg,
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
              color: ThemeConfig.darkBg,
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}
