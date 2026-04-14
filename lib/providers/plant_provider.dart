import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/plant_data.dart';

/// Provider for managing plant monitoring data and state.
/// 
/// Currently uses simulated data updates. To integrate with a real API:
/// 1. Inject/configure your API service
/// 2. Replace `_simulateDataFetch()` with actual HTTP calls
/// 3. The UI will update automatically via ChangeNotifier
class PlantProvider extends ChangeNotifier {
  List<PlantData> _plants = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedPlantIndex = 0;
  Timer? _updateTimer;

  // Getters
  List<PlantData> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedPlantIndex => _selectedPlantIndex;
  PlantData? get selectedPlant =>
      _plants.isNotEmpty ? _plants[_selectedPlantIndex] : null;

  PlantProvider() {
    _initializeData();
  }

  /// Initialize data — simulates an API call with a delay.
  Future<void> _initializeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      _plants = PlantData.dummyList;
      _isLoading = false;

      // Start periodic data simulation (every 8 seconds)
      _startPeriodicUpdates();
    } catch (e) {
      _errorMessage = 'Failed to load plant data: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Start periodic simulated sensor updates.
  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _simulateSensorUpdate();
    });
  }

  /// Simulate small sensor value fluctuations.
  void _simulateSensorUpdate() {
    if (_plants.isEmpty) return;

    final random = Random();
    _plants = _plants.map((plant) {
      return plant.copyWith(
        soilMoisture: (plant.soilMoisture + (random.nextDouble() * 4 - 2))
            .clamp(0.0, 100.0),
        temperature: (plant.temperature + (random.nextDouble() * 1.0 - 0.5))
            .clamp(15.0, 45.0),
        humidity: (plant.humidity + (random.nextDouble() * 3 - 1.5))
            .clamp(0.0, 100.0),
        lightIntensity:
            (plant.lightIntensity + (random.nextDouble() * 5 - 2.5))
                .clamp(0.0, 100.0),
      );
    }).toList();

    notifyListeners();
  }

  /// Select a plant by index.
  void selectPlant(int index) {
    if (index >= 0 && index < _plants.length) {
      _selectedPlantIndex = index;
      notifyListeners();
    }
  }

  /// Toggle the water pump for the selected plant.
  void togglePump() {
    if (_plants.isEmpty) return;

    final plant = _plants[_selectedPlantIndex];
    _plants[_selectedPlantIndex] = plant.copyWith(
      isPumpActive: !plant.isPumpActive,
      lastWatered: !plant.isPumpActive ? DateTime.now() : null,
    );
    notifyListeners();
  }

  /// Refresh data — simulates re-fetching from API.
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _plants = PlantData.dummyList;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
