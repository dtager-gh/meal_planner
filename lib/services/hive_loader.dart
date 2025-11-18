import 'package:hive_flutter/hive_flutter.dart';


Future<void> loadDefaultFoods() async {
  var meats = Hive.box<String>('meats');
  var veggies = Hive.box<String>('veggies');
  var salads = Hive.box<String>('salads');


  if (meats.isEmpty) {
    meats.addAll([
      "Chicken",
      "Steak",
      "Pork",
      "Fish",
      "Ground Beef",
    ]);
  }


  if (veggies.isEmpty) {
    veggies.addAll([
      "Broccoli",
      "Green Beans",
      "Asparagus",
      "Spinach",
      "Zucchini",
    ]);
  }


  if (salads.isEmpty) {
    salads.addAll([
      "Garden Salad",
      "Caesar Salad",
    ]);
  }
}