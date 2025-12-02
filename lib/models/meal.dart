
// Represents a single meal (lunch or dinner)
class Meal {
  // The main protein of the meal, currently stored as a String
  final String meat;

  // List of sides (can be vegetables or salads)
  final List<String> sides;

  // Constructor: requires a meat and a list of sides
  Meal({required this.meat, required this.sides});

  // Convert a Meal object into JSON so it can be saved
  Map<String, dynamic> toJson() {
    return {
      'meat': meat,
      'sides': sides,
    };
  }

  // Create a Meal object from JSON (used when loading from Hive)
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      meat: json['meat'],// load the meat name
      sides: List<String>.from(json['sides']),// convert sides list from JSON
    );
  }
}
