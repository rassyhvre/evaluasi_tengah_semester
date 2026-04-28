import 'dart:async';
import 'package:flutter/material.dart';
import '../models/plant_data.dart';
import '../data/services/plant_service.dart';

/// Provider for managing plant monitoring data and state.
/// 
/// Delegates all data operations to [PlantService].
/// The UI updates automatically via ChangeNotifier.
class PlantProvider extends ChangeNotifier {
  final PlantService _plantService = PlantService();

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

  /// Initialize data via PlantService.
  Future<void> _initializeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plants = await _plantService.fetchPlants();
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

  /// Delegate sensor update simulation to PlantService.
  void _simulateSensorUpdate() {
    _plants = _plantService.simulateSensorUpdate(_plants);
    notifyListeners();
  }

  /// Select a plant by index.
  void selectPlant(int index) {
    if (index >= 0 && index < _plants.length) {
      _selectedPlantIndex = index;
      notifyListeners();
    }
  }

  /// Toggle the water pump for the selected plant via PlantService.
  void togglePump() {
    if (_plants.isEmpty) return;

    _plants[_selectedPlantIndex] =
        _plantService.togglePump(_plants[_selectedPlantIndex]);
    notifyListeners();
  }

  /// Refresh data via PlantService.
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    _plants = await _plantService.refreshPlants();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
