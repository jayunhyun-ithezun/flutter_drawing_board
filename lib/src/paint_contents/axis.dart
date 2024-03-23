import 'package:flutter/painting.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// Graph
class Graph extends PaintContent {
  Graph();

  Graph.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory Graph.fromJson(Map<String, dynamic> data) {
    return Graph.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  /// Start point
  Offset? startPoint;

  /// End point
  Offset? endPoint;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Draw X axis
    canvas.drawLine(startPoint!, Offset(endPoint!.dx, startPoint!.dy), paint);

    // Draw Y axis
    canvas.drawLine(startPoint!, Offset(startPoint!.dx, endPoint!.dy), paint);
  }

  @override
  Graph copy() => Graph();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint?.toJson(),
      'endPoint': endPoint?.toJson(),
      'paint': paint.toJson(),
    };
  }
}
