import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_lib;

import '../../../utils/dialogs.dart';
import '../../../widgets/custom_alert.dart';

class RenameFileDialog extends StatefulWidget {
  final String path;
  final String type;

  const RenameFileDialog({super.key, required this.path, required this.type});

  @override
  _RenameFileDialogState createState() => _RenameFileDialogState();
}

class _RenameFileDialogState extends State<RenameFileDialog> {
  final TextEditingController name = TextEditingController();

  @override
  void initState() {
    super.initState();
    name.text = path_lib.basename(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlert(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 15),
            const Text(
              'Rename Item',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: name,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: 40,
                  width: 130,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      side: MaterialStateProperty.all(
                        BorderSide(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 130,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (name.text.isNotEmpty) {
                        if (widget.type == 'file') {
                          if (!File(widget.path.replaceAll(
                                      path_lib.basename(widget.path), '') +
                                  name.text)
                              .existsSync()) {
                            await File(widget.path)
                                .rename(widget.path.replaceAll(
                                        path_lib.basename(widget.path), '') +
                                    name.text)
                                .catchError((e) {
                              // print(e.toString());
                              if (e.toString().contains('Permission denied')) {
                                Dialogs.showToast(
                                    'Cannot write to this device!');
                              }
                            });
                          } else {
                            Dialogs.showToast(
                                'A File with that name already exists!');
                          }
                        } else {
                          if (Directory(widget.path.replaceAll(
                                      path_lib.basename(widget.path), '') +
                                  name.text)
                              .existsSync()) {
                            Dialogs.showToast(
                                'A Folder with that name already exists!');
                          } else {
                            await Directory(widget.path)
                                .rename(widget.path.replaceAll(
                                        path_lib.basename(widget.path), '') +
                                    name.text)
                                .catchError((e) {
                              // print(e.toString());
                              if (e.toString().contains('Permission denied')) {
                                Dialogs.showToast(
                                    'Cannot write to this device!');
                              }
                            });
                          }
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.secondary),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Rename',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
