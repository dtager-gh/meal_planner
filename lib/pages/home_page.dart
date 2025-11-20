import 'package:flutter/material.dart';
import 'meal_plan_page.dart';
import 'edit_food_page.dart';
import '../services/meal_generator.dart';
import 'shopping_list_page.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';

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
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header image
                Image.asset(
                  'assets/meal.jpg',
                  height: 150,
                ),
                const SizedBox(height: 40),

                // Generate Meal Plan Button
                GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTap: () {
                    final plan = generateWeekPlan();
                    setState(() {
                      currentPlan = plan;
                      hasShoppingList = true;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MealPlanPage(plan: plan)),
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _buttonScale,
                    builder: (context, child) => Transform.scale(
                      scale: _buttonScale.value,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orangeAccent, Colors.deepOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.5),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Generate 7-Day Meal Plan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Add New Foods Button
                GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditFoodPage()),
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _buttonScale,
                    builder: (context, child) => Transform.scale(
                      scale: _buttonScale.value,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.greenAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Add New Meats / Veggies',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating Action Button for Shopping Cart
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: hasShoppingList
                ? () {
              final shoppingList = generateShoppingList(currentPlan!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShoppingListPage(shoppingList: shoppingList),
                ),
              );
            }
                : null,
            tooltip: 'View Shopping List',
            child: const Icon(Icons.shopping_cart),
          ),
          if (hasShoppingList)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${generateShoppingList(currentPlan!).length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
