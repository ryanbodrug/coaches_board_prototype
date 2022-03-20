import 'package:coaches_board/curve_decimation.dart';
import 'package:flutter/material.dart';
import 'splines.dart' as splines;

class DrawnPath {
  ImageInfo pathImage;

  Color color;
  double strokeWidth;
  List<Offset> pathPoints = List.empty(growable: true);
  List<Offset> smoothedPathPoints = List.empty(growable: true);
  splines.CatmullRomSpline? spline;

  DrawnPath(this.color, this.strokeWidth, this.pathImage);

  _renderImage(Canvas canvas, Offset point, rotation, ImageInfo pathImage) {
    canvas.save();
    var dx = point.dx;
    var dy = point.dy;
    canvas.translate(dx, dy);
    canvas.rotate(-rotation);
    canvas.translate(-dx, -dy);
    canvas.translate(
        -pathImage.image.width / 2.0, -pathImage.image.height / 2.0);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(
          point.dx,
          point.dy,
          pathImage.image.width / pathImage.scale,
          pathImage.image.height / pathImage.scale),
      image: pathImage.image, // <- the loaded image
      filterQuality: FilterQuality.low,
    );
    canvas.restore();
  }

  paint(Canvas canvas, Size size) {
    Paint _paint = Paint()..style = PaintingStyle.stroke;
    _paint.color = color;
    _paint.strokeWidth = strokeWidth;

    //Draw Raw Path
    if (pathPoints.isNotEmpty) {
      Path _path = Path();
      _path.moveTo(pathPoints.first.dx, pathPoints.first.dy);
      for (int i = 1; i < pathPoints.length; i++) {
        _path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
      }

      Paint pointPaint = Paint()..style = PaintingStyle.fill;
      pointPaint.color = Colors.green;
      pointPaint.strokeWidth = 1;
      for (int i = 1; i < pathPoints.length; i++) {
        canvas.drawCircle(pathPoints[i], 5.0, pointPaint);
      }

      canvas.drawPath(_path, _paint);
    }

    // Draw Splines

    if (spline != null) {
      //Render Control Points
      Paint pointPaint = Paint()..style = PaintingStyle.fill;
      pointPaint.color = Colors.red;
      pointPaint.strokeWidth = 1;
      for (int i = 0; i < smoothedPathPoints.length; i++) {
        canvas.drawCircle(smoothedPathPoints[i], 5.0, pointPaint);
      }

      //Render Spline Path
      var splinePath = Path();
      var start = spline!.transform(0.0);
      splinePath.moveTo(start.dx, start.dy);

      double dt = 0.001;
      var totalDistance = 0.0;

      var interpolatedPoints = List<Offset>.empty(growable: true);
      for (double t = dt; t < 1.0; t += dt) {
        var point = spline!.transform(t);
        splinePath.lineTo(point.dx, point.dy);
        interpolatedPoints.add(point);
      }

      var end = spline!.transform(1.0);
      splinePath.lineTo(end.dx, end.dy);
      interpolatedPoints.add(end);

      // for(var ip in interpolatedPoints)
      // {
      //   Paint interpolatedPaint = Paint()..style = PaintingStyle.fill;
      //   interpolatedPaint.color = Colors.black;
      //   interpolatedPaint.strokeWidth = 1;
      //   canvas.drawCircle(ip, 1.0, interpolatedPaint);
      // }

      //Draw First Icon
      var halfWidth = pathImage.image.width / 2.0;
      var pathMetrics = splinePath.computeMetrics().toList();
      var tangent = pathMetrics.last.getTangentForOffset(halfWidth);
      if (tangent != null) {
        var rotation = tangent.angle;
        _renderImage(canvas, start, rotation, pathImage);
      }

      var lastRenderPoint = start;

      for (var i = 1; i < interpolatedPoints.length; ++i) {
        final point = interpolatedPoints[i];
        final prevPoint = interpolatedPoints[i - 1];
        final delta = point - lastRenderPoint;
        totalDistance += (point - prevPoint).distance;
        if (delta.distance >= pathImage.image.width) {
          lastRenderPoint = point;
          var tangent = pathMetrics.last.getTangentForOffset(totalDistance);
          assert(tangent != null);
          if (tangent != null) {
            var rotation = tangent.angle;
            _renderImage(canvas, point, rotation, pathImage);
          }
        }
      }

      Paint splinePaint = Paint()..style = PaintingStyle.stroke;
      splinePaint.color = Colors.blue;
      splinePaint.strokeWidth = 1;
      // canvas.drawPath(splinePath, splinePaint);
    } else if (smoothedPathPoints.isNotEmpty) {
      Path splinePath = Path();
      splinePath.moveTo(
          smoothedPathPoints.first.dx, smoothedPathPoints.first.dy);

      for (int i = 1; i < smoothedPathPoints.length; i++) {
        splinePath.lineTo(smoothedPathPoints[i].dx, smoothedPathPoints[i].dy);
      }

      Paint pointPaint = Paint()..style = PaintingStyle.fill;
      pointPaint.color = Colors.red;
      pointPaint.strokeWidth = 1;
      for (int i = 0; i < smoothedPathPoints.length; i++) {
        canvas.drawCircle(smoothedPathPoints[i], 5.0, pointPaint);
      }
      Paint splinePaint = Paint()..style = PaintingStyle.stroke;
      splinePaint.color = Colors.purple;
      splinePaint.strokeWidth = 1;
      canvas.drawPath(splinePath, splinePaint);
    }
  }

  addPoint(Offset point) {
    pathPoints.add(point);
  }

  finalize(bool smooth) {
    if (pathPoints.isNotEmpty) {
      var tolerance = smooth ? 50.0 : 1.0;
      smoothedPathPoints = CurveDecimation.simplifyDouglasPeucker(pathPoints,
          sqTolerance: tolerance);

      if (smooth) {
        //Catmul rom needs 4 control points
        if (smoothedPathPoints.length > 3) {
          spline = splines.CatmullRomSpline.precompute(smoothedPathPoints);
        }
      }

      pathPoints.clear();
    }
  }

  clear() {
    pathPoints.clear();
    smoothedPathPoints.clear();
  }
}
