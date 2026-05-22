import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zim/utils/theme_config.dart';

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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 8),
            const Text(
              'Add New Folder',
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
              confirmLabel: 'Create',
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
                if (name.text.isEmpty) return;
                final target = Directory('${widget.path}/${name.text}');
                if (target.existsSync()) {
                  Dialogs.showToast('A Folder with that name already exists!');
                } else {
                  try {
                    await target.create();
                  } catch (e) {
                    if (e.toString().contains('Permission denied')) {
                      Dialogs.showToast(
                        'Cannot write to this Storage device!',
                      );
                    }
                  }
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
