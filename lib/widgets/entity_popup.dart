import 'package:flutter/material.dart';

/// Action chosen from an [EntityPopup]: 0 = Rename, 1 = Delete, 2 = Decompress.
typedef EntityAction = void Function(int value);

/// Overflow menu shared by file and folder rows. Decompress is only offered
/// when [canDecompress] is set.
class EntityPopup extends StatelessWidget {
  const EntityPopup({
    super.key,
    required this.onAction,
    this.canDecompress = false,
  });

  final EntityAction onAction;
  final bool canDecompress;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: onAction,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0, child: Text('Rename')),
        const PopupMenuItem(value: 1, child: Text('Delete')),
        if (canDecompress)
          const PopupMenuItem(value: 2, child: Text('Decompress')),
      ],
      icon: Icon(
        Icons.arrow_drop_down,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      offset: const Offset(0, 30),
    );
  }
}
