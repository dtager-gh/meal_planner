class Meal {
  final String meat;
  final List<String> sides;

  Meal({required this.meat, required this.sides});

  // Convert Meal → JSON
  Map<String, dynamic> toJson() {
    return {
      'meat': meat,
      'sides': sides,
    };
  }

  // Convert JSON → Meal
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      meat: json['meat'],
      sides: List<String>.from(json['sides']),
    );
  }
}
