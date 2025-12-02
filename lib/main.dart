import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/home_page.dart';
import 'services/hive_loader.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start Hive (your local storage system).
  await Hive.initFlutter();

  // Open your "boxes" — these work like small folders that store data on the phone.
  await Hive.openBox<String>('mealPlanBox');
  await Hive.openBox<String>('meats');
  await Hive.openBox<String>('veggies');
  await Hive.openBox<String>('salads');

  // Add default foods to Hive the FIRST time the app runs.
  await loadDefaultFoods();


  runApp(const MealPlannerApp());
}


class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),//This means the first screen the user sees is HomePage().
        theme: ThemeData(  //This is all styling — colors, buttons, text, background color.
          brightness: Brightness.light,
          primaryColor: const Color(0xFF6FAF98),
          scaffoldBackgroundColor: const Color(0xFFF5F5DC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6FAF98),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF6FAF98),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6FAF98),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: TextTheme(
            titleLarge: const TextStyle(color: Color(0xFF333333)),
            bodyLarge: const TextStyle(color: Color(0xFF333333)),
          ),
          cardColor: Colors.white,
        ),
    );
  }
}