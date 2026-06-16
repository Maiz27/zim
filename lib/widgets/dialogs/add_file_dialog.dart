import 'package:flutter/material.dart';
import 'package:zim/utils/design_tokens.dart';

import '../../services/file_repository.dart';
import '../../utils/dialogs.dart';
import '../custom_alert.dart';
import 'dialog_actions.dart';

class AddFileDialog extends StatefulWidget {
  final String path;

  const AddFileDialog({super.key, required this.path});

  @override
  State<AddFileDialog> createState() => _AddFileDialogState();
}

class _AddFileDialogState extends State<AddFileDialog> {
  final TextEditingController name = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlert(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add New Folder',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: name,
              keyboardType: TextInputType.text,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            DialogActions(
              confirmLabel: 'Create',
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
                if (name.text.isEmpty) return;
                try {
                  await const FileRepository().createDirectory(
                    widget.path,
                    name.text,
                  );
                } on FileOpException catch (e) {
                  Dialogs.showToast(e.message);
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
