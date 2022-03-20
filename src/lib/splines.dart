///This is currently taken from the Flutter CatmullRomSplines package.
///However this will eventually be used for animtaion at a consistent velocity and will be extended to
///Reparamatarize the curve for animation purposes, in which the control points are positioned at equal distances
///across the spline.  This will give the ability to interpolate at a consistent velocity across the spline.
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CatmullRomSpline {
  CatmullRomSpline(
    List<Offset> controlPoints, {
    double tension = 0.0,
    Offset? startHandle,
    Offset? endHandle,
  })  : assert(
            tension <= 1.0, 'tension $tension must not be greater than 1.0.'),
        assert(tension >= 0.0, 'tension $tension must not be negative.'),
        assert(controlPoints.length > 3,
            'There must be at least four control points to create a CatmullRomSpline.'),
        _controlPoints = controlPoints,
        _startHandle = startHandle,
        _endHandle = endHandle,
        _tension = tension,
        _cubicSegments = <List<Offset>>[];

  /// Constructs a centripetal Catmull-Rom spline curve.
  ///
  /// The same as [CatmullRomSpline], except that the internal data
  /// structures are precomputed instead of being computed lazily.
  CatmullRomSpline.precompute(
    List<Offset> controlPoints, {
    double tension = 0.0,
    Offset? startHandle,
    Offset? endHandle,
  })  : assert(
            tension <= 1.0, 'tension $tension must not be greater than 1.0.'),
        assert(tension >= 0.0, 'tension $tension must not be negative.'),
        assert(controlPoints.length > 3,
            'There must be at least four control points to create a CatmullRomSpline.'),
        _controlPoints = null,
        _startHandle = null,
        _endHandle = null,
        _tension = null,
        _cubicSegments = _computeSegments(controlPoints, tension,
            startHandle: startHandle, endHandle: endHandle);

  static List<List<Offset>> _computeSegments(
    List<Offset> controlPoints,
    double tension, {
    Offset? startHandle,
    Offset? endHandle,
  }) {
    // If not specified, select the first and last control points (which are
    // handles: they are not intersected by the resulting curve) so that they
    // extend the first and last segments, respectively.
    startHandle ??= controlPoints[0] * 2.0 - controlPoints[1];
    endHandle ??=
        controlPoints.last * 2.0 - controlPoints[controlPoints.length - 2];
    final List<Offset> allPoints = <Offset>[
      startHandle,
      ...controlPoints,
      endHandle,
    ];

    // An alpha of 0.5 is what makes it a centripetal Catmull-Rom spline. A
    // value of 0.0 would make it a uniform Catmull-Rom spline, and a value of
    // 1.0 would make it a chordal Catmull-Rom spline. Non-centripetal values
    // for alpha can give self-intersecting behavior or looping within a
    // segment.
    const double alpha = 0.5;
    final double reverseTension = 1.0 - tension;
    final List<List<Offset>> result = <List<Offset>>[];
    for (int i = 0; i < allPoints.length - 3; ++i) {
      final List<Offset> curve = <Offset>[
        allPoints[i],
        allPoints[i + 1],
        allPoints[i + 2],
        allPoints[i + 3]
      ];
      final Offset diffCurve10 = curve[1] - curve[0];
      final Offset diffCurve21 = curve[2] - curve[1];
      final Offset diffCurve32 = curve[3] - curve[2];
      final double t01 = math.pow(diffCurve10.distance, alpha).toDouble();
      final double t12 = math.pow(diffCurve21.distance, alpha).toDouble();
      final double t23 = math.pow(diffCurve32.distance, alpha).toDouble();

      final Offset m1 = (diffCurve21 +
              (diffCurve10 / t01 - (curve[2] - curve[0]) / (t01 + t12)) * t12) *
          reverseTension;
      final Offset m2 = (diffCurve21 +
              (diffCurve32 / t23 - (curve[3] - curve[1]) / (t12 + t23)) * t12) *
          reverseTension;
      final Offset sumM12 = m1 + m2;

      final List<Offset> segment = <Offset>[
        diffCurve21 * -2.0 + sumM12,
        diffCurve21 * 3.0 - m1 - sumM12,
        m1,
        curve[1],
      ];
      result.add(segment);
    }
    return result;
  }

  // The list of control point lists for each cubic segment of the spline.
  final List<List<Offset>> _cubicSegments;

  // This is non-empty only if the _cubicSegments are being computed lazily.
  final List<Offset>? _controlPoints;
  final Offset? _startHandle;
  final Offset? _endHandle;
  final double? _tension;

  void _initializeIfNeeded() {
    if (_cubicSegments.isNotEmpty) {
      return;
    }
    _cubicSegments.addAll(
      _computeSegments(_controlPoints!, _tension!,
          startHandle: _startHandle, endHandle: _endHandle),
    );
  }

  @protected
  int get samplingSeed {
    _initializeIfNeeded();
    final Offset seedPoint = _cubicSegments[0][1];
    return ((seedPoint.dx + seedPoint.dy) * 10000).round();
  }

  Offset transform(double t) {
    _initializeIfNeeded();
    final double length = _cubicSegments.length.toDouble();
    final double position;
    final double localT;
    final int index;
    if (t < 1.0) {
      position = t * length;
      localT = position % 1.0;
      index = position.floor();
    } else {
      position = length;
      localT = 1.0;
      index = _cubicSegments.length - 1;
    }
    final List<Offset> cubicControlPoints = _cubicSegments[index];
    final double localT2 = localT * localT;
    return cubicControlPoints[0] * localT2 * localT +
        cubicControlPoints[1] * localT2 +
        cubicControlPoints[2] * localT +
        cubicControlPoints[3];
  }
}
