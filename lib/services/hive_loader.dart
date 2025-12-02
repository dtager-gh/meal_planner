import 'package:hive_flutter/hive_flutter.dart';


Future<void> loadDefaultFoods() async {
  //These lines open “boxes” from Hive
  var meats = Hive.box<String>('meats');
  var veggies = Hive.box<String>('veggies');
  var salads = Hive.box<String>('salads');



  //If the meats box is empty → add these starter meats
  //If the user already added meats → do nothing
  // So the user always starts with options but you never override their saved data.
  if (meats.isEmpty) {
    meats.addAll([
      "Chicken",
      "Steak",
      "Pork",
      "Fish",
      "Ground Beef",
    ]);
  }


  //Same logic:
  if (veggies.isEmpty) {
    veggies.addAll([
      "Broccoli",
      "Green Beans",
      "Asparagus",
      "Spinach",
      "Zucchini",
    ]);
  }


  //Same logic:
  if (salads.isEmpty) {
    salads.addAll([
      "Garden Salad",
      "Caesar Salad",
    ]);
  }
}