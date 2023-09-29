import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'cute_canvas.dart';

class SaveDialog extends StatelessWidget {
  final List<DrawCommand> commands;
  final void Function(ByteData) onSave;

  const SaveDialog({super.key, required this.commands, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Save your drawing"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        const TextField(
          autofocus: true,
          decoration: InputDecoration(
            // border: OutlineInputBorder(),
            labelText: 'Title',
            // floatingLabelBehavior: FloatingLabelBehavior.always,
            helperText: 'Give your drawing a title',
          ),
        ),
        const SizedBox(height: 30, width: 300),
        const TextField(
          decoration: InputDecoration(
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
                drawCommands(canvas, commands);
                final picture = recorder.endRecording();

                final image = await picture.toImage(200, 200);
                final byteData =
                    await image.toByteData(format: ui.ImageByteFormat.png);

                onSave(byteData!);
              },
              child: const Text("Save"),
            ),
          ],
        )
      ],
    );
  }
}
