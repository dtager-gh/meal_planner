import 'day_plan.dart';


// A WeekPlan represents 7 days of meals (or however many DayPlans you create)
class WeekPlan {

  // List of DayPlan objects, one for each day
  final List<DayPlan> days;

  // Constructor: pass in a list of DayPlan objects
  WeekPlan(this.days);

  // Convert the WeekPlan into JSON so it can be saved in Hive or anywhere
  Map<String, dynamic> toJson() {
    return {
      // Convert each DayPlan into JSON and store in a list
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  // Create a WeekPlan from JSON (used when loading saved data)
  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    return WeekPlan(
      // Take the 'days' list from JSON and convert each item back into a DayPlan
      (json['days'] as List)
          .map((dayJson) => DayPlan.fromJson(dayJson))
          .toList(),
    );
  }
}
