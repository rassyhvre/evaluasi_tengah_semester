/// Model class representing plant sensor data.
/// Ready for backend/API integration — just replace dummy values
/// with deserialized JSON from your API response.
class PlantData {
  final String plantName;
  final String plantType;
  final double soilMoisture; // 0.0 - 100.0 (%)
  final double temperature; // in °C
  final double humidity; // 0.0 - 100.0 (%)
  final bool isPumpActive;
  final DateTime lastWatered;
  final double lightIntensity; // 0.0 - 100.0 (%)

  const PlantData({
    required this.plantName,
    required this.plantType,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.isPumpActive,
    required this.lastWatered,
    required this.lightIntensity,
  });

  /// Factory constructor for JSON deserialization (API-ready).
  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      plantName: json['plant_name'] as String,
      plantType: json['plant_type'] as String,
      soilMoisture: (json['soil_moisture'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      isPumpActive: json['is_pump_active'] as bool,
      lastWatered: DateTime.parse(json['last_watered'] as String),
      lightIntensity: (json['light_intensity'] as num).toDouble(),
    );
  }

  /// Serialize to JSON for sending to API.
  Map<String, dynamic> toJson() {
    return {
      'plant_name': plantName,
      'plant_type': plantType,
      'soil_moisture': soilMoisture,
      'temperature': temperature,
      'humidity': humidity,
      'is_pump_active': isPumpActive,
      'last_watered': lastWatered.toIso8601String(),
      'light_intensity': lightIntensity,
    };
  }

  /// Create a copy with updated fields.
  PlantData copyWith({
    String? plantName,
    String? plantType,
    double? soilMoisture,
    double? temperature,
    double? humidity,
    bool? isPumpActive,
    DateTime? lastWatered,
    double? lightIntensity,
  }) {
    return PlantData(
      plantName: plantName ?? this.plantName,
      plantType: plantType ?? this.plantType,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      isPumpActive: isPumpActive ?? this.isPumpActive,
      lastWatered: lastWatered ?? this.lastWatered,
      lightIntensity: lightIntensity ?? this.lightIntensity,
    );
  }

  /// Dummy data for development and testing.
  static PlantData get dummy => PlantData(
        plantName: 'Monstera Deliciosa',
        plantType: 'Tropical Plant',
        soilMoisture: 68.0,
        temperature: 27.5,
        humidity: 72.0,
        isPumpActive: false,
        lastWatered: DateTime.now().subtract(const Duration(hours: 3, minutes: 24)),
        lightIntensity: 85.0,
      );

  /// Multiple dummy plants for testing.
  static List<PlantData> get dummyList => [
        PlantData(
          plantName: 'Monstera Deliciosa',
          plantType: 'Tropical Plant',
          soilMoisture: 68.0,
          temperature: 27.5,
          humidity: 72.0,
          isPumpActive: false,
          lastWatered:
              DateTime.now().subtract(const Duration(hours: 3, minutes: 24)),
          lightIntensity: 85.0,
        ),
        PlantData(
          plantName: 'Fiddle Leaf Fig',
          plantType: 'Indoor Plant',
          soilMoisture: 42.0,
          temperature: 25.0,
          humidity: 55.0,
          isPumpActive: true,
          lastWatered:
              DateTime.now().subtract(const Duration(minutes: 15)),
          lightIntensity: 60.0,
        ),
        PlantData(
          plantName: 'Snake Plant',
          plantType: 'Succulent',
          soilMoisture: 30.0,
          temperature: 26.0,
          humidity: 40.0,
          isPumpActive: false,
          lastWatered:
              DateTime.now().subtract(const Duration(days: 2, hours: 8)),
          lightIntensity: 45.0,
        ),
      ];
}
