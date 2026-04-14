import 'package:flutter/material.dart';
import '../core/theme/plant_theme.dart';

/// Horizontal scrollable plant selector chips.
class PlantSelector extends StatelessWidget {
  final List<String> plantNames;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PlantSelector({
    super.key,
    required this.plantNames,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PlantTheme.spacingLg),
        itemCount: plantNames.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: PlantTheme.spacingSm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: PlantTheme.animNormal,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? PlantTheme.primaryGreen : PlantTheme.cardBg,
                borderRadius: BorderRadius.circular(PlantTheme.radiusLg),
                border: isSelected
                    ? null
                    : Border.all(
                        color: PlantTheme.mintGreen,
                        width: 1.5,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              PlantTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : PlantTheme.primaryGreenLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    plantNames[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : PlantTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
