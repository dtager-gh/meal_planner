import 'dart:math';

import '../models/meal.dart';
import '../models/day_plan.dart';
import '../models/week_plan.dart';
import 'user_food_service.dart';

class FirestoreMealGenerator {
  final UserFoodService foodService;
  final Random random;

  FirestoreMealGenerator({
    UserFoodService? foodService,
    Random? random,
  })  : foodService = foodService ?? UserFoodService(),
        random = random ?? Random();

  Meal _generateMeal({
    required List<String> availableMeats,
    required List<String> veggies,
    required List<String> salads,
    required bool allowSalad,
  }) {
    if (availableMeats.isEmpty) {
      throw StateError('No enabled meats available.');
    }

    final meat = availableMeats[random.nextInt(availableMeats.length)];

    final bool useSalad = allowSalad ? random.nextBool() : false;

    if (useSalad && salads.isNotEmpty) {
      final salad = salads[random.nextInt(salads.length)];
      return Meal(meat: meat, sides: [salad]);
    }

    if (veggies.isEmpty) {
      // fallback if user has no veggies enabled
      if (salads.isNotEmpty) {
        final salad = salads[random.nextInt(salads.length)];
        return Meal(meat: meat, sides: [salad]);
      }
      // no sides available at all
      return Meal(meat: meat, sides: []);
    }

    final veg1 = veggies[random.nextInt(veggies.length)];
    String veg2 = veg1;

    if (veggies.length > 1) {
      do {
        veg2 = veggies[random.nextInt(veggies.length)];
      } while (veg2 == veg1);
    }

    return Meal(meat: meat, sides: [veg1, veg2]);
  }

  Future<WeekPlan> generateWeekPlan() async {
    final meats = await foodService.getEnabledFoodNames('Meat');
    final veggies = await foodService.getEnabledFoodNames('Vegetable');
    final salads = await foodService.getEnabledFoodNames('Salad');

    if (meats.isEmpty) {
      throw StateError('No enabled meats. Add/enable meats first.');
    }

    final List<DayPlan> days = [];

    for (int i = 0; i < 7; i++) {
      final bool saladAtLunch = random.nextBool();

      // fresh copy each day
      final availableMeats = List<String>.from(meats);

      final lunch = _generateMeal(
        availableMeats: availableMeats,
        veggies: veggies,
        salads: salads,
        allowSalad: saladAtLunch,
      );

      // remove lunch meat so dinner doesn't repeat it
      availableMeats.remove(lunch.meat);

      final dinner = _generateMeal(
        availableMeats: availableMeats.isEmpty ? List<String>.from(meats) : availableMeats,
        veggies: veggies,
        salads: salads,
        allowSalad: !saladAtLunch,
      );

      days.add(DayPlan(lunch: lunch, dinner: dinner));
    }

    return WeekPlan(days);
  }
}