import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/plant_theme.dart';

/// Animated circular gauge widget used for soil moisture, humidity, etc.
/// Shows a circular arc with percentage, label, and animated transitions.
class CircularGaugeWidget extends StatefulWidget {
  final double value; // 0 – 100
  final String label;
  final String unit;
  final IconData icon;
  final LinearGradient gradient;
  final double size;

  const CircularGaugeWidget({
    super.key,
    required this.value,
    required this.label,
    this.unit = '%',
    required this.icon,
    required this.gradient,
    this.size = 130,
  });

  @override
  State<CircularGaugeWidget> createState() => _CircularGaugeWidgetState();
}

class _CircularGaugeWidgetState extends State<CircularGaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PlantTheme.animSlow,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value;
      _animation = Tween<double>(begin: _previousValue, end: widget.value)
          .animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _GaugePainter(
              value: _animation.value,
              gradient: widget.gradient,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.gradient.colors.first,
                    size: widget.size * 0.18,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_animation.value.toStringAsFixed(1)}${widget.unit}',
                    style: TextStyle(
                      fontSize: widget.size * 0.15,
                      fontWeight: FontWeight.w700,
                      color: PlantTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.size * 0.09,
                      color: PlantTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final LinearGradient gradient;

  _GaugePainter({required this.value, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;
    final sweepAngle = sweepTotal * (value / 100).clamp(0.0, 1.0);

    // Background arc
    final bgPaint = Paint()
      ..color = PlantTheme.paleGreen.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      bgPaint,
    );

    // Foreground arc with gradient
    if (sweepAngle > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final fgPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: gradient.colors,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value;
}
