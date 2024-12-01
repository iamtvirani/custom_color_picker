import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

typedef ColorCodeBuilder = Widget Function(BuildContext context, Color color);

class CircleColorPickerController extends ChangeNotifier {
  CircleColorPickerController({
    Color initialColor = const Color.fromARGB(255, 255, 0, 0),
  }) : _color = initialColor;

  Color _color;

  Color get color => _color;

  set color(Color color) {
    _color = color;
    notifyListeners();
  }
}

class CircleColorPicker extends StatefulWidget {
  CircleColorPicker({
    Key? key,
    this.onChanged,
    this.onEnded,
    this.size = const Size(280, 280),
    this.strokeWidth = 13,
    this.thumbSize = 32,
    this.controller,
    this.colorCodeBuilder,
  }) : super(key: key);
  final ValueChanged<Color>? onChanged;
  final ValueChanged<Color>? onEnded;
  final CircleColorPickerController? controller;
  final Size size;
  final double strokeWidth;
  final double thumbSize;
  final ColorCodeBuilder? colorCodeBuilder;

  Color get initialColor => controller?.color ?? const Color.fromARGB(255, 255, 0, 0);

  double get initialLightness => HSLColor.fromColor(initialColor).lightness;

  double get initialHue => HSLColor.fromColor(initialColor).hue;

  @override
  _CircleColorPickerState createState() => _CircleColorPickerState();
}

class _CircleColorPickerState extends State<CircleColorPicker> with TickerProviderStateMixin {
  late AnimationController _lightnessController;
  late AnimationController _hueController;

  Color get _color {
    return HSLColor.fromAHSL(
      1,
      _hueController.value,
      1,
      _lightnessController.value,
    ).toColor();
  }

  @override
  void initState() {
    super.initState();
    _hueController = AnimationController(
      vsync: this,
      value: widget.initialHue,
      lowerBound: 0,
      upperBound: 360,
    )..addListener(_onColorChanged);
    _lightnessController = AnimationController(
      vsync: this,
      value: widget.initialLightness,
      lowerBound: 0,
      upperBound: 0.97,
    )..addListener(_onColorChanged);
    widget.controller?.addListener(_setColor);
  }

  @override
  void dispose() {
    _hueController.dispose();
    _lightnessController.dispose();
    widget.controller?.removeListener(_setColor);
    super.dispose();
  }

  void _onColorChanged() {
    // widget.onChanged?.call(_color);
    widget.controller?.color = _color;
  }

  void _onEnded() {
    widget.onEnded?.call(_color);
  }

  void _setColor() {
    if (widget.controller != null && widget.controller!.color != _color) {
      final hslColor = HSLColor.fromColor(widget.controller!.color);
      _hueController.value = hslColor.hue;
      _lightnessController.value = hslColor.lightness;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _HuePicker(
                  hue: _hueController.value,
                  size: widget.size,
                  strokeWidth: widget.strokeWidth,
                  onColorChange: widget.onChanged,
                  thumbSize: widget.thumbSize,
                  onChanged: (hue) {
                    setState(() {
                      _hueController.value = hue;
                      _onColorChanged();
                    });
                  },
                  onEnded: _onEnded,
                ),
                AnimatedBuilder(
                  animation: _hueController,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: _lightnessController,
                      builder: (context, _) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              LightnessSlider(
                                hue: _hueController.value,
                                lightness: _lightnessController.value,
                                onColorChanged: widget.onChanged,
                                onChanged: (lightness) {
                                  setState(() {
                                    _lightnessController.value = lightness;
                                    _onColorChanged();
                                  });
                                },
                                onEnded: _onEnded,
                                height: 157,
                                width: 36,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LightnessSlider extends StatefulWidget {
  final double hue;
  final bool isTemp;
  final double lightness;
  final double? thumbPosition;
  final double height;
  final Color? color;
  final double width;
  final double? thumbSize;
  final ValueChanged<double> onChanged;
  final ValueChanged<Color>? onColorChanged;
  final VoidCallback onEnded;

  const LightnessSlider({
    super.key,
    required this.hue,
    required this.lightness,
    required this.height,
    required this.onChanged,
    required this.onEnded,
    required this.width,
    required this.onColorChanged,
    this.color,
    this.thumbSize,
    this.thumbPosition,
    this.isTemp = false,
  });

  @override
  _LightnessSliderState createState() => _LightnessSliderState();
}

class _LightnessSliderState extends State<LightnessSlider> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  Timer? _cancelTimer;
  Color thumbColor = Colors.white;
  Color circleColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      value: 1,
      lowerBound: 0.9,
      upperBound: 1,
      duration: const Duration(milliseconds: 50),
    );
    generateColors();
  }

  List<Color> colors = [];

  void generateColors() {
    colors = [];
    HSLColor hslColor = HSLColor.fromColor(thumbColor);

    for (int i = 0; i < 8; i++) {
      double newSaturation = (1 - i * 0.125).clamp(0.0, 1.0);
      double newLightness = (0.5 + i * 0.0625).clamp(0.0, 1.0);

      HSLColor newHslColor = hslColor.withSaturation(newSaturation).withLightness(newLightness);
      colors.add(newHslColor.toColor());
      widget.onColorChanged?.call(circleColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    double clampedLightness = widget.lightness.clamp(0.4, 1);
    thumbColor = HSLColor.fromAHSL(1, widget.hue, 0.5, clampedLightness).toColor();
    circleColor = HSLColor.fromAHSL(1, widget.hue, 1, clampedLightness).toColor();
    generateColors();
    return GestureDetector(
      onPanUpdate: _onUpdate,
      // onVerticalDragUpdate: _onUpdate,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            // The slider container
            GestureDetector(
              onPanDown: _onDown,
              onPanCancel: _onCancel,
              // onPanEnd: _onEnd,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                width: 55,
                height: double.infinity,
                child: Column(
                  children: List.generate(8, (index) {
                    BorderRadius? borderRadius;
                    if (index == 0) {
                      borderRadius = const BorderRadius.vertical(top: Radius.circular(100));
                    } else if (index == 7) {
                      borderRadius = const BorderRadius.vertical(bottom: Radius.circular(100));
                    } else {
                      borderRadius = BorderRadius.zero;
                    }
                    return Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: const Offset(0, 0),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      height: 50,
                    ));
                  }),
                ),
              ),
            ),

            Positioned(
              top: widget.lightness * (widget.thumbPosition ?? 120),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                child: ScaleTransition(
                  scale: _scaleController,
                  child: _Thumb(
                    size: widget.thumbSize ?? 28,
                    color: widget.color ?? circleColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDown(DragDownDetails details) {
    _scaleController.reverse();
    widget.onChanged(details.localPosition.dy / widget.height);
    generateColors();
  }

  void _onStart(DragStartDetails details) {
    _cancelTimer?.cancel();
    _cancelTimer = null;
    widget.onChanged(details.localPosition.dy / widget.height);
  }

  void _onUpdate(DragUpdateDetails details) {
    widget.onChanged(details.localPosition.dy / widget.height);
    final double normalizedPosition = (details.localPosition.dy / widget.height).clamp(0.0, 1);
    int colorIndex = (normalizedPosition * (colors.length - 1)).round();
    setState(() {
      circleColor = colors[colorIndex];
      generateColors();
    });
  }

  void _onEnd(DragEndDetails details) {
    _scaleController.forward();
    widget.onEnded();
  }

  void _onCancel() {
    _cancelTimer = Timer(
      const Duration(milliseconds: 5),
      () {
        _scaleController.forward();
        widget.onEnded();
      },
    );
    generateColors();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
}

class _Thumb extends StatelessWidget {
  final double size;
  final Color color;

  const _Thumb({
    Key? key,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 0), // Border styling
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipOval(
        child:  Container(
          width: 50,
          height: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HuePicker extends StatefulWidget {
  const _HuePicker({
    Key? key,
    required this.hue,
    required this.onChanged,
    required this.onEnded,
    required this.size,
    required this.onColorChange,
    required this.strokeWidth,
    required this.thumbSize,
  }) : super(key: key);
  final double hue;
  final ValueChanged<double> onChanged;
  final VoidCallback onEnded;
  final ValueChanged<Color>? onColorChange;
  final Size size;
  final double strokeWidth;
  final double thumbSize;

  @override
  _HuePickerState createState() => _HuePickerState();
}

class _HuePickerState extends State<_HuePicker> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  Timer? _cancelTimer;

  @override
  Widget build(BuildContext context) {
    final minSize = min(widget.size.width, widget.size.height);
    final offset = _CircleTween(
      minSize / 2 - widget.thumbSize / 2,
    ).lerp(widget.hue * pi / 180);
    return GestureDetector(
      onPanDown: _onDown,
      onPanCancel: _onCancel,
      onHorizontalDragStart: _onStart,
      onHorizontalDragUpdate: _onUpdate,
      onHorizontalDragEnd: _onEnd,
      onVerticalDragStart: _onStart,
      onVerticalDragUpdate: _onUpdate,
      onVerticalDragEnd: _onEnd,
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: Padding(
                padding: EdgeInsets.all(
                  widget.thumbSize / 2 - widget.strokeWidth,
                ),
                child: CustomPaint(
                  painter: _CirclePickerPainter(widget.strokeWidth),
                ),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: ScaleTransition(
                scale: _scaleController,
                child: _Thumb(
                  size: widget.thumbSize,
                  color: HSLColor.fromAHSL(1, widget.hue, 1, 0.5).toColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      value: 1,
      lowerBound: 0.9,
      upperBound: 1,
      duration: const Duration(milliseconds: 50),
    );
  }

  void _onDown(DragDownDetails details) {
    _scaleController.reverse();
    _updatePosition(details.localPosition);
  }

  void _onStart(DragStartDetails details) {
    _cancelTimer?.cancel();
    _cancelTimer = null;
    _updatePosition(details.localPosition);
  }

  void _onUpdate(DragUpdateDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onEnd(DragEndDetails details) {
    _scaleController.forward();
    widget.onEnded();
  }

  void _onCancel() {
    _cancelTimer = Timer(
      const Duration(milliseconds: 5),
      () {
        _scaleController.forward();
        widget.onEnded();
      },
    );
  }

  void _updatePosition(Offset position) {
    final radians = atan2(
      position.dy - widget.size.height / 2,
      position.dx - widget.size.width / 2,
    );
    widget.onChanged(radians % (2 * pi) * 180 / pi);
  }
}

class _CircleTween extends Tween<Offset> {
  _CircleTween(this.radius)
      : super(
          begin: _radiansToOffset(0, radius),
          end: _radiansToOffset(2 * pi, radius),
        );

  final double radius;

  @override
  Offset lerp(double t) => _radiansToOffset(t, radius);

  static Offset _radiansToOffset(double radians, double radius) {
    return Offset(
      radius + radius * cos(radians),
      radius + radius * sin(radians),
    );
  }
}

class _CirclePickerPainter extends CustomPainter {
  const _CirclePickerPainter(this.strokeWidth);

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2.2, size.height / 2.2);
    const segments = 40;
    final adjustedStrokeWidth = radius / 2.5;
    const lineAngleGap = 0.003;

    for (int i = 0; i < segments; i++) {
      final startAngle = 2 * pi * i / segments;
      const sweepAngle = 8.06 * pi / segments - 0.479;

      final paint = Paint()
        ..shader = SweepGradient(
          colors: [
            HSVColor.fromAHSV(1.0, i * (360 / segments), 1.0, 1.0).toColor(),
            HSVColor.fromAHSV(1.0, (i + 1) * (360 / segments), 1.0, 1.0).toColor(),
          ],
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = adjustedStrokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      final linePaint = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 55;

      double gapRadius = radius + 5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: gapRadius),
        startAngle + startAngle,
        lineAngleGap,
        false,
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class VerticalSlider extends StatefulWidget {
  final double sliderHeight;
  final double thumbSize;
  final double thumbPosition;

  VerticalSlider({
    Key? key,
    this.sliderHeight = 400,
    this.thumbSize = 47,
    this.thumbPosition = 0.5,
  }) : super(key: key);

  @override
  _VerticalSliderState createState() => _VerticalSliderState();
}

class _VerticalSliderState extends State<VerticalSlider> {
  double _thumbPosition = 0.5;
  Color _selectedColor = const Color(0xFFE2C725);

  final List<Color> colors = [
    const Color(0xFFE2C725),
    const Color(0xFFFFE23E),
    const Color(0xFFFEE55A),
    const Color(0xFFFFEE91),
    const Color(0xFFFFF7C8),
    Colors.white,
    const Color(0xFFEDEDFF),
    const Color(0xFFDCDCFF),
  ];

  @override
  void initState() {
    super.initState();
    // Set the thumb position to the top of the slider
    final thumbRadius = widget.thumbSize / 2;
    final sliderHeight = widget.sliderHeight;
    _thumbPosition = (5 + thumbRadius) / sliderHeight;
    _selectedColor = colors[0];
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final sliderHeight = widget.sliderHeight;
    final thumbRadius = widget.thumbSize / 2;

    // Adjust thumb position based on drag
    double newThumbPosition = _thumbPosition + details.delta.dy / sliderHeight;
    newThumbPosition = newThumbPosition.clamp(
      (5 + thumbRadius) / sliderHeight,
      0.83 - (thumbRadius / sliderHeight),
    );

    setState(() {
      _thumbPosition = newThumbPosition;

      double normalizedPosition = (_thumbPosition - (thumbRadius / sliderHeight)) / (0.83 - (2 * thumbRadius / sliderHeight)); // Adjusted range

      normalizedPosition = normalizedPosition.clamp(0.0, 1.0);
      int colorIndex = (normalizedPosition * (colors.length - 1)).round();
      _selectedColor = colors[colorIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.sliderHeight,
      width: 57,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Slider background
          Column(
            children: List.generate(colors.length, (index) {
              BorderRadius? borderRadius;
              if (index == 0) {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(100));
              } else if (index == colors.length - 1) {
                borderRadius = const BorderRadius.vertical(bottom: Radius.circular(100));
              } else {
                borderRadius = BorderRadius.zero;
              }
              return Expanded(
                child: Container(
                  width: 57,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: borderRadius,
                  ),
                ),
              );
            }),
          ),
          // Thumb
          Positioned(
            top: (_thumbPosition * widget.sliderHeight) - (widget.thumbSize / 2),
            child: GestureDetector(
              onVerticalDragUpdate: _onDragUpdate,
              child: SizedBox(
                width: widget.thumbSize,
                height: widget.thumbSize,
                child: ClipOval(
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
