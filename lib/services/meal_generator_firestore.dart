import 'dart:math';

import '../models/meal.dart';
import '../models/day_plan.dart';
import '../models/week_plan.dart';
import 'user_food_service.dart';

class FirestoreMealGenerator {
  final UserFoodService foodService;
  final Random _random;

  FirestoreMealGenerator({
    UserFoodService? foodService,
    Random? random,
  })  : foodService = foodService ?? UserFoodService(),
        _random = random ?? Random();

  /// This makes one meal using Firestore foods.
  /// - availableMeats: list of meats allowed (so lunch & dinner don’t repeat)
  /// - allowSalad: if true, this meal may become a salad-only meal
  Future<Meal> generateMeal({
    required List<String> availableMeats,
    required List<String> enabledVeggies,
    required List<String> enabledSalads,
    bool allowSalad = true,
  }) async {
    // Safety checks to avoid crashes
    if (availableMeats.isEmpty) {
      throw StateError('No enabled meats available.');
    }
    if (enabledVeggies.isEmpty && enabledSalads.isEmpty) {
      throw StateError('No enabled veggies or salads available.');
    }

    final meat = availableMeats[_random.nextInt(availableMeats.length)];

    final bool useSalad = allowSalad ? _random.nextBool() : false;

    // Salad meal: meat + 1 salad side (matching your old behavior)
    if (useSalad && enabledSalads.isNotEmpty) {
      final salad = enabledSalads[_random.nextInt(enabledSalads.length)];
      return Meal(meat: meat, sides: [salad]);
    }

    // Otherwise meat + 2 veggies (matching your old behavior)
    if (enabledVeggies.isEmpty) {
      // No veggies but salads exist, fall back to salad side
      final salad = enabledSalads[_random.nextInt(enabledSalads.length)];
      return Meal(meat: meat, sides: [salad]);
    }

    final veg1 = enabledVeggies[_random.nextInt(enabledVeggies.length)];
    String veg2 = veg1;

    // Try to pick a second different veg if possible
    if (enabledVeggies.length > 1) {
      do {
        veg2 = enabledVeggies[_random.nextInt(enabledVeggies.length)];
      } while (veg2 == veg1);
    }

    return Meal(meat: meat, sides: [veg1, veg2]);
  }

  /// Generates 7 days of lunch+dinner just like your current generateWeekPlan(),
  /// but using Firestore and respecting enabled == true.
  Future<WeekPlan> generateWeekPlan() async {
    final enabledMeats = await foodService.getEnabledFoodNames('Meat');
    final enabledVeggies = await foodService.getEnabledFoodNames('Vegetable');
    final enabledSalads = await foodService.getEnabledFoodNames('Salad');

    // Guard rails for a friendly user experience
    if (enabledMeats.isEmpty) {
      throw StateError('You have no enabled Meats. Go to Add Foods and enable/add some meats.');
    }
    if (enabledVeggies.isEmpty && enabledSalads.isEmpty) {
      throw StateError('You have no enabled Vegetables or Salads. Go to Add Foods and enable/add some.');
    }

    final List<DayPlan> days = [];

    for (int i = 0; i < 7; i++) {
      final bool saladAtLunch = _random.nextBool();

      // Fresh meat list each day so lunch & dinner won’t repeat within the day
      final availableMeats = List<String>.from(enabledMeats);

      // Lunch
      final lunch = await generateMeal(
        availableMeats: availableMeats,
        enabledVeggies: enabledVeggies,
        enabledSalads: enabledSalads,
        allowSalad: saladAtLunch,
      );

      // Remove lunch meat so dinner can't repeat it (your current logic)
      availableMeats.remove(lunch.meat);

      // Dinner: if lunch used salad, dinner can't; otherwise dinner can
      final dinner = await generateMeal(
        availableMeats: availableMeats.isEmpty ? List<String>.from(enabledMeats) : availableMeats,
        enabledVeggies: enabledVeggies,
        enabledSalads: enabledSalads,
        allowSalad: !saladAtLunch,
      );

      days.add(DayPlan(lunch: lunch, dinner: dinner));
    }

    return WeekPlan(days);
  }
}