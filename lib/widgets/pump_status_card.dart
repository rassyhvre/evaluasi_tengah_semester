import 'package:flutter/material.dart';
import '../core/theme/plant_theme.dart';

/// Pump status toggle card with animated indicator and glow effect.
class PumpStatusCard extends StatelessWidget {
  final bool isActive;
  final DateTime lastWatered;
  final VoidCallback onToggle;

  const PumpStatusCard({
    super.key,
    required this.isActive,
    required this.lastWatered,
    required this.onToggle,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ${diff.inHours % 24}h ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PlantTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
              )
            : PlantTheme.cardGradient,
        borderRadius: BorderRadius.circular(PlantTheme.radiusLg),
        boxShadow: isActive ? PlantTheme.elevatedShadow : PlantTheme.cardShadow,
        border: isActive
            ? null
            : Border.all(
                color: PlantTheme.paleGreen.withValues(alpha: 0.5),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          // Pump indicator with animated glow
          AnimatedContainer(
            duration: PlantTheme.animNormal,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : PlantTheme.surfaceGreen,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: PlantTheme.accentGreen.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isActive ? Icons.water_drop : Icons.water_drop_outlined,
              color: isActive ? Colors.white : PlantTheme.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: PlantTheme.spacingMd),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Pump',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Colors.white
                        : PlantTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: PlantTheme.animFast,
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF95D5B2)
                            : PlantTheme.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.8)
                            : PlantTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.6)
                          : PlantTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last watered: ${_formatTimeAgo(lastWatered)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.6)
                            : PlantTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Toggle button
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: PlantTheme.animNormal,
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.3)
                    : PlantTheme.paleGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(3),
              child: AnimatedAlign(
                duration: PlantTheme.animNormal,
                curve: Curves.easeOutBack,
                alignment:
                    isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : PlantTheme.textMuted,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
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
