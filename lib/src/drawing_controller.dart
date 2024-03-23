import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'helper/safe_value_notifier.dart';
import 'paint_contents/paint_content.dart';
import 'paint_contents/simple_line.dart';

/// Drawing parameters
class DrawConfig {
  DrawConfig({
    required this.contentType,
    this.angle = 0,
    this.fingerCount = 0,
    this.size,
    this.blendMode = BlendMode.srcOver,
    this.color = Colors.red,
    this.colorFilter,
    this.filterQuality = FilterQuality.high,
    this.imageFilter,
    this.invertColors = false,
    this.isAntiAlias = false,
    this.maskFilter,
    this.shader,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeWidth = 4,
    this.style = PaintingStyle.stroke,
  });

  DrawConfig.def({
    required this.contentType,
    this.angle = 0,
    this.fingerCount = 0,
    this.size,
    this.blendMode = BlendMode.srcOver,
    this.color = Colors.black,
    this.colorFilter,
    this.filterQuality = FilterQuality.high,
    this.imageFilter,
    this.invertColors = false,
    this.isAntiAlias = false,
    this.maskFilter,
    this.shader,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeWidth = 4,
    this.style = PaintingStyle.stroke,
  });

  /// angle of rotation（0:0,1:90,2:180,3:270）
  final int angle;

  final Type contentType;

  final int fingerCount;

  final Size? size;

  /// Paint related
  final BlendMode blendMode;
  final Color color;
  final ColorFilter? colorFilter;
  final FilterQuality filterQuality;
  final ui.ImageFilter? imageFilter;
  final bool invertColors;
  final bool isAntiAlias;
  final MaskFilter? maskFilter;
  final Shader? shader;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double strokeWidth;
  final PaintingStyle style;

  /// generated paint
  Paint get paint => Paint()
    ..blendMode = blendMode
    ..color = color
    ..colorFilter = colorFilter
    ..filterQuality = filterQuality
    ..imageFilter = imageFilter
    ..invertColors = invertColors
    ..isAntiAlias = isAntiAlias
    ..maskFilter = maskFilter
    ..shader = shader
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin
    ..strokeWidth = strokeWidth
    ..style = style;

  DrawConfig copyWith({
    Type? contentType,
    BlendMode? blendMode,
    Color? color,
    ColorFilter? colorFilter,
    FilterQuality? filterQuality,
    ui.ImageFilter? imageFilter,
    bool? invertColors,
    bool? isAntiAlias,
    MaskFilter? maskFilter,
    Shader? shader,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeWidth,
    PaintingStyle? style,
    int? angle,
    int? fingerCount,
    Size? size,
  }) {
    return DrawConfig(
      contentType: contentType ?? this.contentType,
      angle: angle ?? this.angle,
      blendMode: blendMode ?? this.blendMode,
      color: color ?? this.color,
      colorFilter: colorFilter ?? this.colorFilter,
      filterQuality: filterQuality ?? this.filterQuality,
      imageFilter: imageFilter ?? this.imageFilter,
      invertColors: invertColors ?? this.invertColors,
      isAntiAlias: isAntiAlias ?? this.isAntiAlias,
      maskFilter: maskFilter ?? this.maskFilter,
      shader: shader ?? this.shader,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      style: style ?? this.style,
      fingerCount: fingerCount ?? this.fingerCount,
      size: size ?? this.size,
    );
  }
}

/// drawing controller
class DrawingController extends ChangeNotifier {
  DrawingController({DrawConfig? config, PaintContent? content}) {
    _history = <PaintContent>[];
    _currentIndex = 0;
    realPainter = RePaintNotifier();
    painter = RePaintNotifier();
    drawConfig = SafeValueNotifier<DrawConfig>(
        config ?? DrawConfig.def(contentType: SimpleLine));
    setPaintContent(content ?? SimpleLine());
  }

  /// drawing start point
  Offset? _startPoint;

  /// Drawing board data key
  late GlobalKey painterKey = GlobalKey();

  /// controller
  late SafeValueNotifier<DrawConfig> drawConfig;

  /// The last time it was drawn.
  late PaintContent _paintContent;

  /// Current Drawing Content
  PaintContent? currentContent;

  /// Underlying Drawing Content (Drawing Records)
  late List<PaintContent> _history;

  /// Does the current controller exist?
  bool _mounted = true;

  /// Get Drawing Layers/History
  List<PaintContent> get getHistory => _history;

  /// step pointer
  late int _currentIndex;

  /// Surface Canvas Refresh Control
  RePaintNotifier? painter;

  /// Base Canvas Refresh Control
  RePaintNotifier? realPainter;

  /// Get the index of the current step
  int get currentIndex => _currentIndex;

  /// Get the current color
  Color get getColor => drawConfig.value.color;

  /// Is it possible to draw?
  bool get couldDraw => drawConfig.value.fingerCount <= 1;

  /// Start drawing points
  Offset? get startPoint => _startPoint;

  /// Set the size of the drawing board
  void setBoardSize(Size? size) {
    drawConfig.value = drawConfig.value.copyWith(size: size);
  }

  /// finger drop
  void addFingerCount(Offset offset) {
    drawConfig.value = drawConfig.value
        .copyWith(fingerCount: drawConfig.value.fingerCount + 1);
  }

  /// Fingers up.
  void reduceFingerCount(Offset offset) {
    if (drawConfig.value.fingerCount <= 0) {
      return;
    }

    drawConfig.value = drawConfig.value
        .copyWith(fingerCount: drawConfig.value.fingerCount - 1);
  }

  /// Set drawing style
  void setStyle({
    BlendMode? blendMode,
    Color? color,
    ColorFilter? colorFilter,
    FilterQuality? filterQuality,
    ui.ImageFilter? imageFilter,
    bool? invertColors,
    bool? isAntiAlias,
    MaskFilter? maskFilter,
    Shader? shader,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    double? strokeWidth,
    PaintingStyle? style,
  }) {
    drawConfig.value = drawConfig.value.copyWith(
      blendMode: blendMode,
      color: color,
      colorFilter: colorFilter,
      filterQuality: filterQuality,
      imageFilter: imageFilter,
      invertColors: invertColors,
      isAntiAlias: isAntiAlias,
      maskFilter: maskFilter,
      shader: shader,
      strokeCap: strokeCap,
      strokeJoin: strokeJoin,
      strokeWidth: strokeWidth,
      style: style,
    );
  }

  /// Set drawing content
  void setPaintContent(PaintContent content) {
    content.paint = drawConfig.value.paint;
    _paintContent = content;
    drawConfig.value =
        drawConfig.value.copyWith(contentType: content.runtimeType);
  }

  /// add a data
  void addContent(PaintContent content) {
    _history.add(content);
    _currentIndex++;
    _refreshDeep();
  }

  /// Add multiple pieces of data
  void addContents(List<PaintContent> contents) {
    _history.addAll(contents);
    _currentIndex += contents.length;
    _refreshDeep();
  }

  /// * rotating canvas
  /// * set angle
  void turn() {
    drawConfig.value =
        drawConfig.value.copyWith(angle: (drawConfig.value.angle + 1) % 4);
  }

  /// Start drawing
  void startDraw(Offset startPoint) {
    _startPoint = startPoint;
    currentContent = _paintContent.copy();
    currentContent?.paint = drawConfig.value.paint;
    currentContent?.startDraw(startPoint);
  }

  /// Undrawn
  void cancelDraw() {
    _startPoint = null;
    currentContent = null;
  }

  /// Drawing in progress
  void drawing(Offset nowPaint) {
    currentContent?.drawing(nowPaint);
    _refresh();
  }

  /// End of drawing
  void endDraw() {
    _startPoint = null;
    final int hisLen = _history.length;

    if (hisLen > _currentIndex) {
      _history.removeRange(_currentIndex, hisLen);
    }

    if (currentContent != null) {
      _history.add(currentContent!);
      _currentIndex = _history.length;
      currentContent = null;
    }

    _refresh();
    _refreshDeep();
    notifyListeners();
  }

  /// undo function
  void undo() {
    if (_currentIndex > 0) {
      _currentIndex = _currentIndex - 1;
      _refreshDeep();
    }
  }

  /// Check if undo is available.
  /// Returns true if possible.
  bool canUndo() {
    if (_currentIndex > 0) {
      return true;
    } else {
      return false;
    }
  }

  /// Redo function
  void redo() {
    if (_currentIndex < _history.length) {
      _currentIndex = _currentIndex + 1;
      _refreshDeep();
    }
  }

  /// Check if redo is available.
  /// Returns true if possible.
  bool canRedo() {
    if (_currentIndex < _history.length) {
      return true;
    } else {
      return false;
    }
  }

  /// Clear the drawing board
  void clear() {
    _history.clear();
    _currentIndex = 0;
    _refreshDeep();
  }

  /// Get image data
  Future<ByteData?> getImageData() async {
    try {
      final RenderRepaintBoundary boundary = painterKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(
          pixelRatio: View.of(painterKey.currentContext!).devicePixelRatio);
      return await image.toByteData(format: ui.ImageByteFormat.png);
    } catch (e) {
      debugPrint('获取图片数据出错:$e');
      return null;
    }
  }

  /// Get drawing board content as JSON
  List<Map<String, dynamic>> getJsonList() {
    return _history.map((PaintContent e) => e.toJson()).toList();
  }

  /// Refresh the surface canvas
  void _refresh() {
    painter?._refresh();
  }

  /// Refresh the base canvas
  void _refreshDeep() {
    realPainter?._refresh();
  }

  /// Destroy the controller
  @override
  void dispose() {
    if (!_mounted) {
      return;
    }

    drawConfig.dispose();
    realPainter?.dispose();
    painter?.dispose();

    _mounted = false;

    super.dispose();
  }
}

/// Canvas refresh controller
class RePaintNotifier extends ChangeNotifier {
  void _refresh() {
    notifyListeners();
  }
}
