import 'dart:math';
import 'dart:ui' as ui;

import 'package:doodles/color_toolbar.dart';
import 'package:doodles/cute_canvas.dart';
import 'package:doodles/drawing_viewer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'save_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unison Doodles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 10, 72, 180)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Unison Doodles'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final colors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  int selectedColor = 0;

  List<DrawCommand> commands = [];

  // ByteData? savedImageData;

  ui.Image? savedImage;

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final canvasSize =
        min<double>(MediaQuery.of(context).size.shortestSide - 60, 700);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("🎨 ${widget.title}"),
        actions: [
          FilledButton(
            onPressed: () {
              _launchUrl(Uri.parse(
                  "https://share.unison-lang.org/@rlmark/cloudDoodles"));
            },
            child: const Text("Source Code"),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              _launchUrl(Uri.parse("https://www.unison.cloud/"));
            },
            child: const Text("About The Cloud"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("🧑‍🎨 Draw something",
                          style: theme.textTheme.headlineMedium),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: canvasSize,
                          height: canvasSize,
                          child: CuteCanvas(
                            size: canvasSize,
                            color: colors[selectedColor],
                            commands: commands,
                            onCommand: (command) {
                              setState(() {
                                commands.add(command);
                              });
                            },
                          ),
                        ),
                        ColorToolbar(
                          colors: colors,
                          selectedColor: selectedColor,
                          onColorSelected: (index) {
                            setState(() {
                              selectedColor = index;
                            });
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                commands = [];
                              });
                            },
                            child: const Text("Clear"),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => SaveDialog(
                                  canvasSize: canvasSize,
                                  onSave: (imageData) async {
                                    final codec =
                                        await ui.instantiateImageCodec(
                                            imageData.buffer.asUint8List());
                                    final frame = await codec.getNextFrame();
                                    setState(() {
                                      savedImage = frame.image;
                                    });
                                  },
                                  commands: commands,
                                ),
                              );
                            },
                            child: const Text("Save"),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "🖼 Gallery",
                  style: theme.textTheme.headlineLarge!.copyWith(height: 2),
                ),
                Text(
                  "Everyone's work is here for now!",
                  style: theme.textTheme.bodyLarge!.copyWith(height: 2),
                ),
                if (savedImage != null) Text("SAVED IMAGE: $savedImage"),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.extent(
                    shrinkWrap: true,
                    maxCrossAxisExtent: 350,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.filled(
                      10,
                      savedImage == null
                          ? const Text("no drawing")
                          : DrawingViewer(
                              image: savedImage!,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
