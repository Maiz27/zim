import 'package:flutter/material.dart';

class IconFont extends StatelessWidget {
  final Color? color;
  final double? size;
  final String iconName;

  const IconFont({super.key, this.color, this.size, required this.iconName});

  @override
  Widget build(BuildContext context) {
    return Text(
      iconName,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color ?? Theme.of(context).textTheme.bodySmall?.color,
        fontSize: size ?? Theme.of(context).iconTheme.size,
        fontFamily: 'Icons',
      ),
    );
  }
}
