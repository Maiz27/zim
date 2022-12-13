import 'package:flutter/material.dart';

class DirPopup extends StatelessWidget {
  final String path;
  final Function? popTap;

  DirPopup({
    Key? key,
    required this.path,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (val) => popTap!(val),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Text(
            'Rename',
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Text(
            'Delete',
          ),
        ),
      ],
      icon: Icon(
        Icons.arrow_drop_down,
        color: Theme.of(context).textTheme.headline6!.color,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      offset: Offset(0, 30),
    );
  }
}
