import 'package:flutter/material.dart';

class CurveDecimation {
 
  static _getSquareSegmentDistance(Offset p, Offset p1, Offset p2) {
    var x = p1.dx;
    var y = p1.dy;
    var dx = p2.dx - x;
    var dy = p2.dy - y;
    if (dx != 0 || dy != 0) {
      final t = ((p.dx - x) * dx + (p.dy - y) * dy) / (dx * dx + dy * dy);
      if (t > 1) {
        x = p2.dx;
        y = p2.dy;
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
      }
    }
    dx = p.dx - x;
    dy = p.dy - y;
    return dx * dx + dy * dy;
  }

  static List<Offset> simplifyDouglasPeucker(
      List<Offset> points, {required double sqTolerance } ) {
    final len = points.length;
    var markers = List<bool>.filled(len, false, growable: true);
    var first = 0;
    var last = len - 1;
    var firstStack = List<int>.empty(growable: true);
    var lastStack = List<int>.empty(growable: true);
    var newPoints = List<Offset>.empty(growable: true);

    markers[first] = markers[last] = true;
    var index = 0;

    while (true) {
      double maxSqDist = 0;
      for (var i = first + 1; i < last; i++) {
        var sqDist = _getSquareSegmentDistance(points[i], points[first], points[last]);

        if (sqDist > maxSqDist) {
          index = i;
          maxSqDist = sqDist;
        }
      }

      if (maxSqDist > sqTolerance) {
        markers[index] = true;

        firstStack.add(first);
        lastStack.add(index);
        firstStack.add(index);
        lastStack.add(last);
      }

      if (firstStack.isEmpty || lastStack.isEmpty) {
        break;
      }

      first = firstStack.removeLast();
      last = lastStack.removeLast();
    }

    for (var i = 0; i < len; i++) {
      if (markers[i]) {
        newPoints.add(points[i]);
      }
    }

    return newPoints;
  }
}