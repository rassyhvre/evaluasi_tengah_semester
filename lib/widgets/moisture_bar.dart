import 'package:flutter/material.dart';
import '../core/theme/plant_theme.dart';

/// Animated horizontal moisture bar with gradient fill and percentage label.
class MoistureBar extends StatefulWidget {
  final double value; // 0 – 100
  final double height;

  const MoistureBar({
    super.key,
    required this.value,
    this.height = 12,
  });

  @override
  State<MoistureBar> createState() => _MoistureBarState();
}

class _MoistureBarState extends State<MoistureBar>
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
  void didUpdateWidget(MoistureBar oldWidget) {
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
      builder: (context, _) {
        final val = _animation.value.clamp(0.0, 100.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soil Moisture',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PlantTheme.textSecondary,
                  ),
                ),
                Text(
                  '${val.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PlantTheme.moistureColor(val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: PlantTheme.paleGreen.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: val / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PlantTheme.moistureColor(val).withValues(alpha: 0.7),
                          PlantTheme.moistureColor(val),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: PlantTheme.moistureColor(val)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              PlantTheme.moistureLabel(val),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: PlantTheme.moistureColor(val),
              ),
            ),
          ],
        );
      },
    );
  }
}
