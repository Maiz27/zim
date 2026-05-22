import 'package:flutter/material.dart';

import '../../utils/theme_config.dart';

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
    final foreground =
        Theme.of(context).textTheme.bodyMedium?.color ?? ThemeConfig.darkBg;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: foreground.withValues(alpha: 0.4)),
            ),
            child: Text(cancelLabel, style: TextStyle(color: foreground)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: confirmEnabled ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmLabel,
              style: TextStyle(color: ThemeConfig.darkBg),
            ),
          ),
        ),
      ],
    );
  }
}
