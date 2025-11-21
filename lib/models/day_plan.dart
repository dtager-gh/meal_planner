import 'meal.dart';

class DayPlan {
  final Meal lunch;
  final Meal dinner;

  DayPlan({required this.lunch, required this.dinner});

  // Convert DayPlan → JSON
  Map<String, dynamic> toJson() {
    return {
      'lunch': lunch.toJson(),
      'dinner': dinner.toJson(),
    };
  }

  // Convert JSON → DayPlan
  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      lunch: Meal.fromJson(json['lunch']),
      dinner: Meal.fromJson(json['dinner']),
    );
  }
}
