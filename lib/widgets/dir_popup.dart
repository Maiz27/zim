import 'package:flutter/material.dart';

class DirPopup extends StatelessWidget {
  final String path;
  final Function? popTap;

  const DirPopup({
    Key? key,
    required this.path,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (val) => popTap!(val),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0,
          child: Text(
            'Rename',
          ),
        ),
        const PopupMenuItem(
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
      offset: const Offset(0, 30),
    );
  }
}
