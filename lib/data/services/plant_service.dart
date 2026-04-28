import 'dart:math';
import '../../models/plant_data.dart';

/// Service for fetching and managing plant sensor data.
/// 
/// Currently uses simulated data. To integrate with a real API:
/// 1. Replace `fetchPlants()` with actual HTTP calls
/// 2. Replace `simulateSensorUpdate()` with real-time data fetch
class PlantService {
  /// Fetch all plants — simulates API call with delay.
  Future<List<PlantData>> fetchPlants() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    return PlantData.dummyList;
  }

  /// Refresh plant data — simulates re-fetching from API.
  Future<List<PlantData>> refreshPlants() async {
    await Future.delayed(const Duration(seconds: 1));
    return PlantData.dummyList;
  }

  /// Simulate small sensor value fluctuations.
  /// In production, replace with actual API polling.
  List<PlantData> simulateSensorUpdate(List<PlantData> currentPlants) {
    if (currentPlants.isEmpty) return currentPlants;

    final random = Random();
    return currentPlants.map((plant) {
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
  }

  /// Toggle pump for a given plant — in production, call API endpoint.
  PlantData togglePump(PlantData plant) {
    return plant.copyWith(
      isPumpActive: !plant.isPumpActive,
      lastWatered: !plant.isPumpActive ? DateTime.now() : null,
    );
  }
}
