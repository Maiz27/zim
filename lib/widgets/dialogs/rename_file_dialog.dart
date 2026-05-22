import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_lib;
import 'package:zim/utils/theme_config.dart';

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

  String _replaceBasename(String newName) {
    final dirname = path_lib.dirname(widget.path);
    return path_lib.join(dirname, newName);
  }

  Future<void> _submit() async {
    if (name.text.isEmpty) return;
    final newPath = _replaceBasename(name.text);
    final exists = widget.type == 'file'
        ? File(newPath).existsSync()
        : Directory(newPath).existsSync();
    if (exists) {
      Dialogs.showToast(
        widget.type == 'file'
            ? 'A File with that name already exists!'
            : 'A Folder with that name already exists!',
      );
    } else {
      try {
        if (widget.type == 'file') {
          await File(widget.path).rename(newPath);
        } else {
          await Directory(widget.path).rename(newPath);
        }
      } catch (e) {
        if (e.toString().contains('Permission denied')) {
          Dialogs.showToast('Cannot write to this device!');
        }
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlert(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 8),
            const Text(
              'Rename Item',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: name,
              keyboardType: TextInputType.text,
              autofocus: true,
              cursorColor: ThemeConfig.primary,
            ),
            const SizedBox(height: 32),
            DialogActions(
              confirmLabel: 'Rename',
              onCancel: () => Navigator.pop(context),
              onConfirm: _submit,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
