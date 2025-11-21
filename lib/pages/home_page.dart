
import 'package:flutter/material.dart';
import 'meal_plan_page.dart';
import 'edit_food_page.dart';
import '../services/meal_generator.dart';
import 'shopping_list_page.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool hasShoppingList = false;
  WeekPlan? currentPlan;

  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    // Load saved plan if exists
    var box = Hive.box<String>('mealPlanBox');
    if (box.containsKey('currentPlan')) {
      currentPlan = WeekPlan.fromJson(jsonDecode(box.get('currentPlan')!));
      hasShoppingList = true;
    }

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(_buttonController);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _buttonController.forward();
  void _onTapUp(TapUpDetails details) => _buttonController.reverse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Planner"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Header image
              Image.asset('assets/meal.jpg', height: 150),
              const SizedBox(height: 40),

              // Generate Meal Plan Button
              _buildButton(
                icon: Icons.restaurant_menu,
                label: 'Generate 7-Day Meal Plan',
                gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                onTap: () {
                  final plan = generateWeekPlan();
                  setState(() {
                    currentPlan = plan;
                    hasShoppingList = true;
                  });
                  Hive.box<String>('mealPlanBox').put('currentPlan', jsonEncode(plan.toJson()));
                },
              ),

              // Go to Meal Plan Button
              _buildButton(
                icon: Icons.fastfood,
                label: 'Meal Plan',
                gradient: currentPlan != null
                    ? const LinearGradient(colors: [Colors.redAccent, Colors.orangeAccent])
                    : const LinearGradient(colors: [Colors.grey, Colors.grey]),
                onTap: currentPlan != null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MealPlanPage(plan: currentPlan!)),
                  );
                }
                    : null,
                disabled: currentPlan == null,
              ),

              // Add New Foods Button
              _buildButton(
                icon: Icons.add,
                label: 'Add New Meats / Veggies',
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditFoodPage()),
                  );
                },
              ),

              // Reset Button
              _buildButton(
                icon: Icons.clear,
                label: 'Clear / Reset List',
                gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                onTap: () async {
                  var box = Hive.box<String>('mealPlanBox');
                  await box.clear();
                  setState(() {
                    currentPlan = null;
                    hasShoppingList = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      // Shopping cart FAB
      floatingActionButton: hasShoppingList
          ? FloatingActionButton(
        onPressed: () {
          final shoppingList = generateShoppingList(currentPlan!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShoppingListPage(shoppingList: shoppingList),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_cart),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${generateShoppingList(currentPlan!).length}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTapDown: disabled ? null : _onTapDown,
      onTapUp: disabled ? null : _onTapUp,
      onTap: disabled ? null : onTap,
      child: AnimatedBuilder(
        animation: _buttonScale,
        builder: (context, child) => Transform.scale(
          scale: disabled ? 1.0 : _buttonScale.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (disabled ? Colors.grey : gradient.colors.last).withOpacity(0.5),
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: disabled ? Colors.black38 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
