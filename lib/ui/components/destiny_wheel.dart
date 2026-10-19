import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models.dart';

String wheelOptionDisplayText(String text) =>
    text.replaceFirst(RegExp(r'[\s··・：:]?\d+(?:\.\d+)?%$'), '');

String shortWheelLabel(String text, int maxGraphemes) {
  final characters = text.runes.toList(growable: false);
  if (characters.length <= maxGraphemes) return text;
  if (maxGraphemes <= 1) return '…';
  return '${String.fromCharCodes(characters.take(maxGraphemes - 1))}…';
}

List<String> splitWheelLabel(
  String text, {
  required int maxCharactersPerLine,
  required int maxLines,
}) {
  final characters = text.runes.toList(growable: false);
  if (characters.isEmpty || maxCharactersPerLine < 1 || maxLines < 1) {
    return const <String>[];
  }

  final lines = <String>[];
  var offset = 0;
  for (var line = 0; line < maxLines && offset < characters.length; line++) {
    final remaining = characters.length - offset;
    final isLastLine = line == maxLines - 1;
    if (isLastLine && remaining > maxCharactersPerLine) {
      lines.add(
        shortWheelLabel(
          String.fromCharCodes(characters.skip(offset)),
          maxCharactersPerLine,
        ),
      );
      break;
    }
    final length = math.min(maxCharactersPerLine, remaining);
    lines.add(String.fromCharCodes(characters.skip(offset).take(length)));
    offset += length;
  }
  return lines;
}

List<double> wheelSweepAngles(List<WheelOption> options) {
  if (options.isEmpty) return const <double>[];
  final weights = options
      .map((option) => option.weight.isFinite ? math.max(0, option.weight) : 0)
      .toList(growable: false);
  final total = weights.fold<double>(0, (sum, weight) => sum + weight);
  if (total <= 0) {
    return List<double>.filled(options.length, math.pi * 2 / options.length);
  }
  const minimumReadableSweep = .09;
  final reserved = minimumReadableSweep * options.length;
  if (reserved >= math.pi * 2) {
    return List<double>.filled(options.length, math.pi * 2 / options.length);
  }
  final distributable = math.pi * 2 - reserved;
  return weights
      .map((weight) => minimumReadableSweep + weight / total * distributable)
      .toList(growable: false);
}

double wheelSegmentCenter(List<WheelOption> options, int index) {
  final sweeps = wheelSweepAngles(options);
  if (sweeps.isEmpty) return 0;
  final safeIndex = index.clamp(0, sweeps.length - 1);
  return sweeps.take(safeIndex).fold<double>(0, (sum, sweep) => sum + sweep) +
      sweeps[safeIndex] / 2;
}

List<double> wheelLabelRadii(double outerRadius, int lineCount) =>
    List<double>.generate(lineCount, (index) => outerRadius - index * 15);

class WheelLabelLayout {
  const WheelLabelLayout({
    required this.maxCharactersPerLine,
    required this.maxLines,
    required this.outerRadius,
  });

  final int maxCharactersPerLine;
  final int maxLines;
  final double outerRadius;
}

WheelLabelLayout wheelLabelLayout(
  String text, {
  required double radius,
  required double sweep,
}) {
  final length = text.runes.length;
  final innerRadius = radius * .56;
  final maxCharacters = math.max(
    3,
    math.min(7, (innerRadius * sweep * .86 / 8).ceil()),
  );
  final requiredLines = math.max(1, (length / maxCharacters).ceil());
  final maxLines = requiredLines.clamp(1, 5);
  final outward = maxLines == 5
      ? .92
      : maxLines == 4
      ? .88
      : .84;
  return WheelLabelLayout(
    maxCharactersPerLine: maxCharacters,
    maxLines: maxLines,
    outerRadius: radius * outward,
  );
}

List<String> splitWheelLabelForArc(
  String text, {
  required double radius,
  required double sweep,
  int maxLines = 5,
  double fontSize = 12,
}) {
  final characters = text
      .replaceAll(RegExp(r'\s+'), '')
      .runes
      .toList(growable: false);
  if (characters.isEmpty) return const <String>[];
  final lines = <String>[];
  var offset = 0;
  final outerRadius = radius * .92;
  for (var line = 0; line < maxLines && offset < characters.length; line++) {
    final lineRadius = math.max(radius * .55, outerRadius - line * 15);
    final capacity = math.max(
      1,
      math.min(8, (lineRadius * sweep * .84 / fontSize).floor()),
    );
    final remaining = characters.length - offset;
    final isFinalLine = line == maxLines - 1;
    if (isFinalLine && remaining > capacity) {
      lines.add('…');
      break;
    }
    final count = math.min(capacity, remaining);
    lines.add(String.fromCharCodes(characters.skip(offset).take(count)));
    offset += count;
  }
  return lines;
}

class DestinyWheel extends StatefulWidget {
  const DestinyWheel({
    super.key,
    required this.pool,
    required this.selectedIndex,
    required this.spinning,
    required this.onTap,
    this.onLongPress,
    this.presentationSequence = 0,
    this.animationDuration = const Duration(milliseconds: 2300),
  });

  final WheelPool pool;
  final int selectedIndex;
  final bool spinning;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int presentationSequence;
  final Duration animationDuration;

  @override
  State<DestinyWheel> createState() => _DestinyWheelState();
}

class _DestinyWheelState extends State<DestinyWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotation;
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _rotation = AlwaysStoppedAnimation<double>(_angle);
  }

  @override
  void didUpdateWidget(covariant DestinyWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning &&
        (!oldWidget.spinning ||
            widget.presentationSequence != oldWidget.presentationSequence) &&
        widget.pool.options.isNotEmpty) {
      final selectedCenter = wheelSegmentCenter(
        widget.pool.options,
        widget.selectedIndex,
      );
      final target = -math.pi / 2 - selectedCenter + math.pi * 2 * 6;
      if (widget.animationDuration <= Duration.zero) {
        _controller.stop();
        _angle = target % (math.pi * 2);
        _rotation = AlwaysStoppedAnimation<double>(_angle);
        return;
      }
      _controller.duration = widget.animationDuration;
      _rotation = Tween<double>(begin: _angle, end: target).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward().whenComplete(() {
          if (mounted) setState(() => _angle = target % (math.pi * 2));
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '命运转盘，${widget.pool.title}，点击转动，长按查看全部选项',
      child: GestureDetector(
        key: const Key('destiny-wheel'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.spinning ? null : widget.onTap,
        onLongPress: widget.spinning ? null : widget.onLongPress,
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              painter: _DestinyWheelPainter(
                options: widget.pool.options,
                rotation: widget.spinning ? _rotation.value : _angle,
                selectedIndex: widget.selectedIndex,
                textColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff10254a),
                    border: Border.all(
                      color: const Color(0xffd6ad5d),
                      width: 2,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.spinning ? '命运\n转动中' : '点击\n转动',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xfff7d77f),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinyWheelPainter extends CustomPainter {
  const _DestinyWheelPainter({
    required this.options,
    required this.rotation,
    required this.selectedIndex,
    required this.textColor,
  });

  final List<WheelOption> options;
  final double rotation;
  final int selectedIndex;
  final Color textColor;

  static const List<Color> _colors = <Color>[
    Color(0xff563e88),
    Color(0xff245080),
    Color(0xff844660),
    Color(0xff3a6f78),
    Color(0xff936338),
    Color(0xff46386e),
    Color(0xff8a5b89),
    Color(0xff3f5f95),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 7;
    final sweeps = wheelSweepAngles(options);
    final rect = Rect.fromCircle(center: center, radius: radius);
    var start = rotation;

    for (var index = 0; index < options.length; index++) {
      final sweep = sweeps[index];
      final paint = Paint()..color = _colors[index % _colors.length];
      canvas.drawArc(rect, start, sweep, true, paint);
      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        Paint()
          ..color = const Color(0x55ffffff)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      if (sweep > .01) {
        _drawArcLabel(
          canvas,
          center,
          radius,
          start,
          sweep,
          options[index].text,
        );
      }
      start += sweep;
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xffd6ad5d)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    final pointer = Path()
      ..moveTo(center.dx - 12, 1)
      ..lineTo(center.dx + 12, 1)
      ..lineTo(center.dx, 26)
      ..close();
    canvas.drawPath(pointer, Paint()..color = const Color(0xfff3ce70));
  }

  void _drawArcLabel(
    Canvas canvas,
    Offset center,
    double wheelRadius,
    double start,
    double sweep,
    String rawText,
  ) {
    final style = TextStyle(
      color: textColor,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      shadows: const <Shadow>[Shadow(color: Color(0xaa000000), blurRadius: 2)],
    );
    final labels = splitWheelLabelForArc(
      wheelOptionDisplayText(rawText),
      radius: wheelRadius,
      sweep: sweep,
    );
    final radii = wheelLabelRadii(wheelRadius * .92, labels.length);
    for (var index = 0; index < labels.length; index++) {
      _drawArcLine(
        canvas,
        center,
        radii[index],
        start,
        sweep,
        labels[index],
        style,
      );
    }
  }

  void _drawArcLine(
    Canvas canvas,
    Offset center,
    double labelRadius,
    double start,
    double sweep,
    String label,
    TextStyle style,
  ) {
    final glyphs = label.runes.map(String.fromCharCode).toList(growable: false);
    final painters = glyphs
        .map(
          (glyph) => TextPainter(
            text: TextSpan(text: glyph, style: style),
            textDirection: TextDirection.ltr,
          )..layout(),
        )
        .toList(growable: false);
    final fullWidth = painters.fold<double>(0, (sum, p) => sum + p.width);
    var cursor = start + sweep / 2 - fullWidth / labelRadius / 2;

    for (var index = 0; index < painters.length; index++) {
      final painter = painters[index];
      final width = painter.width;
      final angle = cursor + width / labelRadius / 2;
      canvas.save();
      canvas.translate(
        center.dx + math.cos(angle) * labelRadius,
        center.dy + math.sin(angle) * labelRadius,
      );
      canvas.rotate(angle + math.pi / 2);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
      cursor += width / labelRadius;
    }
  }

  @override
  bool shouldRepaint(covariant _DestinyWheelPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.options != options ||
      oldDelegate.textColor != textColor;
}
