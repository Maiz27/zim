import 'package:flutter/material.dart';
import 'package:zim/utils/design_tokens.dart';

/// Confirm / Cancel button row used by the file-management dialogs.
///
/// Buttons share remaining width via [Expanded], so the dialog renders cleanly
/// on narrow devices where two fixed-width buttons would overflow.
class DialogActions extends StatelessWidget {
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool confirmEnabled;

  const DialogActions({
    super.key,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.confirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            child: Text(cancelLabel),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton(
            onPressed: confirmEnabled ? onConfirm : null,
            child: Text(confirmLabel),
          ),
        ),
      ],
    );
  }
}
