import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'cute_canvas.dart';

class SaveDialog extends StatefulWidget {
  final List<DrawCommand> commands;
  final double canvasSize;
  final bool isSaving;
  final void Function(String, String, ByteData) onSave;

  const SaveDialog({
    super.key,
    required this.commands,
    required this.onSave,
    required this.canvasSize,
    required this.isSaving,
  });

  @override
  State<SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Save your drawing"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        TextField(
          autofocus: true,
          controller: _titleController,
          decoration: const InputDecoration(
            // border: OutlineInputBorder(),
            labelText: 'Title',
            // floatingLabelBehavior: FloatingLabelBehavior.always,
            helperText: 'Give your drawing a title',
          ),
        ),
        const SizedBox(height: 30, width: 300),
        TextField(
          controller: _authorController,
          decoration: const InputDecoration(
            // border: OutlineInputBorder(),
            // floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: 'Author',
            helperText: 'Who made this work of art?',
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final recorder = ui.PictureRecorder();
                final canvas = Canvas(recorder);
                drawCommands(canvas, widget.commands);
                final picture = recorder.endRecording();

                final image = await picture.toImage(
                  widget.canvasSize.toInt(),
                  widget.canvasSize.toInt(),
                );
                final byteData =
                    await image.toByteData(format: ui.ImageByteFormat.png);

                widget.onSave(
                  _titleController.text,
                  _authorController.text,
                  byteData!,
                );
              },
              child: widget.isSaving ? const Text("Saving....") : const Text("Save"),
            ),
          ],
        )
      ],
    );
  }
}
