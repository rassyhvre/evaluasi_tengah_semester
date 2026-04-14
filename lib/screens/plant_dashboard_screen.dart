import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/plant_theme.dart';
import '../providers/plant_provider.dart';
import '../widgets/circular_gauge.dart';
import '../widgets/moisture_bar.dart';
import '../widgets/pump_status_card.dart';
import '../widgets/plant_selector.dart';
import '../widgets/plant_loading_shimmer.dart';

/// Main dashboard screen for the Smart Plant Monitor.
/// Displays real-time sensor data, moisture charts, and pump controls.
class PlantDashboardScreen extends StatelessWidget {
  const PlantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: PlantTheme.scaffoldBg,
      body: Consumer<PlantProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const _DashboardLoadingView();
          }
          if (provider.errorMessage != null) {
            return _DashboardErrorView(
              message: provider.errorMessage!,
              onRetry: provider.refreshData,
            );
          }
          return const _DashboardContent();
        },
      ),
    );
  }
}

/// Loading state view.
class _DashboardLoadingView extends StatelessWidget {
  const _DashboardLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, isLoading: true),
        const Expanded(child: PlantLoadingShimmer()),
      ],
    );
  }
}

/// Error state view.
class _DashboardErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, isLoading: false),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(PlantTheme.spacingXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: PlantTheme.danger.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: PlantTheme.danger,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: PlantTheme.spacingMd),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: PlantTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: PlantTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: PlantTheme.spacingLg),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlantTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(PlantTheme.radiusMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Main dashboard content.
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          Provider.of<PlantProvider>(context, listen: false).refreshData(),
      color: PlantTheme.primaryGreen,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader(context, isLoading: false)),

          // Plant selector
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: PlantTheme.spacingMd, bottom: 8),
              child: Consumer<PlantProvider>(
                builder: (context, provider, _) {
                  return PlantSelector(
                    plantNames:
                        provider.plants.map((p) => p.plantName).toList(),
                    selectedIndex: provider.selectedPlantIndex,
                    onSelected: provider.selectPlant,
                  );
                },
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(PlantTheme.spacingLg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Plant Info Header ──
                _buildPlantInfoCard(),
                const SizedBox(height: PlantTheme.spacingLg),

                // ── Section: Sensor Overview ──
                const _SectionTitle(
                  title: 'Sensor Overview',
                  icon: Icons.sensors,
                ),
                const SizedBox(height: PlantTheme.spacingMd),

                // Sensor gauge row
                _buildGaugeRow(),
                const SizedBox(height: PlantTheme.spacingMd),

                // Sensor grid cards
                _buildSensorGrid(),
                const SizedBox(height: PlantTheme.spacingLg),

                // ── Section: Soil Moisture Detail ──
                const _SectionTitle(
                  title: 'Soil Moisture',
                  icon: Icons.grass,
                ),
                const SizedBox(height: PlantTheme.spacingMd),
                _buildMoistureCard(),
                const SizedBox(height: PlantTheme.spacingLg),

                // ── Section: Pump Control ──
                const _SectionTitle(
                  title: 'Pump Control',
                  icon: Icons.water_drop,
                ),
                const SizedBox(height: PlantTheme.spacingMd),
                _buildPumpControl(),
                const SizedBox(height: PlantTheme.spacingXl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfoCard() {
    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        final plant = provider.selectedPlant!;
        return AnimatedSwitcher(
          duration: PlantTheme.animNormal,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: Container(
            key: ValueKey(plant.plantName),
            padding: const EdgeInsets.all(PlantTheme.spacingLg),
            decoration: BoxDecoration(
              gradient: PlantTheme.primaryGradient,
              borderRadius: BorderRadius.circular(PlantTheme.radiusLg),
              boxShadow: PlantTheme.elevatedShadow,
            ),
            child: Row(
              children: [
                // Plant icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(PlantTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.yard,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: PlantTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.plantName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(PlantTheme.radiusSm),
                        ),
                        child: Text(
                          plant.plantType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: PlantTheme.mintGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online • Monitoring active',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGaugeRow() {
    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        final plant = provider.selectedPlant!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              CircularGaugeWidget(
                value: plant.soilMoisture,
                label: 'Moisture',
                icon: Icons.water_drop,
                gradient: PlantTheme.moistureGradient,
              ),
              const SizedBox(width: PlantTheme.spacingMd),
              CircularGaugeWidget(
                value: plant.humidity,
                label: 'Humidity',
                icon: Icons.cloud,
                gradient: PlantTheme.humidityGradient,
              ),
              const SizedBox(width: PlantTheme.spacingMd),
              CircularGaugeWidget(
                value: plant.lightIntensity,
                label: 'Light',
                icon: Icons.wb_sunny,
                gradient: PlantTheme.lightGradient,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorGrid() {
    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        final plant = provider.selectedPlant!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 400 ? 3 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: PlantTheme.spacingMd,
              mainAxisSpacing: PlantTheme.spacingMd,
              childAspectRatio: 1.1,
              children: [
                _AnimatedSensorCard(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: '${plant.temperature.toStringAsFixed(1)}°C',
                  subtitle: plant.temperature <= 30 ? 'Normal' : 'High',
                  iconColor: PlantTheme.warning,
                  iconBgColor: PlantTheme.warning.withValues(alpha: 0.1),
                ),
                _AnimatedSensorCard(
                  icon: Icons.water_drop,
                  label: 'Soil Moisture',
                  value: '${plant.soilMoisture.toStringAsFixed(1)}%',
                  subtitle: PlantTheme.moistureLabel(plant.soilMoisture),
                  iconColor: PlantTheme.info,
                  iconBgColor: PlantTheme.info.withValues(alpha: 0.1),
                ),
                _AnimatedSensorCard(
                  icon: Icons.cloud,
                  label: 'Humidity',
                  value: '${plant.humidity.toStringAsFixed(1)}%',
                  subtitle: plant.humidity >= 60 ? 'Humid' : 'Dry',
                  iconColor: PlantTheme.accentGreen,
                  iconBgColor: PlantTheme.accentGreen.withValues(alpha: 0.1),
                ),
                _AnimatedSensorCard(
                  icon: Icons.wb_sunny,
                  label: 'Light',
                  value: '${plant.lightIntensity.toStringAsFixed(0)}%',
                  subtitle: plant.lightIntensity >= 60 ? 'Bright' : 'Low',
                  iconColor: const Color(0xFFF4D35E),
                  iconBgColor: const Color(0xFFF4D35E).withValues(alpha: 0.12),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMoistureCard() {
    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        final plant = provider.selectedPlant!;
        return Container(
          padding: const EdgeInsets.all(PlantTheme.spacingLg),
          decoration: BoxDecoration(
            color: PlantTheme.cardBg,
            borderRadius: BorderRadius.circular(PlantTheme.radiusLg),
            boxShadow: PlantTheme.cardShadow,
            border: Border.all(
              color: PlantTheme.paleGreen.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              MoistureBar(value: plant.soilMoisture),
              const SizedBox(height: PlantTheme.spacingMd),
              Divider(
                color: PlantTheme.paleGreen.withValues(alpha: 0.5),
                height: 1,
              ),
              const SizedBox(height: PlantTheme.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MiniStat(
                    icon: Icons.arrow_downward,
                    label: 'Min Today',
                    value: '${(plant.soilMoisture - 12).clamp(0, 100).toStringAsFixed(0)}%',
                    color: PlantTheme.danger,
                  ),
                  _MiniStat(
                    icon: Icons.arrow_upward,
                    label: 'Max Today',
                    value: '${(plant.soilMoisture + 8).clamp(0, 100).toStringAsFixed(0)}%',
                    color: PlantTheme.success,
                  ),
                  _MiniStat(
                    icon: Icons.show_chart,
                    label: 'Average',
                    value: '${plant.soilMoisture.toStringAsFixed(0)}%',
                    color: PlantTheme.info,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPumpControl() {
    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        final plant = provider.selectedPlant!;
        return PumpStatusCard(
          isActive: plant.isPumpActive,
          lastWatered: plant.lastWatered,
          onToggle: provider.togglePump,
        );
      },
    );
  }
}

// ── Shared Header ──

Widget _buildHeader(BuildContext context, {required bool isLoading}) {
  return Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 16,
      left: PlantTheme.spacingLg,
      right: PlantTheme.spacingLg,
      bottom: PlantTheme.spacingLg,
    ),
    decoration: const BoxDecoration(
      gradient: PlantTheme.headerGradient,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(PlantTheme.radiusXl),
        bottomRight: Radius.circular(PlantTheme.radiusXl),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: PlantTheme.mintGreen, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Smart Plant',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isLoading ? 'Loading data...' : 'Real-time monitoring',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Notification bell
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(PlantTheme.radiusSm),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: PlantTheme.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Settings
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(PlantTheme.radiusSm),
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Helper Widgets ──

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: PlantTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: PlantTheme.primaryGreen),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: PlantTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: PlantTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Sensor card with fade+slide animation when it enters the view.
class _AnimatedSensorCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color iconColor;
  final Color iconBgColor;

  const _AnimatedSensorCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  State<_AnimatedSensorCard> createState() => _AnimatedSensorCardState();
}

class _AnimatedSensorCardState extends State<_AnimatedSensorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  borderRadius: BorderRadius.circular(PlantTheme.radiusSm),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 20),
              ),
              const Spacer(),
              // Value with animated transition
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
                  widget.value,
                  key: ValueKey<String>(widget.value),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: PlantTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PlantTheme.textSecondary,
                ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 10,
                    color: PlantTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
