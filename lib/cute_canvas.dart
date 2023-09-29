import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

abstract class DrawCommand {}

class Stroke extends DrawCommand {
  final Color color;
  final List<Offset> points;

  Stroke(this.color, this.points);
}

class CuteCanvas extends StatefulWidget {
  final double size;
  final Color color;
  final List<DrawCommand> commands;
  final void Function(DrawCommand) onCommand;

  const CuteCanvas({
    super.key,
    required this.color,
    required this.commands,
    required this.onCommand,
    required this.size,
  });

  @override
  State<CuteCanvas> createState() => _CuteCanvasState();
}

class _CuteCanvasState extends State<CuteCanvas> {
  bool isPenDown = false;

  List<Offset> currentCommandPoints = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          isPenDown = true;
        });
      },
      onPanEnd: (details) {
        setState(() {
          isPenDown = false;
          widget.onCommand(Stroke(widget.color, currentCommandPoints));
          currentCommandPoints = [];
        });
      },
      onPanUpdate: (details) {
        setState(() {
          if (isPenDown) {
            currentCommandPoints.add(details.localPosition);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.white,
        ),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                CustomPaint(
                  foregroundPainter: MyCustomPainter(
                    commands: widget.commands,
                  ),
                ),
                CustomPaint(
                  painter: StrokePainter(
                    points: currentCommandPoints,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  StrokePainter({super.repaint, required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _drawStroke(color, canvas, points);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyCustomPainter extends CustomPainter {
  final List<DrawCommand> commands;

  MyCustomPainter({
    super.repaint,
    required this.commands,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawCommands(canvas, commands);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void drawCommands(Canvas canvas, List<DrawCommand> commands) {
  for (var command in commands) {
    if (command is Stroke) {
      _drawStroke(command.color, canvas, command.points);
    }
  }
}

void _drawStroke(Color color, Canvas canvas, List<Offset> points) {
  Paint paint = Paint()..color = color;

  // 1. Get the outline points from the input points
  final outlinePoints =
      getStroke(points.map((offset) => Point(offset.dx, offset.dy)).toList());

  // 2. Render the points as a path
  final path = Path();

  if (outlinePoints.isEmpty) {
    // If the list is empty, don't do anything.
    return;
  } else if (outlinePoints.length < 2) {
    // If the list only has one point, draw a dot.
    path.addOval(Rect.fromCircle(
        center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
  } else {
    // Otherwise, draw a line that connects each point with a bezier curve segment.
    path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

    for (int i = 1; i < outlinePoints.length - 1; ++i) {
      final p0 = outlinePoints[i];
      final p1 = outlinePoints[i + 1];
      path.quadraticBezierTo(p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
    }
  }

  // 3. Draw the path to the canvas
  canvas.drawPath(path, paint);
}
