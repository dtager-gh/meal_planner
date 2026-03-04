import 'package:flutter_test/flutter_test.dart';

import 'package:meal_planner/models/meal.dart';
import 'package:meal_planner/models/day_plan.dart';
import 'package:meal_planner/models/week_plan.dart';
import 'package:meal_planner/services/shopping_list.dart';

void main() {
  test('generateShoppingList counts meats and sides correctly', () {
    // Day 1: lunch chicken + [rice], dinner beef + [potatoes]
    final day1 = DayPlan(
      lunch: Meal(meat: 'Chicken', sides: ['Rice']),
      dinner: Meal(meat: 'Beef', sides: ['Potatoes']),
    );

    // Day 2: lunch chicken + [salad], dinner fish + [rice]
    final day2 = DayPlan(
      lunch: Meal(meat: 'Chicken', sides: ['Salad']),
      dinner: Meal(meat: 'Fish', sides: ['Rice']),
    );

    final week = WeekPlan([day1, day2]);

    final shopping = generateShoppingList(week);

    // Expected counts:
    // Chicken appears twice (day1 lunch, day2 lunch)
    // Beef once
    // Fish once
    // Rice appears twice (day1 lunch, day2 dinner)
    // Potatoes once
    // Salad once
    expect(shopping['Chicken'], 2);
    expect(shopping['Beef'], 1);
    expect(shopping['Fish'], 1);
    expect(shopping['Rice'], 2);
    expect(shopping['Potatoes'], 1);
    expect(shopping['Salad'], 1);

    // Also ensure no unexpected keys
    expect(shopping.length, 6);
  });
}

