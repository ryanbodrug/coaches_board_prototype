import 'package:flutter/material.dart';

class PolylineSmoother {
  static Offset _interpolate(double percent, Offset p1, Offset p2) {
    final x = percent * (p2.dx - p1.dx) + p1.dx;
    final y = percent * (p2.dy - p1.dy) + p1.dy;

    return Offset(x, y);
  }

  static List<Offset> chaikinsAlgorithm(List<Offset> points,
      {int iterations = 1}) {
    List<Offset> smoothedLine = List<Offset>.from(points);
    for (int itr = 0; itr < iterations; ++itr) {
      List<Offset> inputLine = List<Offset>.from(smoothedLine);
      smoothedLine.clear();
      for (int i = 0; i < inputLine.length - 1; ++i) {
        final p1 = inputLine[i];
        final p2 = inputLine[i + 1];

        final q = _interpolate(0.25, p1, p2);
        final r = _interpolate(0.75, p1, p2);

        smoothedLine.add(q);
        smoothedLine.add(r);
      }
    }
    return smoothedLine;
  }
}
