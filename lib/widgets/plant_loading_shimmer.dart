import 'package:flutter/material.dart';
import '../core/theme/plant_theme.dart';

/// Shimmer loading placeholder widget.
/// Displays animated loading skeleton while data is being fetched.
class PlantLoadingShimmer extends StatefulWidget {
  const PlantLoadingShimmer({super.key});

  @override
  State<PlantLoadingShimmer> createState() => _PlantLoadingShimmerState();
}

class _PlantLoadingShimmerState extends State<PlantLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFFE8F5EE),
                Color(0xFFD8F3DC),
                Color(0xFFE8F5EE),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PlantTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          _shimmerBox(width: 200, height: 28),
          const SizedBox(height: 8),
          _shimmerBox(width: 140, height: 16),
          const SizedBox(height: PlantTheme.spacingLg),

          // Plant selector shimmer
          Row(
            children: [
              _shimmerBox(width: 120, height: 40, borderRadius: 20),
              const SizedBox(width: 8),
              _shimmerBox(width: 100, height: 40, borderRadius: 20),
              const SizedBox(width: 8),
              _shimmerBox(width: 90, height: 40, borderRadius: 20),
            ],
          ),
          const SizedBox(height: PlantTheme.spacingLg),

          // Primary card shimmer
          _shimmerBox(
            width: double.infinity,
            height: 180,
            borderRadius: PlantTheme.radiusLg,
          ),
          const SizedBox(height: PlantTheme.spacingMd),

          // Grid shimmer
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  width: double.infinity,
                  height: 120,
                  borderRadius: PlantTheme.radiusMd,
                ),
              ),
              const SizedBox(width: PlantTheme.spacingMd),
              Expanded(
                child: _shimmerBox(
                  width: double.infinity,
                  height: 120,
                  borderRadius: PlantTheme.radiusMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: PlantTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  width: double.infinity,
                  height: 120,
                  borderRadius: PlantTheme.radiusMd,
                ),
              ),
              const SizedBox(width: PlantTheme.spacingMd),
              Expanded(
                child: _shimmerBox(
                  width: double.infinity,
                  height: 120,
                  borderRadius: PlantTheme.radiusMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: PlantTheme.spacingLg),

          // Pump card shimmer
          _shimmerBox(
            width: double.infinity,
            height: 100,
            borderRadius: PlantTheme.radiusLg,
          ),
        ],
      ),
    );
  }
}
