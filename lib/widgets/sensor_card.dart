import 'package:flutter/material.dart';
import '../core/theme/plant_theme.dart';

/// A single stat info card with icon, label, value, and animated transitions.
/// Used for temperature, humidity, light, etc.
class SensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color iconColor;
  final Color iconBgColor;

  const SensorCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PlantTheme.spacingMd),
      decoration: BoxDecoration(
        color: PlantTheme.cardBg,
        borderRadius: BorderRadius.circular(PlantTheme.radiusMd),
        boxShadow: PlantTheme.cardShadow,
        border: Border.all(
          color: PlantTheme.paleGreen.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(PlantTheme.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: PlantTheme.spacingSm + 4),
          // Value
          AnimatedSwitcher(
            duration: PlantTheme.animNormal,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: PlantTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: PlantTheme.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 10,
                color: PlantTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
