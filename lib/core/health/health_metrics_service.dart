class HealthMetricsResult {
  final double bmi;
  final int dailyCalories;
  final Map<String, int> macroTargets;

  const HealthMetricsResult({
    required this.bmi,
    required this.dailyCalories,
    required this.macroTargets,
  });
}

class HealthMetricsService {
  HealthMetricsService._();

  static const Map<String, double> _activityFactors = {
    'student': 1.2,
    'not employed': 1.2,
    'retired': 1.2,
    'employed part-time': 1.375,
    'employed full-time': 1.55,
  };

  static double? calculateBmi({
    required double? heightCm,
    required double? weightKg,
  }) {
    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      return null;
    }
    final heightM = heightCm / 100;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  static double? calculateBmr({
    required String? gender,
    required int? age,
    required double? heightCm,
    required double? weightKg,
  }) {
    if (gender == null || age == null || heightCm == null || weightKg == null) {
      return null;
    }
    final normalizedGender = gender.trim().toLowerCase();
    if (normalizedGender == 'male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    }
    return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
  }

  static int? calculateDailyCalories({
    required String? gender,
    required int? age,
    required double? heightCm,
    required double? weightKg,
    required String? lifestyle,
  }) {
    final bmr = calculateBmr(
      gender: gender,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
    );
    if (bmr == null) return null;
    final factor = _activityFactors[lifestyle?.trim().toLowerCase()] ?? 1.2;
    return (bmr * factor).round();
  }

  static Map<String, int>? calculateMacroTargets({required int? dailyCalories}) {
    if (dailyCalories == null || dailyCalories <= 0) return null;
    return {
      'calories': dailyCalories,
      'protein': (dailyCalories * 0.15 / 4).round(),
      'fat': (dailyCalories * 0.25 / 9).round(),
      'carbs': (dailyCalories * 0.60 / 4).round(),
      'fiber': 25,
    };
  }

  static Map<String, Map<String, int>> calculateMealTargets({
    required int dailyCalories,
    required Map<String, int> macroTargets,
  }) {
    const distribution = {
      'breakfast': 0.3,
      'lunch': 0.4,
      'dinner': 0.3,
    };

    return distribution.map((meal, ratio) {
      return MapEntry(meal, {
        'calories': (dailyCalories * ratio).round(),
        'protein': ((macroTargets['protein'] ?? 0) * ratio).round(),
        'fat': ((macroTargets['fat'] ?? 0) * ratio).round(),
        'carbs': ((macroTargets['carbs'] ?? 0) * ratio).round(),
        'fiber': ((macroTargets['fiber'] ?? 0) * ratio).round(),
      });
    });
  }

  static double calculateHydrationGoalLiters({required double? weightKg}) {
    if (weightKg == null || weightKg <= 0) return 2.0;
    final liters = weightKg * 0.033;
    return double.parse(liters.clamp(1.5, 4.5).toStringAsFixed(2));
  }

  static HealthMetricsResult? calculateFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return null;
    final height = _toDouble(profile['height']);
    final weight = _toDouble(profile['weight']);
    final age = _toInt(profile['age']);
    final gender = profile['gender']?.toString();
    final lifestyle = profile['lifestyle']?.toString();

    final bmi = calculateBmi(heightCm: height, weightKg: weight);
    final dailyCalories = calculateDailyCalories(
      gender: gender,
      age: age,
      heightCm: height,
      weightKg: weight,
      lifestyle: lifestyle,
    );
    final macros = calculateMacroTargets(dailyCalories: dailyCalories);

    if (bmi == null || dailyCalories == null || macros == null) return null;
    return HealthMetricsResult(
      bmi: bmi,
      dailyCalories: dailyCalories,
      macroTargets: macros,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }
}
