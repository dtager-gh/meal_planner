import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/home_page.dart';
import 'services/hive_loader.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Hive.initFlutter();


  await Hive.openBox<String>('meats');
  await Hive.openBox<String>('veggies');
  await Hive.openBox<String>('salads');


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
      home: const HomePage(),
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF6FAF98), // muted green
          scaffoldBackgroundColor: const Color(0xFFF5F5DC), // soft cream background
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
            titleLarge: const TextStyle(color: Color(0xFF333333)), // replaces bodyText1
            bodyLarge: const TextStyle(color: Color(0xFF333333)),  // replaces bodyText2
          ),
          cardColor: Colors.white,
        ),
    );
  }
}