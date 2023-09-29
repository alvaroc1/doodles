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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: ClipRect(
        child: CustomPaint(
          painter: DrawingViewerPainter(image: image),
        ),
      ),
    );
  }
}

class DrawingViewerPainter extends CustomPainter {
  final ui.Image image;

  DrawingViewerPainter({super.repaint, required this.image});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / image.width, size.height / image.height);
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
