import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Animated audio waveform visualizer using CustomPainter.
/// Shows animated bars that respond to playback state.
class WaveformVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;
  final double height;
  final double width;

  const WaveformVisualizer({
    super.key,
    required this.isPlaying,
    this.color = AppColors.accent,
    this.barCount = 32,
    this.height = 60,
    this.width = double.infinity,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _barHeights;
  late List<double> _targetHeights;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => 0.2);
    _targetHeights = List.generate(widget.barCount, (_) => 0.2);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(_updateBars);

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _generateTargets();
    _controller.forward(from: 0).then((_) {
      if (mounted && widget.isPlaying) {
        _startAnimation();
      }
    });
  }

  void _generateTargets() {
    _targetHeights = List.generate(widget.barCount, (i) {
      // Create a wave-like pattern
      final base = 0.3 + _random.nextDouble() * 0.7;
      return base;
    });
  }

  void _updateBars() {
    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        _barHeights[i] += (_targetHeights[i] - _barHeights[i]) * 0.3;
      }
    });
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startAnimation();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
      setState(() {
        _barHeights = List.generate(widget.barCount, (_) => 0.15);
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
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: CustomPaint(
        painter: _WaveformPainter(
          barHeights: _barHeights,
          color: widget.color,
          barCount: widget.barCount,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;
  final int barCount;

  _WaveformPainter({
    required this.barHeights,
    required this.color,
    required this.barCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (barCount * 2);
    final spacing = barWidth;
    final maxHeight = size.height;

    for (int i = 0; i < barCount && i < barHeights.length; i++) {
      final x = i * (barWidth + spacing) + spacing / 2;
      final height = maxHeight * barHeights[i];
      final top = (maxHeight - height) / 2;

      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          color.withValues(alpha: 0.4),
          color,
          color.withValues(alpha: 0.6),
        ],
      );

      final rect = Rect.fromLTWH(x, top, barWidth, height);
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
