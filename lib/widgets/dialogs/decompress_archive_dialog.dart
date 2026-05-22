import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zim/utils/file_utils.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../../utils/dialogs.dart';
import '../../utils/theme_config.dart';
import '../custom_alert.dart';
import 'dialog_actions.dart';

class DecompressArchiveDialog extends StatefulWidget {
  final String path;
  final String parent;
  const DecompressArchiveDialog({
    super.key,
    required this.path,
    required this.parent,
  });

  @override
  State<DecompressArchiveDialog> createState() =>
      _DecompressArchiveDialogState();
}

class _DecompressArchiveDialogState extends State<DecompressArchiveDialog> {
  final TextEditingController outputDir = TextEditingController();
  bool loading = FileUtils.decompressing;

  @override
  void initState() {
    super.initState();
    outputDir.text = widget.parent;
  }

  @override
  void dispose() {
    outputDir.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (loading) return;
    setState(() => loading = true);
    if (!Directory(outputDir.text).existsSync()) {
      try {
        await Directory(outputDir.text).create(recursive: true);
      } catch (e) {
        if (e.toString().contains('Permission denied')) {
          Dialogs.showToast('Cannot write to this Storage device!');
        }
      }
    }
    final success =
        await FileUtils.extractArchive(widget.path, outputDir.text);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      Dialogs.showToast('Archive decompressed Successfully');
    } else {
      setState(() => loading = false);
    }
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
          children: [
            const SizedBox(height: 8),
            const Text(
              'Decompress Archive',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            IconFont(
              iconName: IconFontHelper.archive,
              color: Colors.purple[700],
              size: 25,
            ),
            const SizedBox(height: 10),
            Text(
              widget.path.split('/').last,
              softWrap: true,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Output Directory:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: outputDir,
              keyboardType: TextInputType.text,
              cursorColor: ThemeConfig.primary,
            ),
            const SizedBox(height: 16),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 8),
            DialogActions(
              confirmLabel: 'Decompress',
              confirmEnabled: !loading,
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
