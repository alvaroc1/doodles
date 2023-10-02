import 'dart:math';
import 'dart:ui' as ui;

import 'package:doodles/color_toolbar.dart';
import 'package:doodles/cute_canvas.dart';
import 'package:doodles/drawing_viewer.dart';
import 'backend_client.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'save_dialog.dart';

void main() {
  runApp(MyApp(
    backendClient: BackendClient.instance,
  ));
}

class MyApp extends StatelessWidget {
  final BackendClient backendClient;

  const MyApp({
    super.key,
    required this.backendClient,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unison Doodles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 10, 72, 180)),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Unison Doodles',
        backendClient: backendClient,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final BackendClient backendClient;

  const MyHomePage({
    super.key,
    required this.title,
    required this.backendClient,
  });

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

  final _scrollController = ScrollController();

  int selectedColor = 0;

  List<DrawCommand> commands = [];

  List<ImageData> savedImages = [];

  int? cursor = null;

  bool saving = false;

  // ByteData? savedImageData;

  ui.Image? savedImage;

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  initState() {
    super.initState();
    _loadImages();

    _scrollController.addListener(() {
      if (cursor != null && _scrollController.offset > _scrollController.position.maxScrollExtent * .7) {

        _loadNextPage();
      }
    });
  }

  void _loadNextPage() async {
    final nextPage = await widget.backendClient.getPageOfDrawings(cursor);
    cursor = nextPage.cursor;

    final hydrated = await _hydrateImages(nextPage.drawings);

    setState(() {
      savedImages.addAll(hydrated);
    });
  }

  Future<void> _loadImages() async {
    final page = await widget.backendClient.getPageOfDrawings(null);
    final decodedImages =
        await _hydrateImages(page.drawings);
    cursor = page.cursor;

    setState(() {
      savedImages = decodedImages;
    });
  }

  Future<List<ImageData>> _hydrateImages(List<DrawingData> drawings) async {
    final futures = drawings.map((drawing) async {
      final codec = await ui
          .instantiateImageCodec(drawing.canvasData.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return ImageData(
          title: drawing.title, author: drawing.author, image: frame.image);
    });

    final decodedImages = await Future.wait(futures);

    return decodedImages;
  }

  void _clear() {
    setState(() {
      commands = [];
    });
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
        controller: _scrollController,
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
                            onPressed: _clear,
                            child: const Text("Clear"),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => SaveDialog(
                                  isSaving: saving,
                                  canvasSize: canvasSize,
                                  onSave: (title, author, imageData) async {
                                    setState(() {
                                      saving = true;
                                    });
                                    await widget.backendClient
                                        .putDrawing(DrawingData(
                                      title: title,
                                      author: author,
                                      time:
                                          DateTime.now().millisecondsSinceEpoch,
                                      canvasData: imageData,
                                    ));

                                    await _loadImages();

                                    setState(() {
                                      saving = false;
                                    });

                                    _clear();

                                    Navigator.of(context).pop();
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
                    childAspectRatio: .8,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    physics: const NeverScrollableScrollPhysics(),
                    children: savedImages.map((drawing) {
                      return Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 2.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth,
                                  child: DrawingViewer(
                                    image: drawing.image,
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                drawing.title,
                                style: (theme.textTheme.titleLarge ??
                                        const TextStyle())
                                    .copyWith(
                                        fontWeight: FontWeight.bold, height: 2),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                drawing.author,
                                style: theme.textTheme.titleMedium ??
                                    const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
