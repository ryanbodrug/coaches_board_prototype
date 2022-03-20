import 'package:flutter/material.dart';
import 'drawn_path.dart';

class BoardPainter extends CustomPainter {
  List<DrawnPath> paths; 

  BoardPainter({required this.paths});
 
  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isNotEmpty) {
      for (DrawnPath currentPath in paths) {
          currentPath.paint(canvas, size);
      }
    }
  }

  // 4
  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return true;
  }
}