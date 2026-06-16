import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_lib;
import 'package:zim/utils/design_tokens.dart';

import '../../services/file_repository.dart';
import '../../utils/dialogs.dart';
import '../custom_alert.dart';
import 'dialog_actions.dart';

class RenameFileDialog extends StatefulWidget {
  final String path;
  final String type;

  const RenameFileDialog({super.key, required this.path, required this.type});

  @override
  State<RenameFileDialog> createState() => _RenameFileDialogState();
}

class _RenameFileDialogState extends State<RenameFileDialog> {
  final TextEditingController name = TextEditingController();

  @override
  void initState() {
    super.initState();
    name.text = path_lib.basename(widget.path);
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (name.text.isEmpty) return;
    final entity = widget.type == 'file'
        ? File(widget.path)
        : Directory(widget.path);
    try {
      await const FileRepository().rename(entity, name.text);
    } on FileOpException catch (e) {
      Dialogs.showToast(e.message);
    }
    if (!mounted) return;
    Navigator.pop(context);
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
              'Rename Item',
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
              confirmLabel: 'Rename',
              onCancel: () => Navigator.pop(context),
              onConfirm: _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
