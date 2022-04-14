import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wave_slider/core/wave_controller.dart';

import '../core/wave_curve_values.dart';

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;
  final Color color;

  double _previousSliderPosition = 0;

  final Paint fillPainter;
  final Paint wavePainter;

  final double animationProgress;
  final SliderState sliderState;

  WavePainter({
    required this.sliderPosition,
    required this.dragPercentage,
    required this.color,
    required this.animationProgress,
    required this.sliderState,
  })  : fillPainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

  WaveCurveValues _calculateWaveCurveValues({required Size size}) {
    double minWaveHeight = size.height * 0.2;
    double maxWaveHeight = size.height * 0.8;

    double controlHeight =
        (size.height - minWaveHeight) - (maxWaveHeight * dragPercentage);

    double bendWidth = 20 + 20 * dragPercentage;
    // initial bending from horizontal line
    double bezierWidth = 20 + 20 * dragPercentage;

    double centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;

    double startOfBend = sliderPosition - bendWidth / 2;
    double startOfBezier = startOfBend - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezier = endOfBend + bezierWidth;

    startOfBend = (startOfBend <= 0.0) ? 0.0 : startOfBend;
    startOfBezier = (startOfBezier <= 0.0) ? 0.0 : startOfBezier;
    endOfBend = (endOfBend >= size.width) ? size.width : endOfBend;
    endOfBezier = (endOfBezier > size.width) ? size.width : endOfBezier;

    // left half control point of bezier
    double leftControlPoint1 = startOfBend;
    double leftControlPoint2 = startOfBend;
    // right half control point of bezier
    double rightControlPoint1 = endOfBend;
    double rightControlPoint2 = endOfBend;

    // the bend-ability of the curve when it is moving
    double bendAbility = 25.0;
    // the max distance between the current slider position and previous slider position will be 20 ( so that the bend doesn't go out of shape )
    double maxSlideDifference = 30.0;

    double slideDifference = (sliderPosition - _previousSliderPosition).abs();
    slideDifference = (slideDifference > maxSlideDifference)
        ? maxSlideDifference
        : slideDifference;

    bool moveLeft = sliderPosition < _previousSliderPosition;

    double bend =
        lerpDouble(0.0, bendAbility, slideDifference / maxSlideDifference)!;
    bend = moveLeft ? -bend : bend;

    leftControlPoint1 += bend;
    leftControlPoint2 -= bend;
    rightControlPoint1 -= bend;
    rightControlPoint2 += bend;
    centerPoint -= bend;

    return WaveCurveValues(
      startOfBezier: startOfBezier,
      endOfBezier: endOfBezier,
      leftControlPoint1: leftControlPoint1,
      leftControlPoint2: leftControlPoint2,
      rightControlPoint1: rightControlPoint1,
      rightControlPoint2: rightControlPoint2,
      controlHeight: controlHeight,
      centerPoint: centerPoint,
    );
  }

  void _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(0.0, size.height),
      5.0,
      fillPainter,
    );
    canvas.drawCircle(
      Offset(size.width, size.height),
      5.0,
      fillPainter,
    );
  }

  /// test line same as below function
  // void _paintLine(Canvas canvas, Size size) {
  //   Path path = Path();
  //   path.moveTo(0.0, size.height);
  //   path.lineTo(size.width, size.height);
  //   canvas.drawPath(path, wavePainter);
  // }

  /// just to test if slider position works
  // void _paintBlock(Canvas canvas, Size size) {
  // rectangle position & size of rectangle
  //   Rect sliderRect =
  //       Offset(sliderPosition, size.height - 5.0) & const Size(3.0, 10.0);
  //   canvas.drawRect(sliderRect, fillPainter);
  // }

  void _paintWaveLine(
      Canvas canvas, Size size, WaveCurveValues waveCurveValues) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(waveCurveValues.startOfBezier, size.height);
    path.cubicTo(
      waveCurveValues.leftControlPoint1,
      size.height,
      waveCurveValues.leftControlPoint2,
      waveCurveValues.controlHeight,
      waveCurveValues.centerPoint,
      waveCurveValues.controlHeight,
    );
    path.cubicTo(
      waveCurveValues.rightControlPoint1,
      waveCurveValues.controlHeight,
      waveCurveValues.rightControlPoint2,
      size.height,
      waveCurveValues.endOfBezier,
      size.height,
    );
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  void _paintStartupWave(Canvas canvas, Size size) {
    WaveCurveValues waveCurveValues = _calculateWaveCurveValues(size: size);
    double waveHeight = lerpDouble(
      size.height,
      waveCurveValues.controlHeight,
      Curves.elasticOut.transform(animationProgress),
    )!;
    waveCurveValues.controlHeight = waveHeight;
    _paintWaveLine(canvas, size, waveCurveValues);
  }

  void _paintRestingWave(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  void _paintSlidingWave(Canvas canvas, Size size) {
    WaveCurveValues waveCurveValues = _calculateWaveCurveValues(size: size);
    _paintWaveLine(canvas, size, waveCurveValues);
  }

  void _paintStoppingWave(Canvas canvas, Size size) {
    WaveCurveValues waveCurveValues = _calculateWaveCurveValues(size: size);
    double waveHeight = lerpDouble(
      waveCurveValues.controlHeight,
      size.height,
      Curves.elasticOut.transform(animationProgress),
    )!;
    waveCurveValues.controlHeight = waveHeight;
    _paintWaveLine(canvas, size, waveCurveValues);
  }

  @override
  void paint(Canvas canvas, Size size) {
    //the circles at either end of the line
    _paintAnchors(canvas, size);

    switch (sliderState) {
      case SliderState.starting:
        _paintStartupWave(canvas, size);
        break;
      case SliderState.resting:
        _paintRestingWave(canvas, size);
        break;
      case SliderState.sliding:
        _paintSlidingWave(canvas, size);
        break;
      case SliderState.stopping:
        _paintStoppingWave(canvas, size);
        break;
      default:
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    _previousSliderPosition = oldDelegate.sliderPosition;
    return true;
  }
}
