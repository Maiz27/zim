import 'dart:ui';

import 'package:flutter/material.dart';

/// Themed wrapper around [Dialog] used by the file-management dialogs.
///
/// Previously this was a full-screen `Stack` with an `Expanded` Column, which
/// fought the keyboard inset and didn't honor Material dialog insets. Using
/// [Dialog] gives us correct sizing on phones/tablets and avoids the dialog
/// being pushed off-screen when the soft keyboard opens.
class CustomAlert extends StatelessWidget {
  final Widget child;

  const CustomAlert({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ),
    );
  }
}
