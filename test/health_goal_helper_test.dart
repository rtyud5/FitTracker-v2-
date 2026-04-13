import 'package:flutter_test/flutter_test.dart';
import 'package:fittracker_source/core/health/health_goal_helper.dart';

void main() {
  group('HealthGoalHelper', () {
    test('normalizes display labels to canonical values', () {
      expect(HealthGoalHelper.normalize('Weight loss'), HealthGoalHelper.weightLoss);
      expect(HealthGoalHelper.normalize('Muscle building'), HealthGoalHelper.muscleBuilding);
      expect(HealthGoalHelper.normalize('Maintain weight'), HealthGoalHelper.maintainWeight);
    });

    test('maps canonical values back to display labels', () {
      expect(HealthGoalHelper.displayLabel('weight gain'), 'Weight gain');
      expect(HealthGoalHelper.displayLabel('muscle building'), 'Muscle building');
    });
  });
}
