import 'package:flutter/material.dart';
import 'package:zim/providers/app_provider.dart';

class IconFont extends StatelessWidget {
  final Color? color;
  final double size;
  final String iconName;

  const IconFont(
      {super.key, this.color, required this.size, required this.iconName});

  @override
  Widget build(BuildContext context) {
    return Text(
      iconName,
      style: TextStyle(
        color: color ?? AppProvider().theme.textTheme.headline6!.color,
        fontSize: size,
        fontFamily: 'Icons',
      ),
    );
  }
}
