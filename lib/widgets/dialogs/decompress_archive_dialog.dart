import 'package:flutter/material.dart';
import 'package:zim/utils/design_tokens.dart';
import 'package:zim/utils/icon_font_helper.dart';
import 'package:zim/widgets/icon_font.dart';

import '../../services/file_repository.dart';
import '../../utils/dialogs.dart';
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
  bool loading = false;

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
    try {
      await const FileRepository().extract(widget.path, outputDir.text);
      if (!mounted) return;
      Navigator.pop(context);
      Dialogs.showToast('Archive decompressed Successfully');
    } on FileOpException catch (e) {
      if (!mounted) return;
      Dialogs.showToast(e.message);
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final archiveColors =
        FilePalette.of(FileKind.archive, theme.brightness);
    return CustomAlert(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Decompress Archive',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: archiveColors.container,
                  borderRadius: AppRadius.brMd,
                ),
                child: IconFont(
                  iconName: IconFontHelper.archive,
                  color: archiveColors.icon,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.path.split('/').last,
              softWrap: true,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Output Directory:',
              style: theme.textTheme.titleMedium,
            ),
            TextField(
              controller: outputDir,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: AppSpacing.sm),
            DialogActions(
              confirmLabel: 'Decompress',
              confirmEnabled: !loading,
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
