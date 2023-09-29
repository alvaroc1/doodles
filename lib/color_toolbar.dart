import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ColorToolbar extends StatelessWidget {
  final List<Color> colors;
  final int selectedColor;
  final void Function(int) onColorSelected;

  const ColorToolbar({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Wrap(
        direction: Axis.vertical,
        spacing: 4,
        runSpacing: 4,
        children: colors
            .mapIndexed(
              (index, color) => Container(
                decoration: BoxDecoration(
                  color: index == selectedColor
                      ? Colors.blueAccent
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: RawMaterialButton(
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  fillColor: color,
                  shape: const CircleBorder(),
                  // onPressed: () {
                  //   setState(() {
                  //     selectedColor = index;
                  //   });
                  // },
                  onPressed: () => onColorSelected(index),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
