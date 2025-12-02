import 'meal.dart';

// Represents the meals for a single day
class DayPlan {

  // Lunch meal
  final Meal lunch;

  // Dinner meal
  final Meal dinner;

  // Constructor: requires both lunch and dinner
  DayPlan({required this.lunch, required this.dinner});

  // Convert the DayPlan into JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'lunch': lunch.toJson(),// Convert lunch Meal to JSON
      'dinner': dinner.toJson(), // Convert dinner Meal to JSON
    };
  }

  // Create a DayPlan from JSON (used when loading saved plans)
  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      lunch: Meal.fromJson(json['lunch']),// Load lunch from JSON
      dinner: Meal.fromJson(json['dinner']),// Load dinner from JSON
    );
  }
}
