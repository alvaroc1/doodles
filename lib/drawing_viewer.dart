import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DrawingViewer extends StatelessWidget {
  final ui.Image image;

  const DrawingViewer({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: DrawingViewerPainter(image: image),
      ),
    );
  }
}

class DrawingViewerPainter extends CustomPainter {
  final ui.Image image;

  DrawingViewerPainter({super.repaint, required this.image});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
