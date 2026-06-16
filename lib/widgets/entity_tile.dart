import 'package:flutter/material.dart';

import '../utils/design_tokens.dart';
import 'entity_popup.dart';

/// One file/folder list row: a leading chip/icon, a title, an optional
/// subtitle, a tap action and an optional overflow menu. Shared scaffold behind
/// [FileItem] and [DirectoryItem] so both rows stay visually identical.
class EntityTile extends StatelessWidget {
  const EntityTile({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.onAction,
    this.canDecompress = false,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final EntityAction? onAction;
  final bool canDecompress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: onAction == null
          ? null
          : EntityPopup(onAction: onAction!, canDecompress: canDecompress),
    );
  }
}
