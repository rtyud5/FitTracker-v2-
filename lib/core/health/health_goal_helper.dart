class HealthGoalHelper {
  HealthGoalHelper._();

  static const String weightLoss = 'weight loss';
  static const String weightGain = 'weight gain';
  static const String muscleBuilding = 'muscle building';
  static const String maintainWeight = 'maintain weight';

  static const List<String> displayOptions = [
    'Weight loss',
    'Weight gain',
    'Muscle building',
    'Maintain weight',
  ];

  static String normalize(dynamic value) {
    final raw = value?.toString().trim().toLowerCase() ?? '';
    if (raw.isEmpty) return maintainWeight;
    if (raw.contains('lose') || raw == weightLoss) return weightLoss;
    if (raw.contains('gain') || raw.contains('bulk') || raw == weightGain) {
      return weightGain;
    }
    if (raw.contains('muscle') || raw.contains('build')) return muscleBuilding;
    return maintainWeight;
  }

  static String displayLabel(dynamic value) {
    switch (normalize(value)) {
      case weightLoss:
        return 'Weight loss';
      case weightGain:
        return 'Weight gain';
      case muscleBuilding:
        return 'Muscle building';
      default:
        return 'Maintain weight';
    }
  }
}
