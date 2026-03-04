import 'package:flutter/material.dart';
import 'meal_plan_page.dart';
import 'edit_food_page.dart';
import '../services/meal_generator.dart';
import 'shopping_list_page.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Meal Planner",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await context.read<AuthService>().logout();
                        if (!context.mounted) return;
                        Navigator.pop(context); // closes the dialog only
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/meal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient overlay for better readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Hero section with icon and title
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'Weekly Meal Planner',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Plan your week, shop smarter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Status card (shows if plan exists)
                          if (currentPlan != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.greenAccent,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Active Meal Plan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '7 days of meals ready',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Main action button (larger, more prominent)
                          _buildPrimaryButton(
                            icon: Icons.auto_awesome,
                            label: 'Generate New Plan',
                            gradient: const LinearGradient(
                              colors: [Colors.orangeAccent, Colors.deepOrange],
                            ),
                            onTap: () {
                              final plan = generateWeekPlan();
                              setState(() {
                                currentPlan = plan;
                                hasShoppingList = true;
                              });
                              Hive.box<String>('mealPlanBox').put('currentPlan', jsonEncode(plan.toJson()));
                            },
                          ),

                          const SizedBox(height: 20),

                          // Secondary buttons in a grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactButton(
                                  icon: Icons.calendar_today,
                                  label: 'View Plan',
                                  gradient: currentPlan != null
                                      ? const LinearGradient(colors: [Colors.blue, Colors.blueAccent])
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
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCompactButton(
                                  icon: Icons.add_circle,
                                  label: 'Add Foods',
                                  gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const EditFoodPage()),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Reset button (less prominent)
                          _buildTextButton(
                            icon: Icons.refresh,
                            label: 'Reset Everything',
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Reset Meal Plan?'),
                                  content: const Text('This will clear your current meal plan and shopping list.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        var box = Hive.box<String>('mealPlanBox');
                                        await box.clear();
                                        setState(() {
                                          currentPlan = null;
                                          hasShoppingList = false;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Reset',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: hasShoppingList
          ? FloatingActionButton.extended(
        onPressed: () {
          final shoppingList = generateShoppingList(currentPlan!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShoppingListPage(shoppingList: shoppingList),
            ),
          );
        },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_cart),
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '${generateShoppingList(currentPlan!).length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        label: const Text('Shopping List'),
      )
          : null,
    );
  }

  Widget _buildPrimaryButton({
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.last.withOpacity(0.4),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled
              ? []
              : [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: disabled ? Colors.black38 : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white70, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}